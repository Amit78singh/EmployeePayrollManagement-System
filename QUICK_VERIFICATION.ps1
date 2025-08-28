# Quick Build Verification Script
# This script checks if the project can build without running long commands

Write-Host "=== Employee Payroll System - Quick Verification ===" -ForegroundColor Green

# Check .NET version
Write-Host "`n1. Checking .NET version..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "   ✓ .NET Version: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ .NET not found or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if SQL Server is accessible
Write-Host "`n2. Checking SQL Server connection..." -ForegroundColor Yellow
$connectionString = "Server=DESKTOP-9D5S73E\SQLEXPRESS;Database=master;Trusted_Connection=True;TrustServerCertificate=True;"
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    $connection.Close()
    Write-Host "   ✓ SQL Server is accessible" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ SQL Server connection issue: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   → Make sure SQL Server is running and connection string is correct" -ForegroundColor Cyan
}

# Check project files exist
Write-Host "`n3. Checking project structure..." -ForegroundColor Yellow
$backendPath = "c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\EmployeePayrollAPI\EmployeePayrollAPI.csproj"
$frontendPath = "c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\FrontEnd_Employe_Payroll\RecipeSage\package.json"

if (Test-Path $backendPath) {
    Write-Host "   ✓ Backend project file found" -ForegroundColor Green
} else {
    Write-Host "   ✗ Backend project file missing" -ForegroundColor Red
}

if (Test-Path $frontendPath) {
    Write-Host "   ✓ Frontend project file found" -ForegroundColor Green
} else {
    Write-Host "   ✗ Frontend project file missing" -ForegroundColor Red
}

# Check Node.js for frontend
Write-Host "`n4. Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "   ✓ Node.js Version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Node.js not found - needed for Angular frontend" -ForegroundColor Red
}

Write-Host "`n=== Verification Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: dotnet restore (in backend folder)" -ForegroundColor White
Write-Host "2. Run: dotnet build (in backend folder)" -ForegroundColor White
Write-Host "3. Run: npm install (in frontend folder)" -ForegroundColor White
Write-Host "4. Execute Database_Schema.sql in SQL Server" -ForegroundColor White
Write-Host "5. Start backend: dotnet run --urls https://localhost:7108" -ForegroundColor White
Write-Host "6. Start frontend: npm start" -ForegroundColor White
