SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE leave_types;
INSERT INTO leave_types (name, description, days_per_year, is_paid, requires_documentation) VALUES
('Vacation Leave', 'Paid vacation leave; must be filed at least 3 days before the requested start date', 7, 1, 0),
('Sick Leave', 'Leave for medical reasons', 5, 1, 0),
('Leave Without Pay', 'Unpaid leave, only usable once Vacation and Sick leave balances are exhausted', 999, 0, 1),
('Maternity Leave', 'Leave for maternity (RA 11210); female employees only', 105, 1, 1),
('Paternity Leave', 'Leave for paternity (RA 8187); male employees only', 7, 1, 1),
('Bereavement Leave', 'Leave for the death of an immediate family member', 3, 1, 1);
SET FOREIGN_KEY_CHECKS = 1;
