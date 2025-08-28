CREATE DATABASE EmployeePayRollDB;
GO

sp_helptext 'usp_LeaveRequest_Apply'

sp_helptext 'usp_Payroll_GenerateMonthly'

USE EmployeePayRollDB;

 CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    EmployeeId INT NULL,
    Username NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARBINARY(64) NOT NULL,  -- store binary hash, not plain text
    Role NVARCHAR(50) NOT NULL,
    CreatedOn DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);



INSERT INTO Users (Username, PasswordHash, Role)
VALUES
('admin', HASHBYTES('SHA2_256', 'admin123'), 'Admin'),
('hruser', HASHBYTES('SHA2_256', 'hr123'), 'HR'),
('emp1', HASHBYTES('SHA2_256', 'emp123'), 'Employee');

---DepartMents

CREATE TABLE Departments(
DepartmentId INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(100) NOT NULL
);

--Roles
 CREATE TABLE Roles(
 RoleId INT PRIMARY KEY IDENTITY(1,1),
 RoleName NVARCHAR(50) NOT NULL
 );

 --EMPLOYEeS
 CREATE TABLE Employees(
 EmployeeId INT PRIMARY KEY IDENTITY (1,1),
 FullName NVARCHAR(100) NOT NULL,
 Email NVARCHAR(100) UNIQUE NOT NULL,
 Phone NVARCHAR(20),
 Gender CHAR(1),
 JoinDate DATE NOT NULL,
 DepartmentId INT,
 RoleId INT,
 IsActive BIT DEFAULT 1,
 FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId),
 FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
 );
  

  --Attendence 

  CREATE TABLE Attendance(
  AttendanceId INT PRIMARY KEY IDENTITY(1,1),
  EmployeeId INT,
  AttendanceDate DATE NOT NULL,
  InTime TIME,
  OutTime TIME,
  Status NVARCHAR(20),--for present, absent , leave
  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
  
  );

  -- LEAVE REQUEST

  CREATE TABLE LeaveRequests(
  LeaveRequestId INT PRIMARY KEY IDENTITY (1,1),
  EmployeeId INT,
  FromDate DATE,
  ToDate DATE,
  Status NVARCHAR(20),----Present, Absent ,Leave
  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
  );

  ALTER TABLE LeaveRequests
ADD
    ApprovedBy NVARCHAR(100) NULL,
    ApprovedDate DATETIME NULL;

  --Payroll

  CREATE TABLE Payroll(
  PayrollId INT PRIMARY KEY IDENTITY(1,1),
  EmployeeId INT,
  [Month] INT,
  [Year] INT,
  BasicSalary DECIMAL(18,2),
  HRA DECIMAL(18,2),
  DA DECIMAL(18,2),
  Deductions DECIMAL(18,2),
  NetSalary AS (BasicSalary + HRA + DA - Deductions) PERSISTED,
  GeneratedOn DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
  );

  ALTER TABLE Payroll
ADD TotalLeaves INT,
    WorkingDays INT,
    PresentDays INT,
    LeaveDeductions DECIMAL(10, 2);

    SELECT * FROM Payroll
  -- Holiday

 CREATE TABLE Holidays(
 HolidayId INT PRIMARY KEY IDENTITY(1,1),
 HolidayName NVARCHAR(100),
 HolidayDate DATE
 );

 CREATE TABLE SalaryComponents (
    ComponentId INT PRIMARY KEY IDENTITY(1,1),
    PayrollId INT,
    ComponentName NVARCHAR(100),
    Amount DECIMAL(10,2),
    FOREIGN KEY (PayrollId) REFERENCES Payroll(PayrollId)
);

CREATE TABLE AuditLogs (
    LogId INT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(100),
    Action NVARCHAR(20),
    ChangedBy NVARCHAR(100),
    ChangedOn DATETIME DEFAULT GETDATE(),
    Details NVARCHAR(MAX)
);


--------***************------

--Insert Department
INSERT INTO Departments(Name) VALUES
('Human Resources'),
('IT'),
('Finance');

 --Insert ROles

INSERT INTO Roles(RoleName) VALUES
('Admin'),
('Manager'),
('Developer'),
('HR Executive');

--Insert Employees
INSERT INTO Employees(FullName,Email,Phone,Gender,JoinDate,DepartmentId,RoleId)
VALUES
('Amit Singh','Aamit@gmail.com','7860592343','M','2024-01-15',2,3),
('Sumit Singh','Sumit@gmail.com','7755844573','M','2024-01-15',2,4),
('Pawan Singh','Pawan@gmail.com','7845623322','M','2024-01-15',1,2),
('Anshu Singh','Anshu@gmail.com','7866544333','M','2024-01-15',3,2),
('Jane Smith', 'jane@example.com', '9876543210', 'F', '2023-11-10', 1, 4);

-- Insert Attendence
INSERT INTO Attendance(EmployeeId,AttendanceDate,InTime,OutTime,Status)
VALUES
(1, '2025-08-01', '09:00', '17:30', 'Present'),
(2, '2025-08-01', '09:10', '17:00', 'Present'),
(3, '2025-08-01', NULL, NULL, 'Leave');

--Insert In LeaveRequest

INSERT INTO LeaveRequests (EmployeeId, FromDate, ToDate, Status)
VALUES 
(3, '2025-08-01', '2025-08-02', 'Approved');

--Insert into Payroll

INSERT INTO Payroll(EmployeeId,[Month],[Year], BasicSalary,HRA,DA,Deductions)
VALUES
(1,8,2025,30000,1000,1000,1000),
(2,8,2025,30000,4000,3000,3000),
(3,8,2025,40000,8000,5000,5000),
(4,8,2025,30000,3000,2000,500);

-- Get all Employee
SELECT * FROM Employees;

--Get all employee with their department and role 

SELECT e.FullName,e.Email,d.Name AS Department, r.RoleName
FROM Employees e
JOIN Departments d ON e.DepartmentId=d.DepartmentId
JOIN Roles r ON e.RoleId = r.RoleId;

--Get Attendance For 1st August
SELECT a.*,e.FullName
FROM Attendance a
JOIN Employees e ON a.EmployeeId = e.EmployeeId
WHERE AttendanceDate = '2025-08-01';

--Update
UPDATE Employees
SET Phone='999999999'
WHERE EmployeeId=1;

--Mark Attendance Absent
UPDATE Attendance
SET Status='Absent'
WHERE AttendanceId=2;

---Delete a Leave Request
DELETE FROM LeaveRequests
WHERE LeaveRequestId=1;
--
-- Step 1: Drop if already exists (optional but recommended)
IF OBJECT_ID('sp_MarkAttendance', 'P') IS NOT NULL
    DROP PROCEDURE sp_MarkAttendance;
GO


----- ****<>>>>

-- Step 2: Create the procedure

--CreateStored Procedure FOr Registration

CREATE OR ALTER PROCEDURE usp_User_Register
    @Username NVARCHAR(100),
    @Password NVARCHAR(100),
    @Role NVARCHAR(50),
    @EmployeeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hash VARBINARY(64);

    -- Hash password before storing
    SET @Hash = HASHBYTES('SHA2_256', CAST(@Password AS NVARCHAR(4000)));

    IF EXISTS (SELECT 1 FROM Users WHERE Username=@Username)
    BEGIN
        SELECT -1 AS StatusCode, 'Username Already Exists' AS Message;
        RETURN;
    END

    INSERT INTO Users (EmployeeId, Username, PasswordHash, Role)
    VALUES (@EmployeeId, @Username, @Hash, @Role);

    SELECT 0 AS StatusCode, 'User Registered Successfully' AS Message;
END;
GO



-- Create Secure Stored Procedure for Login
IF OBJECT_ID('usp_User_Login', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_User_Login;
GO

CREATE PROCEDURE dbo.usp_User_Login
    @Username NVARCHAR(100),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId INT, 
            @DbPassword VARBINARY(64),  -- store hash
            @Role NVARCHAR(50),
            @InputHash VARBINARY(64);

    -- Step 1: Hash the input password
    SET @InputHash = HASHBYTES('SHA2_256', CAST(@Password AS NVARCHAR(4000)));

    -- Step 2: Get stored hash from DB
    SELECT @UserId = UserId, 
           @DbPassword = PasswordHash, 
           @Role = Role
    FROM Users 
    WHERE Username = @Username;

    -- Step 3: Check if user exists
    IF @UserId IS NULL
    BEGIN
        SELECT -1 AS StatusCode, 'Invalid Username' AS Message;
        RETURN;
    END;

    -- Step 4: Compare input hash with stored hash
    IF @DbPassword <> @InputHash
    BEGIN
        SELECT -1 AS StatusCode, 'Invalid Password' AS Message;
        RETURN;
    END;

    -- Step 5: Successful login
    SELECT 0 AS StatusCode, 'Login Successful' AS Message, 
           @UserId AS UserId, @Role AS Role;
END;
GO

        


IF OBJECT_ID('dbo.usp_Employee_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Employee_GetAll;
GO

CREATE PROCEDURE dbo.usp_Employee_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        EmployeeId,
        FullName,
        Email,
        Phone,
        Gender,
        JoinDate,
        DepartmentId,
        RoleId,
        IsActive
    FROM Employees;
END;
GO


--- — Create Employee
IF OBJECT_ID('dbo.usp_Employee_Create', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Employee_Create;
GO

CREATE PROCEDURE dbo.usp_Employee_Create
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,
    @Gender CHAR(1) = NULL,
    @JoinDate DATE,
    @DepartmentId INT = NULL,
    @RoleId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Employees (FullName, Email, Phone, Gender, JoinDate, DepartmentId, RoleId)
    VALUES (@FullName, @Email, @Phone, @Gender, @JoinDate, @DepartmentId, @RoleId);

    SELECT SCOPE_IDENTITY() AS EmployeeId;
END;

----- Update Employee
IF OBJECT_ID('dbo.usp_Employee_Update', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Employee_Update;
GO

CREATE PROCEDURE dbo.usp_Employee_Update
    @EmployeeId INT,
    @FullName NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,
    @Gender CHAR(1) = NULL,
    @JoinDate DATE,
    @DepartmentId INT = NULL,
    @RoleId INT = NULL,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Employees
    SET FullName     = @FullName,
        Phone        = @Phone,
        Gender       = @Gender,
        JoinDate     = @JoinDate,
        DepartmentId = @DepartmentId,
        RoleId       = @RoleId,
        IsActive     = @IsActive
    WHERE EmployeeId = @EmployeeId;
END;
GO

--- GET Leave Request List
IF OBJECT_ID('dbo.usp_LeaveRequest_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_LeaveRequest_GetAll;
GO

CREATE PROCEDURE dbo.usp_LeaveRequest_GetAll
    @EmployeeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        LeaveRequestId,
        EmployeeId,
        FromDate,
        ToDate,
        Status,
        ApprovedBy,
        ApprovedDate
    FROM LeaveRequests
    WHERE (@EmployeeId IS NULL OR EmployeeId = @EmployeeId);
END;
GO

--— Get Payroll Slip

IF OBJECT_ID('dbo.usp_Payroll_GetSlip', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Payroll_GetSlip;
GO

CREATE PROCEDURE dbo.usp_Payroll_GetSlip
    @EmployeeId INT,
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        PayrollId,
        EmployeeId,
        [Year],
        [Month],
        BasicSalary,
        HRA,
        DA,
        Deductions,
        NetSalary,
        WorkingDays,
        PresentDays,
        TotalLeaves,
        LeaveDeductions,
        GeneratedOn
    FROM Payroll
    WHERE EmployeeId = @EmployeeId
      AND [Year] = @Year
      AND [Month] = @Month;
END;
GO



IF OBJECT_ID('usp_Attendance_Mark', 'P') IS NOT NULL
    DROP PROCEDURE usp_Attendance_Mark;
GO

CREATE  PROCEDURE usp_Attendance_Mark
    @EmployeeId INT,
    @AttendanceDate DATETIME,
    @InTime TIME =NULL,
    @OutTime TIME =NULL,
    @Status NVARCHAR(20),
    @StatusCode INT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

        --DECLARE @StatusCode INT = 0;
        --DECLARE @Message NVARCHAR(255);

    BEGIN TRY
          -- 1 Parameter validation
        IF @EmployeeId IS NULL OR @AttendanceDate IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'EmployeeId and AttendanceDate are Required';
          ---  SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

                -- 2. Check if employee exists

    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId =@EmployeeId AND IsActive = 1)
        BEGIN
            SET @StatusCode =1;
            SET @Message = 'Invalid or inactive EmployeeId.';
         --   SELECT @StatusCode AS StatusCode, @Message AS Message;
             RETURN;
        END

                -- 3. Duplicate check or alreadymarked 
      IF EXISTS (
            SELECT 1 FROM Attendance
            WHERE EmployeeId = @EmployeeId AND AttendanceDate = @AttendanceDate
        )
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Attendance already marked for this date.';
         --   SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END


    --BEGIN TRASCATION
    -- Insert Attendance

  BEGIN TRAN;

    INSERT INTO Attendance(EmployeeId, AttendanceDate, InTime, OutTime, Status)
    VALUES (@EmployeeId, @AttendanceDate, @InTime, @OutTime, @Status);

    --- Add Logging InsideSP(Audit Logs)--Optional

    INSERT INTO AuditLogs(TableName,Action,ChangedBy,Details)
    VALUES('Attendance', 'INSERT', 
    SYSTEM_USER,
    CONCAT('Attendance Makrekd For EmpId=',@EmployeeId, 'on', @AttendanceDate)
    );

    COMMIT TRAN;

     -- 5. Success

        SET @Message = 'Attendance marked successfully.';
       -- SELECT @StatusCode AS StatusCode, @Message AS Message;
    END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    SET @StatusCode = -1;
    SET @Message = ERROR_MESSAGE();
   -- SELECT @StatusCode AS StatusCode, @Message AS Message;
END CATCH

END;
GO


sp_helptext 'usp_Attendance_Mark'

 -- Successful insert (New date)
EXEC usp_Attendance_Mark
    @EmployeeId = 1,
    @AttendanceDate = '2025-08-02',
    @InTime = '09:05',
    @OutTime = '17:30',
    @Status = 'Present';

-- Trying to mark again for the same date (should be blocked)
EXEC usp_Attendance_Mark
    @EmployeeId = 1,
    @AttendanceDate = '2025-08-02',
    @InTime = '09:05',
    @OutTime = '17:30',
    @Status = 'Present';

    GO






---**** Stored Procedure: usp_ApproveLeaveRequest   This stored procedure allows HR/Admin to:Approve or Reject a leave request.Only if the request is currently in Pending stat --Automatically log who updated it and when.
IF OBJECT_ID('usp_LeaveRequest_Approve', 'P') IS NOT NULL
    DROP PROCEDURE usp_LeaveRequest_Approve;
 GO


CREATE PROCEDURE usp_LeaveRequest_Approve
    @LeaveRequestId INT,
    @NewStatus NVARCHAR(20),
    @ApprovedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StatusCode INT = 0;
    DECLARE @Message NVARCHAR(255);


BEGIN TRY
            -- 1 Parameter validation
        IF @LeaveRequestId IS NULL OR @NewStatus IS NULL OR LTRIM(RTRIM(@NewStatus)) =''

        BEGIN
            SET @StatusCode =1;
            SET @Message = 'LeaveRequestId and NewStatus are requried';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Allowed status validation 
    IF @NewStatus NOT IN ('Approved', 'Rejected')
    BEGIN
        SET @StatusCode = 1;
        SET @Message = 'Invailid status.Allowed values: Approved, Rejected.';
        SELECT @StatusCode AS StatusCode, @Message AS Message;
        RETURN;
    END

    -- 2 Check If Leave Exists and is Pending

    IF NOT EXISTS (
            SELECT 1 FROM LeaveRequests
            WHERE LeaveRequestId = @LeaveRequestId AND Status='Pending'
    )
    BEGIN 
        SET @StatusCode = 1;
        SET @Message= 'Leave Not Found  or Already Processed';
        SELECT @StatusCode AS StatusCode , @Message AS Message ;
         RETURN;
    END

    --Begin Trascation 
    --UPDATE THE LEAVE STATUS

    BEGIN TRAN;

    UPDATE  LeaveRequests
        SET Status = @NewStatus,
        ApprovedBy =@ApprovedBy,
        ApprovedDate = GETDATE()
    WHERE LeaveRequestId = @LeaveRequestId;

    -- After the UPDATE

    INSERT INTO AuditLogs(TableName, Action, ChangedBy, Details)
    VALUES (
        'LeaveRequests',
        @NewStatus,
        @ApprovedBy,
        CONCAT('LeaveRequestId=', @LeaveRequestId, ' was ', @NewStatus, ' on ', CONVERT(varchar, GETDATE(), 120))
    );
    COMMIT TRAN;

    --- COMMIT TRAN
    SET @Message =CONCAT('Leave' , @NewStatus, 'Successfully');
    SELECT @Message AS StatusCode, @Message AS Message;
END TRY
BEGIN CATCH
    
      IF XACT_STATE() <> 0 ROLLBACK;
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH

END;
GO

--Approve A Leave 
EXEC usp_LeaveRequest_Approve
    @LeaveRequestId=1,
    @NewStatus='Approved',
    @ApprovedBy='HR Manager';

-- Reject a leave
EXEC usp_LeaveRequest_Approve
    @LeaveRequestId = 2,
    @NewStatus = 'Rejected',
    @ApprovedBy = 'Admin';
       

-- Trying again (already processed)
EXEC usp_LeaveRequest_Approve
    @LeaveRequestId = 1,
    @NewStatus = 'Rejected',
    @ApprovedBy = 'HR';
    GO

    ---CREATE Procedure for Apply Leave 

IF OBJECT_ID('usp_LeaveRequest_Apply', 'P') IS NOT NULL
    DROP PROCEDURE usp_LeaveRequest_Apply;
GO

CREATE PROCEDURE usp_LeaveRequest_Apply
    @EmployeeId INT,
    @FromDate DATE,
    @ToDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StatusCode INT = 0;
    DECLARE @Message NVARCHAR(255);

 BEGIN TRY
        -- 1. Parameter Validation
        IF @EmployeeId IS NULL OR @FromDate IS NULL OR @ToDate IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'EmployeeId, FromDate and ToDate are required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @FromDate > @ToDate
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'FromDate cannot be later than ToDate.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END


           -- 2. Employee existence check
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId AND IsActive = 1)
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid or inactive EmployeeId.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END


    -- Check if overlapping leave already exists

    IF EXISTS (
        SELECT 1 FROM LeaveRequests
        WHERE EmployeeId = @EmployeeId 
          AND Status IN ('Pending', 'Approved')
          AND (
                (@FromDate BETWEEN FromDate AND ToDate) OR
                (@ToDate BETWEEN FromDate AND ToDate) OR
                (FromDate BETWEEN @FromDate AND @ToDate)
              )
    )
    BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Overlapping leave already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
    END;

    -- Insert leave request
    -- 4. Begin & Commit Transaction
  BEGIN TRAN;

    INSERT INTO LeaveRequests (EmployeeId, FromDate, ToDate, Status)
    VALUES (@EmployeeId, @FromDate, @ToDate, 'Pending');

    -- Log action
    INSERT INTO AuditLogs(TableName, Action, ChangedBy, Details)
    VALUES (
        'LeaveRequests', 'INSERT', SYSTEM_USER,
        CONCAT('Leave applied by EmployeeId=', @EmployeeId, 
               ' From ', @FromDate, ' To ', @ToDate)
    );
     COMMIT TRAN;
        SET @Message = 'Leave Request Submitted Successfully.';
        SELECT @StatusCode AS StatusCode, @Message AS Message;
END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- Employee 2 applies for leave
EXEC usp_LeaveRequest_Apply
    @EmployeeId = 2,
    @FromDate = '2025-08-05',
    @ToDate = '2025-08-06';
GO




    ------ CREATE  PROCEDURE usp_CalculateMonthlySalary

    IF OBJECT_ID('usp_Payroll_CalculateMonthlySalary', 'P') IS NOT NULL
    DROP PROCEDURE usp_Payroll_CalculateMonthlySalary;
GO




CREATE PROCEDURE usp_Payroll_CalculateMonthlySalary
    @EmployeeId INT,
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255),

        @WorkingDays INT,
        @PresentDays INT,
        @TotalLeaves INT,
        @LeaveDeductions DECIMAL(10,2),
        @Basic DECIMAL(18,2),
        @HRA DECIMAL(18,2),
        @DA DECIMAL(18,2),
        @Deduct DECIMAL(18,2),
        @PerDaySalary DECIMAL(10,2);

    BEGIN TRY
        -- 1. Parameter validation
        IF @EmployeeId IS NULL OR @Month IS NULL OR @Year IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'EmployeeId, Month, and Year are required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @Month < 1 OR @Month > 12 OR @Year < 2000
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid Month or Year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId AND IsActive = 1)
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid or inactive EmployeeId.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRAN;

        -- 2. Calculate working days excluding weekends/holidays
        ;WITH CalendarDates AS (
            SELECT DATEFROMPARTS(@Year, @Month, 1) AS WorkDate
            UNION ALL
            SELECT DATEADD(DAY, 1, WorkDate)
            FROM CalendarDates
            WHERE MONTH(WorkDate) = @Month AND YEAR(WorkDate) = @Year
                  AND WorkDate < EOMONTH(WorkDate)
        )
        SELECT @WorkingDays = COUNT(*)
        FROM CalendarDates
        WHERE DATENAME(WEEKDAY, WorkDate) NOT IN ('Saturday', 'Sunday')
              AND WorkDate NOT IN (SELECT HolidayDate FROM Holidays)
        OPTION (MAXRECURSION 1000);

        -- 3. Get attendance stats
        SELECT
            @PresentDays = COUNT(CASE WHEN Status = 'Present' THEN 1 END),
            @TotalLeaves = COUNT(CASE WHEN Status = 'Leave' THEN 1 END)
        FROM Attendance
        WHERE EmployeeId = @EmployeeId
              AND MONTH(AttendanceDate) = @Month
              AND YEAR(AttendanceDate) = @Year;

        -- 4. Get salary components
        SELECT
            @Basic = BasicSalary,
            @HRA = HRA,
            @DA = DA,
            @Deduct = Deductions
        FROM Payroll
        WHERE EmployeeId = @EmployeeId
              AND [Month] = @Month
              AND [Year] = @Year;

        IF @Basic IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Payroll entry not found for this employee/month/year.';
            ROLLBACK;
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 5. Calculate leave deductions
        SET @PerDaySalary = @Basic / NULLIF(@WorkingDays, 0);
        SET @LeaveDeductions = ISNULL(@TotalLeaves, 0) * ISNULL(@PerDaySalary, 0);

        -- 6. Update Payroll record
        UPDATE Payroll
        SET WorkingDays = @WorkingDays,
            PresentDays = @PresentDays,
            TotalLeaves = @TotalLeaves,
            LeaveDeductions = @LeaveDeductions,
            Deductions = ISNULL(@Deduct, 0) + ISNULL(@LeaveDeductions, 0)
        WHERE EmployeeId = @EmployeeId
              AND [Month] = @Month
              AND [Year] = @Year;

        -- 7. Audit
        INSERT INTO AuditLogs(TableName, Action, ChangedBy, Details)
        VALUES ('Payroll', 'UPDATE', SYSTEM_USER,
                CONCAT('Salary calculated for EmpId=', @EmployeeId,
                       ' Month=', @Month, ' Year=', @Year));

        COMMIT;

        SET @Message = 'Salary calculation completed successfully.';
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


   EXEC  usp_Payroll_CalculateMonthlySalary
    @EmployeeId = 1,
    @Month = 8,
    @Year = 2025;

  
SELECT * FROM Payroll WHERE EmployeeId = 1;

GO





---Create Usp for Apply for leaves

-- Drop existing if needed
IF OBJECT_ID('usp_ApplyForLeave', 'P') IS NOT NULL
    DROP PROCEDURE usp_ApplyForLeave;
GO

CREATE PROCEDURE usp_ApplyForLeave
        @EmployeeId INT,
        @FromDate DATE,
        @ToDate DATE
AS
BEGIN 
    SET NOCOUNT ON;

    -- Check if overlapping leave already exists
    IF EXISTS (
        SELECT 1 FROM LeaveRequests
        WHERE EmployeeId = @EmployeeId 
          AND Status IN ('Pending', 'Approved')
          AND (
                (@FromDate BETWEEN FromDate AND ToDate) OR
                (@ToDate BETWEEN FromDate AND ToDate) OR
                (FromDate BETWEEN @FromDate AND @ToDate)
              )
    )
    BEGIN
        PRINT 'Overlapping leave already exists!';
        RETURN;
    END;
--InserLeave Request

INSERT INTO LeaveRequests(EmployeeId, FromDate,ToDate,Status)
VALUES (@EmployeeId,@FromDate,@ToDate,'Pending');

--Log Action 
INSERT INTO AuditLogs(TableName,Action,ChangedBy,Details)
VALUES(
'Leave Rquests','INSERT',SYSTEM_USER,CONCAT('Leave Apllied BY EMployeeId=',@EmployeeId,'FRom',@FromDate,'To',@ToDate)
);
 PRINT 'Leave Request Submitted Successfully';
 END;
 GO


 EXEC usp_ApplyForLeave 
 @EmployeeId=2,
 @FromDate='2025-08-05',
 @ToDate='2025-08-06';
 GO



 

----- usp_GetEmployeeMonthlyReport – Get full monthly report of an employee (attendance, leaves, payroll)
IF OBJECT_ID('usp_Employee_GetMonthlyReport', 'P') IS NOT NULL
    DROP PROCEDURE usp_Employee_GetMonthlyReport;
GO

CREATE PROCEDURE usp_Employee_GetMonthlyReport
    @EmployeeId INT,
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255);

    BEGIN TRY
        -- 1. Validate inputs
        IF @EmployeeId IS NULL OR @Month IS NULL OR @Year IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'EmployeeId, Month, and Year are required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @Month < 1 OR @Month > 12 OR @Year < 2000
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid Month or Year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId AND IsActive = 1)
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid or inactive EmployeeId.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 2. Fetch data
        IF NOT EXISTS (
            SELECT 1
            FROM Payroll p
            WHERE p.EmployeeId = @EmployeeId AND p.[Month] = @Month AND p.[Year] = @Year
        )
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'No payroll/attendance data found for the given month/year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 3. Return report
        SELECT
            e.FullName,
            d.Name AS Department,
            r.RoleName,
            p.BasicSalary,
            p.HRA,
            p.DA,
            p.Deductions,
            p.NetSalary,
            p.WorkingDays,
            p.PresentDays,
            p.TotalLeaves,
            p.LeaveDeductions,
            p.GeneratedOn,
            COUNT(a.AttendanceId) AS TotalAttendanceRecords
        FROM Employees e
        JOIN Departments d ON e.DepartmentId = d.DepartmentId
        JOIN Roles r ON e.RoleId = r.RoleId
        LEFT JOIN Payroll p 
            ON e.EmployeeId = p.EmployeeId 
           AND p.[Month] = @Month 
           AND p.[Year] = @Year
        LEFT JOIN Attendance a 
            ON e.EmployeeId = a.EmployeeId
           AND MONTH(a.AttendanceDate) = @Month
           AND YEAR(a.AttendanceDate) = @Year
        WHERE e.EmployeeId = @EmployeeId
        GROUP BY e.FullName, d.Name, r.RoleName, p.BasicSalary, p.HRA, p.DA, p.Deductions, 
                 p.NetSalary, p.WorkingDays, p.PresentDays, p.TotalLeaves, p.LeaveDeductions, 
                 p.GeneratedOn;

        -- 4. Success
        SET @Message = 'Monthly report generated successfully.';
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


EXEC usp_Employee_GetMonthlyReport
    @EmployeeId = 1,
    @Month = 8,
    @Year = 2025;

GO

------- usp_EmployeeLoginAudit – Log employee login activity into AuditLogs.
IF OBJECT_ID('usp_Employee_LoginAudit', 'P') IS NOT NULL
    DROP PROCEDURE usp_Employee_LoginAudit;
GO

CREATE PROCEDURE usp_Employee_LoginAudit
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255),
        @EmpName NVARCHAR(100);

    BEGIN TRY
        -- 1. Validate parameter
        IF @EmployeeId IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'EmployeeId is required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 2. Check if employee exists & is active
        SELECT @EmpName = FullName 
        FROM Employees 
        WHERE EmployeeId = @EmployeeId AND IsActive = 1;

        IF @EmpName IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid or inactive EmployeeId.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 3. Insert login audit record
        INSERT INTO AuditLogs(TableName, Action, ChangedBy, Details)
        VALUES (
            'Employees',
            'LOGIN',
            @EmpName,
            CONCAT('Employee ', @EmpName, ' logged in at ', CONVERT(varchar, GETDATE(), 120))
        );

        -- 4. Success output
        SET @Message = CONCAT('Login recorded for ', @EmpName, '.');
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO



EXEC usp_Employee_LoginAudit @EmployeeId = 1;   -- Should succeed  
EXEC usp_Employee_LoginAudit @EmployeeId = 999; -- Should return "invalid employee"


SELECT * FROM AuditLogs

----usp_BulkInsertAttendance – Insert multiple attendance records at once (using table-valued parameter)


---CREATE TYPE AttendanceTableType AS TABLE    -----SQL Server cannot directly accept “a table” as a parameter unless we define a custom type for it
-- 1️⃣ Create Table Type (only needs to be created once)


CREATE TYPE AttendanceTableType AS TABLE
(
    EmployeeId INT,
    AttendanceDate DATETIME,
    InTime TIME NULL,
    OutTime TIME NULL,
    Status NVARCHAR(20)
);
GO
 

IF OBJECT_ID('usp_Attendance_BulkInsert', 'P') IS NOT NULL
    DROP PROCEDURE usp_Attendance_BulkInsert;
GO

CREATE PROCEDURE usp_Attendance_BulkInsert
    @AttendanceRecords AttendanceTableType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255);

    BEGIN TRY
        -- 1. Empty check
        IF NOT EXISTS (SELECT 1 FROM @AttendanceRecords)
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'No attendance records provided.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 2. Validate Employee IDs
        IF EXISTS (
            SELECT ar.EmployeeId
            FROM @AttendanceRecords ar
            LEFT JOIN Employees e ON e.EmployeeId = ar.EmployeeId AND e.IsActive = 1
            WHERE e.EmployeeId IS NULL
        )
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'One or more attendance records have invalid or inactive EmployeeId.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 3. Prevent duplicates
        IF EXISTS (
            SELECT 1
            FROM @AttendanceRecords ar
            JOIN Attendance a
              ON a.EmployeeId = ar.EmployeeId
             AND a.AttendanceDate = ar.AttendanceDate
        )
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Duplicate attendance entries detected.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 4. Transaction for safety
        BEGIN TRAN;

        INSERT INTO Attendance(EmployeeId, AttendanceDate, InTime, OutTime, Status)
        SELECT EmployeeId, AttendanceDate, InTime, OutTime, Status
        FROM @AttendanceRecords;

        -- 5. Audit log
        INSERT INTO AuditLogs(TableName, Action, ChangedBy, Details)
        VALUES 
        ('Attendance', 'BULK INSERT', SYSTEM_USER, 
         CONCAT('Bulk attendance inserted: ', (SELECT COUNT(*) FROM @AttendanceRecords), ' records'));

        COMMIT;

        -- 6. Success
        SET @Message = CONCAT('Bulk attendance inserted successfully. Count=', (SELECT COUNT(*) FROM @AttendanceRecords));
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


--Declare and populate the table variable
DECLARE @AttTable AS AttendanceTableType;

INSERT INTO @AttTable (EmployeeId, AttendanceDate, InTime, OutTime, Status)
VALUES
(1, '2025-08-03', '09:00', '17:30', 'Present'),
(2, '2025-08-03', '09:15', '17:20', 'Present');

--  Execute the procedure
EXEC  usp_Attendance_BulkInsert @AttendanceRecords = @AttTable;
GO




CREATE OR ALTER PROCEDURE usp_AuditLogs_GetByEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 50
        LogId        AS AuditLogId,  -- maps to DTO property
        TableName,
        Action,
        ChangedBy,
        ChangedOn,
        Details
    FROM AuditLogs
    WHERE ChangedBy = (SELECT FullName FROM Employees WHERE EmployeeId = @EmployeeId)
    ORDER BY LogId DESC;
END


sp_help AuditLogs
SELECT TOP 1 * FROM AuditLogs


---Views--
--- vw_MonthlyAttendanceSummary

IF OBJECT_ID('vw_MonthlyAttendanceSummary', 'V') IS NOT NULL
    DROP VIEW vw_MonthlyAttendanceSummary;
GO

----Views

CREATE VIEW vw_MonthlyAttendanceSummary
AS
SELECT 
    e.EmployeeId,
    e.FullName,
    DATENAME(MONTH, a.AttendanceDate) AS Month,
    MONTH(a.AttendanceDate) AS MonthNumber, 
    YEAR(a.AttendanceDate) AS Year,
    SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS TotalPresent,
    SUM(CASE WHEN a.Status = 'Absent' THEN 1 ELSE 0 END) AS TotalAbsent,
    SUM(CASE WHEN a.Status = 'Leave' THEN 1 ELSE 0 END) AS TotalLeave
FROM Attendance a
INNER JOIN Employees e ON a.EmployeeId = e.EmployeeId
GROUP BY 
    e.EmployeeId, 
    e.FullName, 
    YEAR(a.AttendanceDate), 
    DATENAME(MONTH, a.AttendanceDate),
    MONTH(a.AttendanceDate); -- Added this line to fix the error
GO

SELECT * FROM vw_MonthlyAttendanceSummary;

--- View for vw_EmployeeSalarySlip


CREATE VIEW vw_EmployeeSalarySlip
AS
SELECT 
    p.PayrollId,
    e.EmployeeId,
    e.FullName,
    d.Name AS DEpartmentName,
    p.BasicSalary,
   
    p.Deductions,
    p.NetSalary,
    p.Month,
    p.Year
FROM Payroll p
INNER JOIN Employees e ON p.EmployeeId = e.EmployeeId
INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId;


SELECT * FROM vw_EmployeeSalarySlip;


-------VIEW vw_LeaveRequestDetails


IF OBJECT_ID('vw_LeaveRequestDetails', 'V') IS NOT NULL
    DROP VIEW vw_LeaveRequestDetails;
GO

CREATE VIEW vw_LeaveRequestDetails
AS
SELECT
    lr.LeaveRequestId,
    e.FullName,
    d.Name AS DepartmentName,
    lr.FromDate AS StartDate ,
    lr.ToDate AS EndDate,
    lr.Status,
    lr.ApprovedBy
  
FROM  LeaveRequests lr
INNER JOIN Employees e ON lr.EmployeeId = e.EmployeeId
INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId;
GO

SELECT * FROM vw_LeaveRequestDetails;

GO

-- TRIGGERS

ALTER TRIGGER trg_AfterAttendanceInsert
ON Attendance
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE a
    SET a.Status = 'Late'
    FROM Attendance a
    INNER JOIN inserted i 
        ON a.AttendanceId = i.AttendanceId
    WHERE CAST(i.InTime AS TIME) > '09:15:00'
      AND (i.Status IS NULL OR i.Status = 'Present');
END;
GO



---Test trg  After Attendace Insret 
INSERT INTO Attendance(EmployeeId, AttendanceDate,InTime,OutTime,Status)
VALUES(1,GETDATE(),'10:40','18:00','Present');

-- Check if Status changed to 'Late'
SELECT * FROM Attendance
WHERE EmployeeId = 1
ORDER BY AttendanceId DESC;

GO

---------------

CREATE OR ALTER TRIGGER trg_AfterLeaveUpdate
ON LeaveRequests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
     INSERT INTO AuditLogs(TableName,Action,ChangedBy,Details)
     SELECT
        'LeaveRequests',
        'STATUS UPDATE',
        SYSTEM_USER,
        'LeaveRequestId' + ' '+ CAST(i.LeaveRequestId AS NVARCHAR)+ ' ' +
        'Status Changed From "' + CAST(d.Status AS NVARCHAR(50))+ ' ' +
        '"to"' + CAST (i.Status AS NVARCHAR(50))+ '"'
    FROM inserted i
    INNER JOIN deleted d ON i.LeaveRequestId = d.LeaveRequestId
    WHERE i.Status <> d.Status;
END;
GO

--- Test trigger
INSERT INTO LeaveRequests (EmployeeId, FromDate, ToDate,  Status)
VALUES (1, '2025-08-15', '2025-08-16', 'Pending');
 -- Update its status to Approved (this should trigger AuditLogs insert)

UPDATE LeaveRequests
SET Status='Approved'
WHERE LeaveRequestId =(SELECT TOP 1 LeaveRequestId FROM LeaveRequests ORDER BY LeaveRequestId DESC);

--check the auditlogs

SELECT * FROM AuditLogs 
WHERE TableName = 'LeaveRequests'
ORDER BY LogId  DESC;
GO


--- – User Defined Functions (UDFs)

CREATE FUNCTION ufn_CalculateTotalWorkingDays
(
    @EmployeeId INT,
    @Month INT,
    @Year INT
)
RETURNS INT
AS 
BEGIN 
    DECLARE @TotalDays INT;

    SELECT @TotalDays =COUNT(DISTINCT AttendanceDate)
    FROM Attendance a
    WHERE a.EmployeeId=@EmployeeId
    AND MONTH(a.AttendanceDate)= @Month
    AND YEAR(a.AttendanceDate)=@Year
    AND a.Status ='Present'
    ---ExcludeHoidays

    AND NOT EXISTS(
    SELECT 1 
    FROM Holidays h
    WHERE h.HolidayDate=a.AttendanceDate
    )

    -- Exclude approved leave days by checking if the attendance date falls within any approved leave period
    AND NOT EXISTS(
    SELECT 1
    FROM LeaveRequests lr
    WHERE lr.EmployeeId = @EmployeeId
    AND lr.Status = 'Approved'
   AND a.AttendanceDate BETWEEN lr.FromDate AND  lr.ToDate
   );
RETURN ISNULL(@TotalDays, 0);
END
GO
--Use
SELECT dbo.ufn_CalculateTotalWorkingDays(1, 8, 2025) AS TotalWorkingDays;


--- ANOTHER FUNCTION
CREATE FUNCTION ufn_GetRemainingLeaveBalance
(
@EmployeeId INT,
@Year INT
)
RETURNS INT
AS
BEGIN
    DECLARE @LeaveLimit INT =24;  
    DECLARE @UsedLeaves INT;

    SELECT @UsedLeaves = SUM(DATEDIFF(day,FromDate,ToDate)+1)
    FROM LeaveRequests
    WHERE EmployeeId=@EmployeeId
    AND YEAR(FromDate) =@Year
    AND Status = 'Approved';
RETURN @LeaveLimit -ISNULL(@UsedLeaves,0);
END;
GO

SELECT dbo.ufn_GetRemainingLeaveBalance(1, 2025) AS RemainingLeaves;
GO


------- ANOTHER Function
CREATE FUNCTION ufn_CalculateNetSalary
(
    @EmployeeId INT,
    @Month INT,
    @Year INT
)
RETURNS DECIMAL (10,2)
AS 
BEGIN
    DECLARE @BasicSalary DECIMAL(10,2);
     DECLARE @PerDaySalary DECIMAL(10,2);
      DECLARE @TotalLeaveDaysTakenInMonth  INT;
       DECLARE @NetSalary DECIMAL(10,2);

        -- Define the start and end dates of the target month
    DECLARE @MonthStartDate DATE = DATEFROMPARTS(@Year, @Month, 1);
    DECLARE @MonthEndDate DATE = EOMONTH(@MonthStartDate); -- Gets the last day of the given month


    -- GET BAsic Salary
    SELECT @BasicSalary =BasicSalary
    FROM Payroll
    WHERE EmployeeId =@EmployeeId;

     IF @BasicSalary IS NULL
    BEGIN
        RETURN 0.00;
    END

    --PerdaySalary
    SET @PerDaySalary= @BasicSalary/30.0;


   SELECT @TotalLeaveDaysTakenInMonth = ISNULL(SUM(
        -- Calculate the number of days for the overlapping period
        DATEDIFF(day,
                 
                 CASE WHEN lr.FromDate < @MonthStartDate THEN @MonthStartDate ELSE lr.FromDate END,
                 
                 CASE WHEN lr.ToDate > @MonthEndDate THEN @MonthEndDate ELSE lr.ToDate END
               ) + 1 -- Add 1 to include both start and end dates in the count
    ), 0)

    FROM LeaveRequests lr
    WHERE lr.EmployeeId = @EmployeeId
      AND lr.Status = 'Approved'
      -- Check for any overlap between the leave request period and the target month
      AND lr.FromDate <= @MonthEndDate
      AND lr.ToDate >= @MonthStartDate;

    
    SET @NetSalary = @BasicSalary - (@PerDaySalary * @TotalLeaveDaysTakenInMonth);

   --- 0 if it somehow ends up null
    RETURN ISNULL(@NetSalary, 0.00);
END;
GO

SELECT dbo.ufn_CalculateNetSalary(1, 8, 2025) AS NetSalary;
GO



----------Transaction-Based Stored Procedure for Payroll Generation


IF OBJECT_ID('usp_Payroll_GenerateMonthly', 'P') IS NOT NULL
    DROP PROCEDURE usp_Payroll_GenerateMonthly;
GO

CREATE PROCEDURE usp_Payroll_GenerateMonthly
    @EmployeeId INT,
    @Month INT,
    @Year INT,
    @BasicSalary DECIMAL(10,2),
    @HRA DECIMAL(10,2),
    @DA DECIMAL(10,2),
    @TotalLeaves INT,
    @WorkingDays INT,
    @PresentDays INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255),
        @LeaveDeductions DECIMAL(10,2),
        @DailySalary DECIMAL(10,2);

    BEGIN TRY
        -- 1. Parameter validation
        IF @EmployeeId IS NULL OR @Month IS NULL OR @Year IS NULL

        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'EmployeeId, Month and Year are required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @Month < 1 OR @Month > 12 OR @Year < 2000
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid Month or Year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId AND IsActive = 1)
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid or inactive EmployeeId.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 2. Duplicate payroll check
        IF EXISTS (
            SELECT 1
            FROM Payroll
            WHERE EmployeeId = @EmployeeId
              AND [Month] = @Month
              AND [Year] = @Year
        )
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Payroll already generated for this employee in the given month/year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

       
        -- 3. Salary inputs validation
IF @BasicSalary IS NULL OR @BasicSalary <= 0 
    OR @WorkingDays IS NULL OR @WorkingDays <= 0 
    OR @PresentDays IS NULL OR @PresentDays <= 0
BEGIN
    SET @StatusCode = 1;
    SET @Message = 'BasicSalary, WorkingDays, PresentDays must be provided.';
    SELECT @StatusCode AS StatusCode, @Message AS Message;
    RETURN;
END

        BEGIN TRAN;

        -- 3. Salary computations
        SET @DailySalary = @BasicSalary / NULLIF(@WorkingDays, 0);
        SET @LeaveDeductions = ISNULL(@DailySalary, 0) * ISNULL(@TotalLeaves, 0);

        -- 4. Insert payroll record
        INSERT INTO Payroll(
            EmployeeId, [Month], [Year],
            BasicSalary, HRA, DA,
            Deductions, GeneratedOn,
            TotalLeaves, WorkingDays, PresentDays, LeaveDeductions
        )
        VALUES(
            @EmployeeId, @Month, @Year,
            @BasicSalary, @HRA, @DA,
            @LeaveDeductions, GETDATE(),
            @TotalLeaves, @WorkingDays, @PresentDays, @LeaveDeductions
        );

        -- 5. Audit entry
        INSERT INTO AuditLogs (TableName, Action, ChangedBy, Details)
        VALUES (
            'Payroll',
            'INSERT',
            SYSTEM_USER,
            CONCAT('Payroll generated for EmpId=', @EmployeeId,
                   ' Month=', @Month, ' Year=', @Year,
                   ' Basic=', @BasicSalary, ' Leaves=', @TotalLeaves)
        );

        COMMIT;

        SET @Message = 'Payroll generated successfully.';
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


-- Report Query Using NOLOCK
SELECT 
    p.PayrollId,
    e.FullName AS EmployeeName,
    p.Month,
    p.Year,
    p.BasicSalary,
    p.HRA,
    p.DA,
    p.Deductions,
    p.NetSalary,
    p.GeneratedOn
FROM Payroll p WITH (NOLOCK)
JOIN Employees e WITH (NOLOCK) ON p.EmployeeId = e.EmployeeId
ORDER BY p.GeneratedOn DESC;


EXEC  usp_Payroll_GenerateMonthly
    @EmployeeId = 1,
    @Month = 8,
    @Year = 2025,
    @BasicSalary = 30000,
    @HRA = 5000,
    @DA = 2000,
    @TotalLeaves = 2,
    @WorkingDays = 26,
    @PresentDays = 24;
GO;


------1) Create a Table Type — dbo.EmployeeAttendanceType


CREATE TYPE dbo.EmployeeAttendanceType AS TABLE
(
    EmployeeId INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    InTime TIME NULL,
    OutTime TIME NULL,
    Status NVARCHAR(20) NULL,

   CONSTRAINT PK_EmployeeAttendanceType PRIMARY KEY (EmployeeId, AttendanceDate)
   );
   GO





--   -------- Temp table in stored procedure


--3) Temp Table Example — payroll calculations (#TempSalary)
--Use a temporary table (#TempSalary) inside a stored procedure if you need:

--intermediate, multiple-step processing

--indexing on intermediate results

--repeated joins/aggregations

IF OBJECT_ID('usp_Payroll_BulkGenerateWithTempTable', 'P') IS NOT NULL
    DROP PROCEDURE usp_Payroll_BulkGenerateWithTempTable;
GO

CREATE PROCEDURE usp_Payroll_BulkGenerateWithTempTable
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255);

    BEGIN TRY
        -- 1. Parameter validation
        IF @Month IS NULL OR @Year IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Month and Year are required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @Month < 1 OR @Month > 12 OR @Year < 2000
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid Month or Year provided.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRAN;

        -- 2. Create temp table for intermediate calculations
        CREATE TABLE #TempSalary (
            EmployeeId INT PRIMARY KEY,
            WorkingDays INT DEFAULT 0,
            PresentDays INT DEFAULT 0,
            TotalLeaves INT DEFAULT 0,
            BasicSalary DECIMAL(18,2) DEFAULT 0,
            HRA DECIMAL(18,2) DEFAULT 0,
            DA DECIMAL(18,2) DEFAULT 0,
            ExistingDeductions DECIMAL(18,2) DEFAULT 0,
            LeaveDeductions DECIMAL(18,2) DEFAULT 0,
            NetPay DECIMAL(18,2) DEFAULT 0
        );

        -- 3. Populate temp table with attendance & payroll aggregation
        INSERT INTO #TempSalary (EmployeeId, WorkingDays, PresentDays, TotalLeaves, BasicSalary, HRA, DA, ExistingDeductions)
        SELECT
            e.EmployeeId,
            COUNT(a.AttendanceDate) AS WorkingDays,
            SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS PresentDays,
            SUM(CASE WHEN a.Status = 'Leave' THEN 1 ELSE 0 END) AS TotalLeaves,
            ISNULL(MAX(p.BasicSalary), 30000) AS BasicSalary,
            ISNULL(MAX(p.HRA), 0) AS HRA,
            ISNULL(MAX(p.DA), 0) AS DA,
            ISNULL(MAX(p.Deductions), 0) AS ExistingDeductions
        FROM Employees e
        LEFT JOIN Attendance a 
               ON e.EmployeeId = a.EmployeeId 
              AND MONTH(a.AttendanceDate) = @Month 
              AND YEAR(a.AttendanceDate) = @Year
        LEFT JOIN Payroll p 
               ON p.EmployeeId = e.EmployeeId 
              AND p.[Month] = @Month 
              AND p.[Year] = @Year
        WHERE e.IsActive = 1
        GROUP BY e.EmployeeId;

        -- Add index for faster joins if needed
        CREATE NONCLUSTERED INDEX IX_TempSalary_EmployeeId ON #TempSalary(EmployeeId);

        -- 4. Compute leave deductions and net pay
        UPDATE #TempSalary
        SET LeaveDeductions = TotalLeaves * 500.00,
            NetPay = (BasicSalary + HRA + DA) - (ExistingDeductions + (TotalLeaves * 500.00));

        -- 5. Update existing payroll records
        UPDATE p
        SET p.WorkingDays = t.WorkingDays,
            p.PresentDays = t.PresentDays,
            p.TotalLeaves = t.TotalLeaves,
            p.LeaveDeductions = t.LeaveDeductions,
            p.Deductions = t.ExistingDeductions + t.LeaveDeductions,
            p.BasicSalary = t.BasicSalary,
            p.HRA = t.HRA,
            p.DA = t.DA,
            p.GeneratedOn = GETDATE()
        FROM Payroll p
        INNER JOIN #TempSalary t 
                ON p.EmployeeId = t.EmployeeId
        WHERE p.[Month] = @Month AND p.[Year] = @Year;

        -- 6. Insert new payroll rows for missing entries
        INSERT INTO Payroll (EmployeeId, [Month], [Year], BasicSalary, HRA, DA, Deductions, TotalLeaves, WorkingDays, PresentDays, LeaveDeductions, GeneratedOn)
        SELECT t.EmployeeId, @Month, @Year, t.BasicSalary, t.HRA, t.DA, 
               (t.ExistingDeductions + t.LeaveDeductions),
               t.TotalLeaves, t.WorkingDays, t.PresentDays, t.LeaveDeductions, GETDATE()
        FROM #TempSalary t
        WHERE NOT EXISTS (
            SELECT 1 FROM Payroll p WHERE p.EmployeeId = t.EmployeeId AND p.[Month] = @Month AND p.[Year] = @Year
        );

        -- 7. Audit logging
        INSERT INTO AuditLogs(TableName, Action, ChangedBy, Details)
        VALUES ('Payroll', 'BULK_GENERATE', SYSTEM_USER, CONCAT('Bulk payroll generated for ', @Month, '/', @Year));

        COMMIT;

        -- 8. Success message
        SET @Message = CONCAT('Bulk payroll generation completed for ', @Month, '/', @Year, '.');
        SELECT @StatusCode AS StatusCode, @Message AS Message;

        -- OPTIONAL: return computed results
        SELECT * FROM #TempSalary;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO



EXEC usp_Payroll_BulkGenerateWithTempTable @Month = 8, @Year = 2025;

-- Then inspect Payroll rows:
SELECT TOP 50 * FROM Payroll WHERE [Month] = 8 AND [Year] = 2025;

GO



--*******___


----  Table Variable Example — small set processing inside a proc
-----usp_GetPerfectAttendanceEmployees 

IF OBJECT_ID('usp_Attendance_GetPerfectEmployees', 'P') IS NOT NULL
    DROP PROCEDURE usp_Attendance_GetPerfectEmployees;
GO

CREATE PROCEDURE usp_Attendance_GetPerfectEmployees
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @StatusCode INT = 0,
        @Message NVARCHAR(255);

    BEGIN TRY
        -- 1. Validate inputs
        IF @Month IS NULL OR @Year IS NULL
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Month and Year are required.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @Month < 1 OR @Month > 12 OR @Year < 2000
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'Invalid Month or Year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 2. Table variable for intermediate aggregates
        DECLARE @Perf TABLE (
            EmployeeId INT PRIMARY KEY,
            WorkingDays INT,
            PresentDays INT
        );

        INSERT INTO @Perf(EmployeeId, WorkingDays, PresentDays)
        SELECT
            e.EmployeeId,
            COUNT(a.AttendanceDate) AS WorkingDays,
            SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS PresentDays
        FROM Employees e
        LEFT JOIN Attendance a 
               ON e.EmployeeId = a.EmployeeId
              AND MONTH(a.AttendanceDate) = @Month
              AND YEAR(a.AttendanceDate) = @Year
        WHERE e.IsActive = 1
        GROUP BY e.EmployeeId
        HAVING COUNT(a.AttendanceDate) > 0;  -- exclude employees with no records

        -- 3. Check if any perfect attendance exists
        IF NOT EXISTS (SELECT 1 FROM @Perf WHERE PresentDays = WorkingDays)
        BEGIN
            SET @StatusCode = 1;
            SET @Message = 'No employees found with perfect attendance for the given period.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- 4. Return perfect attendance list
        SELECT 
            p.EmployeeId,
            e.FullName,
            d.Name AS Department,
            p.WorkingDays,
            p.PresentDays
        FROM @Perf p
        INNER JOIN Employees e ON e.EmployeeId = p.EmployeeId
        LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId
        WHERE p.PresentDays = p.WorkingDays;

        -- 5. Final success message
        SET @Message = CONCAT('Perfect attendance list generated for ', @Month, '/', @Year, '.');
        SELECT @StatusCode AS StatusCode, @Message AS Message;

    END TRY
    BEGIN CATCH
        SET @StatusCode = -1;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO



---=========INDEXES=======-------

-- 1) Attendance: filter by Employee + Month/Year (via AttendanceDate)

CREATE NONCLUSTERED INDEX IX_Attendance_EmployeeId_AttendanceDate
ON dbo.Attendance (EmployeeId, AttendanceDate)
INCLUDE(Status, Intime, OutTime);
GO
--  test Attendance for a month
SELECT a.*
FROM dbo.Attendance a
WHERE a.EmployeeId =1
    AND a.AttendanceDate BETWEEN '2025-08-01' AND '2025-08-31';

---2 Payroll find/update by Employee + Year + Month
CREATE NONCLUSTERED INDEX IX_Payroll_Employee_Year_Month
ON dbo.Payroll (EmployeeId, [Year],[Month])
INCLUDE (BasicSalary,HRA, DA, Deductions, NetSalary,WorkingDays,TotalLeaves, Leavedeductions, GeneratedOn);

---3 LEAVE REQUESTS APPROVAL + OVERLAPS CHCEK
----for approval dashboard  fast lookup of pending requests
CREATE NONCLUSTERED INDEX IX_LeaveRequests_Pending
ON dbo.LeaveRequests (EmployeeId, FromDate, ToDate)
WHERE Status = 'Pending';

-- for overlap checks across Approved/Pending
CREATE NONCLUSTERED INDEX IX_LeaveRequests_Emp_Status_From_To
ON dbo.LeaveRequests (EmployeeId, Status, FromDate,ToDate)
INCLUDE (ApprovedBy, ApprovedDate);

---- 4 Holidays Used in working day month
CREATE NONCLUSTERED INDEX IX_Holidays_HolidayDate
ON dbo.Holidays(HolidayDate);

--5 Foreign Key helper indexers (join speed)
-- atttendance -> Employees
CREATE NONCLUSTERED INDEX IX_Attendance_EmployeeId ON dbo.Attendance(EmployeeId);

--LeaveRequests -> Employees
CREATE NONCLUSTERED INDEX IX_Attendance_EmployeeId ON dbo.LeaveRequests (EmployeeId);

--Employees -> Departments, Roles(for views / reports)
CREATE NONCLUSTERED INDEX IX_Employees_DepartmentId ON dbo.Employees(DepartmentId);
CREATE NONCLUSTERED INDEX IX_Employees_RoleId ON dbo.Employees(RoleId);

-- SalaryComponents -> Payroll
CREATE NONCLUSTERED INDEX IX_SalaryComponents_PayrollId ON dbo.SalaryComponents (PayrollId);


--- AuditLogs
CREATE NONCLUSTERED INDEX IX_AuditLogs_TableName_ChangedOn
ON dbo.AuditLogs (TableName, ChangedOn);
GO

-- — Test that indexes are being used
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Press Ctrl+M in SSMS to include Actual Execution Plan

--  Attendance for a month
SELECT a.*
FROM dbo.Attendance a
WHERE a.EmployeeId = 1
  AND a.AttendanceDate BETWEEN '2025-08-01' AND '2025-08-31';

--  Payroll fetch for a month
SELECT p.*
FROM dbo.Payroll p
WHERE p.EmployeeId = 1 AND p.[Year] = 2025 AND p.[Month] = 8;

--  Pending leaves dashboard
SELECT lr.*
FROM dbo.LeaveRequests lr
WHERE lr.Status = 'Pending' AND lr.EmployeeId = 2;

-- Check if employee 1 has leave (approved or pending) overlapping given dates
SELECT *
FROM dbo.LeaveRequests
WHERE EmployeeId = 1
  AND Status IN ('Approved', 'Pending')
  AND FromDate <= '2025-08-15'
  AND ToDate >= '2025-08-10';

-- Get holidays in August 2025
SELECT *
FROM dbo.Holidays
WHERE HolidayDate BETWEEN '2025-08-01' AND '2025-08-31';

-- Foreign Key helper indexes

SELECT e.EmployeeId, e.FullName, a.AttendanceDate, a.Status
FROM dbo.Employees e
JOIN dbo.Attendance a ON e.EmployeeId = a.EmployeeId
WHERE e.EmployeeId = 1
  AND a.AttendanceDate BETWEEN '2025-08-01' AND '2025-08-31';



  SELECT EmployeeId, AttendanceDate, Status, InTime, OutTime
FROM dbo.Attendance
WHERE EmployeeId = 1
  AND AttendanceDate BETWEEN '2025-08-01' AND '2025-08-31';

