<?php
require_once __DIR__ . '/../src/auth/UserRegistration.php';

function assertPasswordPolicy($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$validator = new ReflectionMethod(UserRegistration::class, 'passwordValidationError');
$validator->setAccessible(true);

assertPasswordPolicy($validator->invoke(null, 'Abcdef1!') === null, 'A password meeting all requirements should pass');
assertPasswordPolicy($validator->invoke(null, 'Abc1!') !== null, 'A password shorter than 8 characters should fail');
assertPasswordPolicy($validator->invoke(null, 'abcdefg1!') !== null, 'A password without an uppercase letter should fail');
assertPasswordPolicy($validator->invoke(null, 'ABCDEFG1!') !== null, 'A password without a lowercase letter should fail');
assertPasswordPolicy($validator->invoke(null, 'Abcdefg!') !== null, 'A password without a number should fail');
assertPasswordPolicy($validator->invoke(null, 'Abcdefg1') !== null, 'A password without a special character should fail');
assertPasswordPolicy($validator->invoke(null, "Abcdef1 \t") !== null, 'Whitespace alone should not satisfy the special character requirement');

echo "PASS: password policy enforces length and character requirements\n";
