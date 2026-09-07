# Leave Approval Process Documentation

## Diagram Selection

The two processes use different diagram types because they describe different perspectives:

- **Old Process: BPMN** documents the end-to-end organizational process involving the employee, supervisor, Google Forms, Google account notifications, and HRIS.
- **New Process: UML Activity Diagram** documents how the LeaveSync application behaves when an employee submits a leave request and when supervisors or HR process the request.

BPMN explains how the organization delivers the process. UML Activity Diagrams explain how the software use case behaves within that process.

---

## Old Process: BPMN Analysis

### Process Name

Manual Leave Request and HRIS Approval Process

### Objective

Allow an employee to submit a leave request through Google Forms and have the supervisor review and record the result in HRIS.

### Start Condition

The employee needs to request leave.

### Participants and Systems

- Employee
- Google Forms
- Supervisor's Google account
- Supervisor
- HRIS

### Inputs

- Employee identity
- Leave type
- Leave start date
- Leave end date
- Leave reason

### Outputs

- Approved leave recorded in HRIS and deducted from the employee's balance; or
- Rejected leave recorded in HRIS with no balance deduction.

### Business Rules

1. The employee submits the request through Google Forms.
2. The supervisor receives the request through the supervisor's Google account.
3. The supervisor reviews the request.
4. The supervisor either approves or rejects the request.
5. The supervisor manually enters the result into HRIS under the employee who submitted the request.
6. HRIS deducts the leave from the employee's balance only when the request is entered as approved.
7. A rejected request does not reduce the employee's leave balance.

### Main BPMN Activities

1. Complete leave request in Google Form.
2. Submit leave request.
3. Receive request through the supervisor's Google account.
4. Review leave request.
5. Decide whether to approve the request.
6. Enter the approved or rejected result into HRIS.
7. Deduct the approved leave days from the employee's balance, or keep the balance unchanged when rejected.
8. Record the final result.

### BPMN Diagram Explanation

#### Employee Lane

The Employee lane begins the process. The employee completes the leave request form with the required leave information and submits it through Google Forms. The submission is the message or information flow that moves the process to the supervisor.

#### Supervisor / Google Account Lane

The Supervisor / Google Account lane represents both the notification channel and the supervisor's work. The supervisor receives the submitted request through the Google account, reviews the information, and reaches the main business decision: approve or reject the request.

#### Approval Path

When the supervisor approves the request, the supervisor enters the approved leave into HRIS under the employee's account. The HRIS then deducts the approved number of leave days from that employee's balance and records the approved leave.

#### Rejection Path

When the supervisor rejects the request, the supervisor enters the rejected result into HRIS. HRIS records the rejection and leaves the employee's leave balance unchanged.

#### BPMN Decision Gateway

The approval decision is modeled as an exclusive gateway because the request follows exactly one of two paths: approved or rejected. The paths do not execute at the same time.

#### BPMN End Condition

The process ends after HRIS records the result and applies the corresponding balance action.

---

## New Process: UML Activity Diagram

### Process Name

Submit and Approve Leave Request in LeaveSync

### Objective

Allow an employee to submit a leave request in LeaveSync and allow the appropriate supervisor and HR approvers to process it while the system manages validation, balance reservation, approval status, and balance updates.

### Start Condition

The employee opens the New Request page in LeaveSync.

### Inputs

- Selected leave type
- Leave start date
- Leave end date
- Leave reason
- Employee account and trusted-device context

### Outputs

- A pending leave request with reserved balance;
- A rejected request with the reserved days returned to the balance; or
- An approved request with the days transferred from pending days to used days.

### System Rules

1. The leave type must exist and be available to the employee.
2. The end date cannot be before the start date.
3. Saturdays and Sundays do not count as leave days.
4. A date range containing no weekdays cannot be submitted.
5. An employee cannot submit a request overlapping an existing pending or approved request.
6. The selected leave type must have enough available balance.
7. Only a registered and trusted device may submit the request.
8. An employee request first waits for supervisor approval and then HR approval.
9. A manager's request goes directly to HR approval.
10. An approved request deducts days from the selected leave type and increases used days.
11. A rejected request restores the reserved days to the selected leave type balance.
12. Approval actions require the authorized approver's passkey assertion.

### Main UML Activities

1. Display the New Request page.
2. Select the leave type.
3. Enter the date range and reason.
4. Count weekdays in the date range.
5. Validate the request data.
6. Check for overlapping pending or approved requests.
7. Check the selected leave-type balance.
8. Verify the submitting device is trusted.
9. Create the leave request.
10. Deduct the days from the available balance and increase pending days.
11. Route the request to the supervisor or HR.
12. Verify the approver's passkey.
13. Approve or reject the request at the current approval stage.
14. Transfer pending days to used days on final approval, or restore the balance on rejection.
15. Display the final request status.

### UML Activity Diagram Explanation

#### Initial Node

The solid black circle indicates that the activity begins when the employee opens the New Request page in LeaveSync. It identifies where control enters the software activity and is not itself an action.

#### Select Leave Type and Enter Request Data

The employee selects a specific leave type, enters the start and end dates, and provides a reason. These values are the input data used by the validation and balance actions.

#### Count Weekdays

The system calculates the number of leave days by iterating from the start date through the end date. Monday through Friday are counted. Saturday and Sunday are skipped. For example, a request from September 11 through September 14 counts only the Friday and Monday as two leave days.

#### Validate the Date Range

The system checks that the end date is not before the start date and that the range contains at least one weekday. An invalid range returns an error to the employee instead of creating a request.

#### Check for an Overlapping Request

The system searches for another request belonging to the same employee whose dates overlap the requested range. Only pending and approved requests block the new request. Rejected and cancelled requests do not block it.

If an overlap exists, the system displays an error and returns the employee to request entry.

#### Check the Selected Leave Balance

The system checks the balance row belonging to the selected leave type. The balance of another leave type is not used for this check. If the selected type does not have enough available days, the request is rejected before creation.

#### Verify the Trusted Device

The system confirms that the request is being submitted from a device registered and trusted for the employee. An untrusted device cannot submit the leave request.

#### Create the Pending Request

After validation succeeds, the system creates the leave request with its selected leave type, dates, weekday count, reason, and approval statuses.

#### Reserve the Leave Balance

The system immediately subtracts the weekday count from the selected leave type's available balance and adds the same number to pending days. This prevents the employee from submitting another request using the same available days while the request is waiting for approval.

#### Route the Request

For an employee request, the system routes the request to the assigned supervisor first. After supervisor approval, the request moves to HR. A manager's request skips the supervisor stage and goes directly to HR.

#### Approval Passkey Verification

Before an authorized supervisor or HR user approves a request, LeaveSync requests a passkey assertion. The system verifies the approval challenge, the registered credential, the user verification result, and the passkey's device binding. A failed assertion prevents approval.

#### Supervisor Decision

The supervisor decision has two guarded paths:

- **[Approve]**: The supervisor approval status is recorded, and the request moves to the HR stage.
- **[Reject]**: The request becomes rejected, pending days are reduced, and the reserved days are returned to the selected leave balance.

#### HR Decision

HR makes the final approval decision:

- **[Approve]**: Pending days are reduced and used days are increased by the stored weekday count.
- **[Reject]**: Pending days are reduced and the same days are returned to the selected leave balance.

#### Balance Transfer

The final approval does not count the days again. It transfers the already reserved days from `pending_days` to `used_days`. Rejection transfers the reserved days back to `balance` instead.

#### Activity Final Node

The activity reaches its final node after the request is approved or rejected, the appropriate balance update is completed, and the final status is available to the employee and approvers.
