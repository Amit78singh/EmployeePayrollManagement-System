# Employee Payroll System - Build & Test Guide

## Critical Fixes Applied

### Backend (.NET API) - Fixed Issues:
✅ **Entity Framework Version Compatibility**: Downgraded EF Core from 9.0.8 to 8.0.8 to match ASP.NET Identity 8.0.8
✅ **DateTime vs DateOnly Consistency**: Fixed all DTOs to use `DateOnly` matching database schema
✅ **Nullable Property Warnings**: Added proper string initialization (`= string.Empty`)
✅ **Database Seeding**: Enabled automatic seeding in Program.cs
✅ **DateOnly Conversion**: Fixed LeaveRepository to properly convert DateOnly to DateTime for stored procedures

### Frontend (Angular) - Configuration Verified:
✅ **Environment Configuration**: API URL correctly set to `https://localhost:7108/api`
✅ **Angular Version**: Using Angular 20.2.x with standalone components
✅ **TypeScript Configuration**: Proper strict mode settings
✅ **Service Integration**: All services configured with proper error handling and mock fallbacks

## Build Instructions

### 1. Backend API (.NET 8)
```powershell
# Navigate to API project
cd "c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\EmployeePayrollAPI"

# Restore packages (should be fast now with fixed versions)
dotnet restore

# Build the project
dotnet build --configuration Release

# Run the API (will start on https://localhost:7108)
dotnet run --urls "https://localhost:7108"
```

### 2. Frontend (Angular)
```powershell
# Navigate to Angular project
cd "c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\FrontEnd_Employe_Payroll\RecipeSage"

# Install dependencies
npm install

# Start development server (will start on http://localhost:4200)
npm start
```

### 3. Database Setup
```sql
-- Run this in SQL Server Management Studio
-- Execute the Database_Schema.sql file to create the database and tables
-- File location: c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\Database_Schema.sql
```

## Testing Endpoints

### Authentication Endpoints:
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login user

### Employee Management:
- GET `/api/employees` - Get all employees
- POST `/api/employees` - Create employee
- PUT `/api/employees/{id}` - Update employee
- DELETE `/api/employees/{id}` - Delete employee

### Attendance Management:
- GET `/api/attendance/employee/{employeeId}` - Get employee attendance
- POST `/api/attendance` - Mark attendance

### Leave Management:
- POST `/api/leave/apply` - Apply for leave
- POST `/api/leave/approve` - Approve/reject leave
- GET `/api/leave` - Get leave requests

### Payroll Management:
- POST `/api/payroll/calculate` - Calculate salary
- POST `/api/payroll/generate` - Generate monthly payroll
- GET `/api/payroll/slip/{employeeId}/{year}/{month}` - Get payslip

## Default Test Users (Created by Seeding)
- **Admin**: admin@test.com / Password123
- **HR**: hr@test.com / Password123  
- **Employee**: employee@test.com / Password123

## Troubleshooting

### If Backend Build Fails:
1. Check SQL Server connection string in appsettings.json
2. Ensure SQL Server is running
3. Verify database exists (run Database_Schema.sql)

### If Frontend Build Fails:
1. Delete node_modules folder
2. Run `npm install` again
3. Check Angular CLI version: `ng version`

### If API Connection Fails:
1. Verify backend is running on https://localhost:7108
2. Check CORS settings in Program.cs
3. Ensure SSL certificate is trusted

## Architecture Overview

**Backend Stack:**
- .NET 8 Web API
- Entity Framework Core 8.0.8
- SQL Server Database
- JWT Authentication
- Dapper for performance-critical queries
- Repository Pattern

**Frontend Stack:**
- Angular 20.2.x
- Angular Material UI
- Standalone Components
- RxJS for reactive programming
- JWT-based authentication

**Database:**
- SQL Server with comprehensive schema
- Stored procedures for complex operations
- Auto-increment primary keys
- Audit triggers for data tracking
