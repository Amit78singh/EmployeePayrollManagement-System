# PowerShell script to start the .NET Core backend
Write-Host "Starting EmployeePayrollAPI Backend..." -ForegroundColor Green

# Change to the backend directory
Set-Location -Path "EmployeePayrollAPI"

# Start the backend
dotnet run --urls "https://localhost:7108"

Write-Host "Backend started successfully!" -ForegroundColor Green
