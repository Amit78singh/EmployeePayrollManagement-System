@echo off
echo Killing existing dotnet processes...
taskkill /F /IM dotnet.exe 2>nul

echo Starting Employee Payroll API...
cd EmployeePayrollAPI
dotnet run --urls "https://localhost:7108"
pause
