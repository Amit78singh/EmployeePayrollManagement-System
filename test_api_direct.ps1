# Test API Endpoints Directly
Write-Host "Testing Employee Payroll API Endpoints..." -ForegroundColor Green

# Test Employees endpoint
Write-Host "`nTesting /api/employees..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7108/api/employees" -Method GET -SkipCertificateCheck
    Write-Host "✓ Employees API working - Found $($response.Count) employees" -ForegroundColor Green
    $response | Select-Object -First 3 | Format-Table EmployeeId, FullName, Email, Salary
} catch {
    Write-Host "✗ Employees API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Leave endpoint
Write-Host "`nTesting /api/leave..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7108/api/leave" -Method GET -SkipCertificateCheck
    Write-Host "✓ Leave API working - Found $($response.Count) leave requests" -ForegroundColor Green
} catch {
    Write-Host "✗ Leave API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Payroll endpoint
Write-Host "`nTesting /api/payroll..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7108/api/payroll" -Method GET -SkipCertificateCheck
    Write-Host "✓ Payroll API working - Found $($response.Count) payroll records" -ForegroundColor Green
} catch {
    Write-Host "✗ Payroll API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Attendance endpoint
Write-Host "`nTesting /api/attendance/employee/1..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7108/api/attendance/employee/1" -Method GET -SkipCertificateCheck
    Write-Host "✓ Attendance API working - Found $($response.Count) attendance records" -ForegroundColor Green
} catch {
    Write-Host "✗ Attendance API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Audit endpoint
Write-Host "`nTesting /api/audit/1..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7108/api/audit/1" -Method GET -SkipCertificateCheck
    Write-Host "✓ Audit API working - Found $($response.Count) audit logs" -ForegroundColor Green
} catch {
    Write-Host "✗ Audit API failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI Testing Complete!" -ForegroundColor Green
