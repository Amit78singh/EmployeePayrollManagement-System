# How to Start Your Employee Payroll System

## Backend API (Required First)

### Method 1: Visual Studio (Recommended)
1. Open `EmployeePayrollAPI.sln` in Visual Studio
2. Set `EmployeePayrollAPI` as startup project
3. Press **F5** or **Ctrl+F5**
4. Backend will start on https://localhost:7108

### Method 2: Command Line Alternative
```cmd
cd EmployeePayrollAPI
dotnet build
dotnet bin\Debug\net8.0\EmployeePayrollAPI.dll --urls "https://localhost:7108"
```

## Frontend (Start After Backend)

```cmd
cd FrontEnd_Employe_Payroll\RecipeSage
npm install
ng serve
```

Frontend will be available at: http://localhost:4200

## Verify System is Working

1. **Backend Check**: Visit https://localhost:7108/swagger
2. **Frontend Check**: Visit http://localhost:4200
3. **Login**: Use admin@test.com / password123

## What You'll See (Real Data)

✅ **Dashboard**: Real employee count, salary totals, attendance, leave data
✅ **Employees**: Real employee records from your database
✅ **Attendance**: Real attendance tracking
✅ **Leave**: Real leave requests and approvals
✅ **Payroll**: Real payroll calculations

## No More Mock Data
All components now use real database data through API calls. No fallback to dummy data.

## If Backend Won't Start
- Kill all dotnet processes: `taskkill /F /IM dotnet.exe`
- Use Visual Studio instead of command line
- Check SQL Server is running: DESKTOP-9D5S73E\SQLEXPRESS
