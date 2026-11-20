const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function createSettings() {
    const html = fs.readFileSync(path.join(__dirname, '../views/settings.html'), 'utf8');
    const start = html.indexOf('        async function loadMFAStatus()');
    const end = html.indexOf('        async function removeDevice(', start);
    assert.ok(start !== -1 && end !== -1);

    const elements = {};
    for (const id of ['mfa-status', 'mfa-btn', 'mfa-secret', 'mfa-code', 'qr-container', 'mfa-modal']) {
        const classes = new Set();
        elements[id] = {
            textContent: '', innerHTML: '', value: '', disabled: false,
            classList: {
                add: name => classes.add(name),
                remove: name => classes.delete(name),
                contains: name => classes.has(name),
            },
        };
    }

    const alerts = [];
    const calls = [];
    let enabled = false;
    let enableResult = { success: true };
    let confirm = true;
    const context = {
        document: { getElementById: id => elements[id] },
        UIManager: { showAlert: (message, type) => alerts.push({ message, type }) },
        confirmDialog: async () => confirm,
        AuthManager: {
            getMFAStatus: async () => ({ success: true, data: { enabled } }),
            setupMFA: async () => ({ success: true, secret: 'SECRET', qr_url: 'otpauth://test' }),
            enableMFA: async code => {
                calls.push(code);
                if (enableResult.success) enabled = true;
                return enableResult;
            },
            disableMFA: async () => {
                calls.push('disable');
                enabled = false;
                return { success: true };
            },
        },
    };
    vm.createContext(context);
    vm.runInContext(html.slice(start, end), context);
    return {
        context, elements, alerts, calls,
        setEnableResult: value => { enableResult = value; },
        setConfirm: value => { confirm = value; },
    };
}

test('setup supports manual entry and enables MFA with a valid code', async () => {
    const { context, elements, calls } = createSettings();
    await context.loadMFAStatus();
    await elements['mfa-btn'].onclick();
    assert.equal(elements['mfa-secret'].textContent, 'SECRET');
    assert.match(elements['qr-container'].textContent, /manually/);
    assert.equal(elements['mfa-modal'].classList.contains('active'), true);

    elements['mfa-code'].value = '012345';
    await context.verifyMFA();
    assert.deepEqual(calls, ['012345']);
    assert.equal(elements['mfa-modal'].classList.contains('active'), false);
    assert.equal(elements['mfa-btn'].textContent, 'Disable 2FA');
});

test('setup renders the authenticator QR code when the library is available', async () => {
    const { context, elements } = createSettings();
    let qrOptions;
    context.QRCode = function (container, options) {
        assert.equal(container, elements['qr-container']);
        qrOptions = options;
    };
    context.QRCode.CorrectLevel = { H: 2 };
    await context.setupMFA();
    assert.equal(qrOptions.text, 'otpauth://test');
    assert.equal(elements['mfa-modal'].classList.contains('active'), true);
});

test('invalid or rejected codes leave setup open', async () => {
    const { context, elements, calls, alerts, setEnableResult } = createSettings();
    await context.setupMFA();
    elements['mfa-code'].value = '123ab6';
    await context.verifyMFA();
    assert.deepEqual(calls, []);
    assert.equal(elements['mfa-modal'].classList.contains('active'), true);

    setEnableResult({ success: false, message: 'Invalid TOTP code' });
    elements['mfa-code'].value = '123456';
    await context.verifyMFA();
    assert.deepEqual(calls, ['123456']);
    assert.equal(elements['mfa-modal'].classList.contains('active'), true);
    assert.equal(alerts.at(-1).message, 'Invalid TOTP code');
});

test('disabling MFA requires confirmation and refreshes the control', async () => {
    const { context, elements, calls, setConfirm } = createSettings();
    elements['mfa-code'].value = '123456';
    await context.verifyMFA();
    setConfirm(false);
    await elements['mfa-btn'].onclick();
    assert.deepEqual(calls, ['123456']);
    setConfirm(true);
    await elements['mfa-btn'].onclick();
    assert.deepEqual(calls, ['123456', 'disable']);
    assert.equal(elements['mfa-btn'].textContent, 'Enable 2FA');
});
