-- Test Database Connection and Data
USE EmployeePayRollDB;

-- Check if database exists and has data
SELECT 'Database Connection Test' as TestType, COUNT(*) as RecordCount FROM Employees WHERE IsActive = 1;

-- Check employee data
SELECT TOP 5 
    EmployeeId, 
    FullName, 
    Email, 
    DepartmentId, 
    RoleId, 
    Salary,
    IsActive 
FROM Employees 
WHERE IsActive = 1;

-- Check departments
SELECT * FROM Departments;

-- Check roles  
SELECT * FROM Roles;

-- Check if audit logs table exists
SELECT 'AuditLogs' as TableName, COUNT(*) as RecordCount FROM AuditLogs;

-- Check if leave requests table exists
SELECT 'LeaveRequests' as TableName, COUNT(*) as RecordCount FROM LeaveRequests;

-- Check if payroll table exists
SELECT 'Payroll' as TableName, COUNT(*) as RecordCount FROM Payroll;

-- Check if attendance table exists
SELECT 'Attendance' as TableName, COUNT(*) as RecordCount FROM Attendance;
