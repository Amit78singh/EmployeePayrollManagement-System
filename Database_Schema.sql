-- Employee Payroll Management System Database Schema
-- SQL Server Database Creation Script

USE master;
GO

-- Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'EmployeePayrollDB')
BEGIN
    CREATE DATABASE EmployeePayrollDB;
END
GO

USE EmployeePayrollDB;
GO

-- Create Tables

-- 1. Departments Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Departments' AND xtype='U')
BEGIN
    CREATE TABLE Departments (
        DepartmentId INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL
    );
END
GO

-- 2. Roles Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Roles' AND xtype='U')
BEGIN
    CREATE TABLE Roles (
        RoleId INT IDENTITY(1,1) PRIMARY KEY,
        RoleName NVARCHAR(50) NOT NULL
    );
END
GO

-- 3. Employees Table (EmployeeId as IDENTITY)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Employees' AND xtype='U')
BEGIN
    CREATE TABLE Employees (
        EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NOT NULL UNIQUE,
        Phone NVARCHAR(20),
        Gender CHAR(1),
        JoinDate DATE NOT NULL,
        DepartmentId INT,
        RoleId INT,
        IsActive BIT DEFAULT 1,
        FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId),
        FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
    );
END
GO

-- 4. Attendance Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Attendance' AND xtype='U')
BEGIN
    CREATE TABLE Attendance (
        AttendanceId INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeId INT NOT NULL,
        AttendanceDate DATE NOT NULL,
        CheckInTime TIME,
        CheckOutTime TIME,
        Status NVARCHAR(20) DEFAULT 'Present',
        FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
        UNIQUE(EmployeeId, AttendanceDate)
    );
END
GO

-- 5. Leave Requests Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='LeaveRequests' AND xtype='U')
BEGIN
    CREATE TABLE LeaveRequests (
        LeaveRequestId INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeId INT NOT NULL,
        FromDate DATE NOT NULL,
        ToDate DATE NOT NULL,
        Reason NVARCHAR(500),
        Status NVARCHAR(20) DEFAULT 'Pending',
        ApprovedBy NVARCHAR(100),
        ApprovedDate DATETIME,
        RequestDate DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
    );
END
GO

-- 6. Holidays Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Holidays' AND xtype='U')
BEGIN
    CREATE TABLE Holidays (
        HolidayId INT IDENTITY(1,1) PRIMARY KEY,
        HolidayName NVARCHAR(100) NOT NULL,
        HolidayDate DATE NOT NULL
    );
END
GO

-- 7. Payroll Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Payroll' AND xtype='U')
BEGIN
    CREATE TABLE Payroll (
        PayrollId INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeId INT NOT NULL,
        Month INT NOT NULL,
        Year INT NOT NULL,
        BasicSalary DECIMAL(18,2) NOT NULL,
        HRA DECIMAL(18,2) DEFAULT 0,
        DA DECIMAL(18,2) DEFAULT 0,
        Deductions DECIMAL(18,2) DEFAULT 0,
        LeaveDeductions DECIMAL(10,2) DEFAULT 0,
        NetSalary AS ((BasicSalary + HRA + DA) - Deductions) PERSISTED,
        GeneratedOn DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
        UNIQUE(EmployeeId, Month, Year)
    );
END
GO

-- 8. Salary Components Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SalaryComponents' AND xtype='U')
BEGIN
    CREATE TABLE SalaryComponents (
        ComponentId INT IDENTITY(1,1) PRIMARY KEY,
        PayrollId INT NOT NULL,
        ComponentName NVARCHAR(100) NOT NULL,
        Amount DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (PayrollId) REFERENCES Payroll(PayrollId)
    );
END
GO

-- 9. Audit Logs Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AuditLogs' AND xtype='U')
BEGIN
    CREATE TABLE AuditLogs (
        LogId INT IDENTITY(1,1) PRIMARY KEY,
        TableName NVARCHAR(100) NOT NULL,
        Action NVARCHAR(20) NOT NULL,
        ChangedBy NVARCHAR(100),
        ChangedOn DATETIME DEFAULT GETDATE(),
        OldValues NVARCHAR(MAX),
        NewValues NVARCHAR(MAX)
    );
END
GO

-- Insert Initial Data

-- Insert Departments
IF NOT EXISTS (SELECT * FROM Departments)
BEGIN
    INSERT INTO Departments (Name) VALUES 
    ('Human Resources'),
    ('Information Technology'),
    ('Finance'),
    ('Operations'),
    ('Marketing');
END
GO

-- Insert Roles
IF NOT EXISTS (SELECT * FROM Roles)
BEGIN
    INSERT INTO Roles (RoleName) VALUES 
    ('Manager'),
    ('Senior Developer'),
    ('Junior Developer'),
    ('HR Executive'),
    ('Accountant'),
    ('Marketing Executive');
END
GO

-- Insert Holidays
IF NOT EXISTS (SELECT * FROM Holidays)
BEGIN
    INSERT INTO Holidays (HolidayName, HolidayDate) VALUES 
    ('New Year', '2024-01-01'),
    ('Republic Day', '2024-01-26'),
    ('Independence Day', '2024-08-15'),
    ('Gandhi Jayanti', '2024-10-02'),
    ('Diwali', '2024-11-01');
END
GO

-- Create Views

-- Employee Salary Slip View
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_EmployeeSalarySlip')
BEGIN
    EXEC('CREATE VIEW vw_EmployeeSalarySlip AS
    SELECT 
        p.PayrollId,
        e.EmployeeId,
        e.FullName,
        d.Name AS DEpartmentName,
        p.Month,
        p.Year,
        p.BasicSalary,
        p.HRA,
        p.DA,
        p.Deductions,
        p.NetSalary
    FROM Payroll p
    INNER JOIN Employees e ON p.EmployeeId = e.EmployeeId
    LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId');
END
GO

-- Leave Request Details View
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_LeaveRequestDetails')
BEGIN
    EXEC('CREATE VIEW vw_LeaveRequestDetails AS
    SELECT 
        lr.LeaveRequestId,
        lr.EmployeeId,
        e.FullName,
        d.Name AS DepartmentName,
        lr.FromDate,
        lr.ToDate,
        DATEDIFF(day, lr.FromDate, lr.ToDate) + 1 AS LeaveDays,
        lr.Reason,
        lr.Status,
        lr.ApprovedBy,
        lr.ApprovedDate,
        lr.RequestDate
    FROM LeaveRequests lr
    INNER JOIN Employees e ON lr.EmployeeId = e.EmployeeId
    LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId');
END
GO

-- Monthly Attendance Summary View
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_MonthlyAttendanceSummary')
BEGIN
    EXEC('CREATE VIEW vw_MonthlyAttendanceSummary AS
    SELECT 
        e.EmployeeId,
        e.FullName,
        YEAR(a.AttendanceDate) AS Year,
        MONTH(a.AttendanceDate) AS Month,
        DATENAME(MONTH, a.AttendanceDate) AS MonthName,
        COUNT(*) AS TotalDays,
        SUM(CASE WHEN a.Status = ''Present'' THEN 1 ELSE 0 END) AS PresentDays,
        SUM(CASE WHEN a.Status = ''Absent'' THEN 1 ELSE 0 END) AS AbsentDays
    FROM Employees e
    LEFT JOIN Attendance a ON e.EmployeeId = a.EmployeeId
    GROUP BY e.EmployeeId, e.FullName, YEAR(a.AttendanceDate), MONTH(a.AttendanceDate), DATENAME(MONTH, a.AttendanceDate)');
END
GO

-- Create Stored Procedures

-- Employee CRUD Procedures
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Employee_GetAll')
    DROP PROCEDURE usp_Employee_GetAll;
GO

CREATE PROCEDURE usp_Employee_GetAll
AS
BEGIN
    SELECT 
        e.EmployeeId,
        e.FullName,
        e.Email,
        e.Phone,
        e.Gender,
        e.JoinDate,
        e.DepartmentId,
        d.Name AS DepartmentName,
        e.RoleId,
        r.RoleName,
        e.IsActive
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId
    LEFT JOIN Roles r ON e.RoleId = r.RoleId
    ORDER BY e.EmployeeId;
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Employee_Create')
    DROP PROCEDURE usp_Employee_Create;
GO

CREATE PROCEDURE usp_Employee_Create
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,
    @Gender CHAR(1) = NULL,
    @JoinDate DATE,
    @DepartmentId INT = NULL,
    @RoleId INT = NULL
AS
BEGIN
    DECLARE @EmployeeId INT;
    
    INSERT INTO Employees (FullName, Email, Phone, Gender, JoinDate, DepartmentId, RoleId)
    VALUES (@FullName, @Email, @Phone, @Gender, @JoinDate, @DepartmentId, @RoleId);
    
    SET @EmployeeId = SCOPE_IDENTITY();
    
    -- Log audit
    INSERT INTO AuditLogs (TableName, Action, ChangedBy, NewValues)
    VALUES ('Employees', 'INSERT', @Email, 
            'EmployeeId: ' + CAST(@EmployeeId AS NVARCHAR) + ', FullName: ' + @FullName);
    
    SELECT @EmployeeId AS EmployeeId;
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Employee_Update')
    DROP PROCEDURE usp_Employee_Update;
GO

CREATE PROCEDURE usp_Employee_Update
    @EmployeeId INT,
    @FullName NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,
    @Gender CHAR(1) = NULL,
    @JoinDate DATE,
    @DepartmentId INT = NULL,
    @RoleId INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    UPDATE Employees 
    SET FullName = @FullName,
        Phone = @Phone,
        Gender = @Gender,
        JoinDate = @JoinDate,
        DepartmentId = @DepartmentId,
        RoleId = @RoleId,
        IsActive = @IsActive
    WHERE EmployeeId = @EmployeeId;
    
    -- Log audit
    INSERT INTO AuditLogs (TableName, Action, ChangedBy, NewValues)
    VALUES ('Employees', 'UPDATE', 'System', 
            'EmployeeId: ' + CAST(@EmployeeId AS NVARCHAR) + ', Updated');
END
GO

-- Employee Delete Procedure
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Employee_Delete')
    DROP PROCEDURE usp_Employee_Delete;
GO

CREATE PROCEDURE usp_Employee_Delete
    @EmployeeId INT
AS
BEGIN
    -- Soft delete by setting IsActive = 0
    UPDATE Employees 
    SET IsActive = 0
    WHERE EmployeeId = @EmployeeId;
    
    -- Log audit
    INSERT INTO AuditLogs (TableName, Action, ChangedBy, NewValues)
    VALUES ('Employees', 'DELETE', 'System', 
            'EmployeeId: ' + CAST(@EmployeeId AS NVARCHAR) + ', Deactivated');
END
GO

-- Employee GetById Procedure
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Employee_GetById')
    DROP PROCEDURE usp_Employee_GetById;
GO

CREATE PROCEDURE usp_Employee_GetById
    @EmployeeId INT
AS
BEGIN
    SELECT 
        e.EmployeeId,
        e.FullName,
        e.Email,
        e.Phone,
        e.Gender,
        e.JoinDate,
        e.DepartmentId,
        d.Name AS DepartmentName,
        e.RoleId,
        r.RoleName,
        e.Salary,
        e.IsActive
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId
    LEFT JOIN Roles r ON e.RoleId = r.RoleId
    WHERE e.EmployeeId = @EmployeeId;
END
GO

-- Attendance Procedures
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Attendance_Insert')
    DROP PROCEDURE usp_Attendance_Insert;
GO

CREATE PROCEDURE usp_Attendance_Insert
    @EmployeeId INT,
    @AttendanceDate DATE,
    @CheckInTime TIME = NULL,
    @CheckOutTime TIME = NULL,
    @Status NVARCHAR(20) = 'Present'
AS
BEGIN
    INSERT INTO Attendance (EmployeeId, AttendanceDate, CheckInTime, CheckOutTime, Status)
    VALUES (@EmployeeId, @AttendanceDate, @CheckInTime, @CheckOutTime, @Status);
END
GO

-- Leave Procedures
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Leave_Apply')
    DROP PROCEDURE usp_Leave_Apply;
GO

CREATE PROCEDURE usp_Leave_Apply
    @EmployeeId INT,
    @FromDate DATE,
    @ToDate DATE,
    @Reason NVARCHAR(500)
AS
BEGIN
    INSERT INTO LeaveRequests (EmployeeId, FromDate, ToDate, Reason, Status)
    VALUES (@EmployeeId, @FromDate, @ToDate, @Reason, 'Pending');
    
    SELECT SCOPE_IDENTITY() AS LeaveRequestId;
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Leave_Approve')
    DROP PROCEDURE usp_Leave_Approve;
GO

CREATE PROCEDURE usp_Leave_Approve
    @LeaveRequestId INT,
    @ApprovedBy NVARCHAR(100),
    @Status NVARCHAR(20)
AS
BEGIN
    UPDATE LeaveRequests 
    SET Status = @Status,
        ApprovedBy = @ApprovedBy,
        ApprovedDate = GETDATE()
    WHERE LeaveRequestId = @LeaveRequestId;
END
GO

-- Payroll Procedures
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Payroll_Calculate')
    DROP PROCEDURE usp_Payroll_Calculate;
GO

CREATE PROCEDURE usp_Payroll_Calculate
    @EmployeeId INT,
    @Month INT,
    @Year INT,
    @BasicSalary DECIMAL(18,2),
    @HRA DECIMAL(18,2) = 0,
    @DA DECIMAL(18,2) = 0,
    @Deductions DECIMAL(18,2) = 0
AS
BEGIN
    -- Check if payroll already exists
    IF EXISTS (SELECT 1 FROM Payroll WHERE EmployeeId = @EmployeeId AND Month = @Month AND Year = @Year)
    BEGIN
        UPDATE Payroll 
        SET BasicSalary = @BasicSalary,
            HRA = @HRA,
            DA = @DA,
            Deductions = @Deductions
        WHERE EmployeeId = @EmployeeId AND Month = @Month AND Year = @Year;
    END
    ELSE
    BEGIN
        INSERT INTO Payroll (EmployeeId, Month, Year, BasicSalary, HRA, DA, Deductions)
        VALUES (@EmployeeId, @Month, @Year, @BasicSalary, @HRA, @DA, @Deductions);
    END
END
GO

-- Create Triggers for Audit Logging
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterAttendanceInsert')
    DROP TRIGGER trg_AfterAttendanceInsert;
GO

CREATE TRIGGER trg_AfterAttendanceInsert
ON Attendance
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLogs (TableName, Action, ChangedBy, NewValues)
    SELECT 'Attendance', 'INSERT', 'System',
           'EmployeeId: ' + CAST(i.EmployeeId AS NVARCHAR) + ', Date: ' + CAST(i.AttendanceDate AS NVARCHAR)
    FROM inserted i;
END
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterLeaveUpdate')
    DROP TRIGGER trg_AfterLeaveUpdate;
GO

CREATE TRIGGER trg_AfterLeaveUpdate
ON LeaveRequests
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditLogs (TableName, Action, ChangedBy, NewValues)
    SELECT 'LeaveRequests', 'UPDATE', i.ApprovedBy,
           'LeaveRequestId: ' + CAST(i.LeaveRequestId AS NVARCHAR) + ', Status: ' + i.Status
    FROM inserted i;
END
GO

PRINT 'Database schema created successfully!';
