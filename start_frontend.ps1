# PowerShell script to start the Angular frontend
Write-Host "Starting Angular Frontend..." -ForegroundColor Green

# Change to the frontend directory
Set-Location -Path "FrontEnd_Employe_Payroll/RecipeSage"

# Check if node_modules exists, if not install dependencies
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Start the frontend
Write-Host "Starting Angular development server..." -ForegroundColor Green
npm start

Write-Host "Frontend started successfully!" -ForegroundColor Green
