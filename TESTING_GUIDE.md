# Employee Payroll System - Complete Testing Guide

## 🚀 System Status
✅ Backend API: Fixed and ready (all CRUD endpoints implemented)
✅ Frontend: Angular development server running on http://localhost:4200
✅ Database: Schema updated with missing stored procedures
✅ Authentication: JWT-based with seeded test users

## 📋 Pre-Testing Checklist

### 1. Database Setup
**CRITICAL**: Run the updated `Database_Schema.sql` in SQL Server Management Studio first!
- Location: `c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\Database_Schema.sql`
- This adds the missing stored procedures: `usp_Employee_Delete` and `usp_Employee_GetById`

### 2. Backend API
```powershell
cd "c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\EmployeePayrollAPI"
dotnet run --urls "https://localhost:7108"
```
**Expected**: API starts on https://localhost:7108 with Swagger UI available

### 3. Frontend Angular App
```powershell
cd "c:\Users\MT010\source\repos\CORE\EmployeePayrollAPI\FrontEnd_Employe_Payroll\RecipeSage"
npm start
```
**Expected**: Angular dev server starts on http://localhost:4200

## 🧪 Testing Scenarios

### Authentication Testing
**Test Users** (auto-created by seeding):
- **admin@test.com** / Password123 (Admin role)
- **hr@test.com** / Password123 (HR role)
- **employee@test.com** / Password123 (Employee role)

**Test Steps**:
1. Navigate to http://localhost:4200
2. Login with any test user
3. Verify JWT token is stored and user is authenticated
4. Check role-based access controls

### Employee CRUD Operations Testing

#### ✅ CREATE Employee
**Steps**:
1. Click "Add Employee" button
2. Fill form with:
   - Full Name: "Test Employee"
   - Email: "test@company.com"
   - Phone: "1234567890"
   - Gender: "M" or "F"
   - Join Date: Select date
   - Department: Select from dropdown
   - Role: Select from dropdown
   - Salary: Enter amount
3. Click "Save"

**Expected Result**: 
- Employee created in database
- Success message displayed
- Employee appears in list immediately
- No more dummy/mock data

#### ✅ READ Employees
**Steps**:
1. Navigate to Employee Management
2. View employee list

**Expected Result**:
- Real employees from database (not dummy data)
- All employee details displayed correctly
- Department and role names resolved
- Salary amounts in INR (₹)

#### ✅ UPDATE Employee
**Steps**:
1. Click edit icon (pencil) on any employee
2. Modify any field (name, phone, salary, etc.)
3. Click "Update"

**Expected Result**:
- Changes saved to database
- Updated data reflected immediately
- Success message displayed

#### ✅ DELETE Employee
**Steps**:
1. Click delete icon (trash) on any employee
2. Confirm deletion

**Expected Result**:
- Employee soft-deleted (IsActive = 0)
- Employee removed from active list
- Success message displayed
- No "Failed to delete" errors

### Salary & Payroll Testing

#### Fix Salary Display Issues
**Current Problem**: "₹N/A", "₹undefined" in salary preview

**Test Steps**:
1. Create employee with valid salary amount
2. Navigate to Payroll section
3. View salary calculations

**Expected Result**:
- Proper salary amounts displayed
- Calculations work correctly
- No "undefined" values

### API Endpoint Testing

#### Direct API Testing (Optional)
Use Swagger UI at https://localhost:7108/swagger or test with curl:

```bash
# Get all employees
curl -X GET "https://localhost:7108/api/employees" -H "accept: application/json"

# Create employee
curl -X POST "https://localhost:7108/api/employees" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "API Test User",
    "email": "apitest@company.com",
    "phone": "9876543210",
    "gender": "M",
    "joinDate": "2024-01-15",
    "departmentId": 1,
    "roleId": 1,
    "salary": 50000
  }'
```

## 🐛 Troubleshooting

### If Employee List Shows Dummy Data
**Problem**: Frontend falling back to mock data
**Solution**: 
1. Check browser console for API errors
2. Verify backend is running on https://localhost:7108
3. Check CORS settings
4. Ensure database connection is working

### If CRUD Operations Fail
**Problem**: Missing stored procedures or API endpoints
**Solution**:
1. Re-run updated `Database_Schema.sql`
2. Restart backend API
3. Check SQL Server connection string in `appsettings.json`

### If Salary Shows "undefined"
**Problem**: Missing or null salary data
**Solution**:
1. Ensure employees have valid salary values
2. Check payroll calculation logic
3. Verify database schema has salary columns

### If Authentication Fails
**Problem**: JWT or seeding issues
**Solution**:
1. Check if database seeding completed successfully
2. Verify JWT settings in `appsettings.json`
3. Clear browser localStorage and retry

## 📊 Success Criteria

### ✅ System is Working When:
- [ ] Login works with test users
- [ ] Employee list shows real data (not dummy)
- [ ] Create employee saves to database
- [ ] Edit employee updates database
- [ ] Delete employee works (soft delete)
- [ ] Salary calculations display correctly
- [ ] No "Failed to delete" errors
- [ ] No "₹undefined" in salary displays
- [ ] All API endpoints respond correctly

### 🎯 Performance Expectations
- Employee list loads in < 2 seconds
- CRUD operations complete in < 1 second
- No console errors in browser
- Smooth navigation between pages

## 🔧 Next Steps After Testing

1. **If all tests pass**: System is production-ready
2. **If issues remain**: Check specific error messages and refer to troubleshooting section
3. **For deployment**: Configure production database connection strings and build for production

## 📞 Support Information

**Key Files Modified**:
- `EmployeesController.cs` - Added DELETE and GetById endpoints
- `EmployeeRepository.cs` - Added missing repository methods
- `employee.service.ts` - Removed mock data fallbacks
- `Database_Schema.sql` - Added missing stored procedures
- `SeedData.cs` - Fixed seeding functionality

**Database Stored Procedures Added**:
- `usp_Employee_Delete` - Soft delete functionality
- `usp_Employee_GetById` - Get single employee details
