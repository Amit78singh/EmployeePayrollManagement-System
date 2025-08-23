# Employee Payroll API

A comprehensive .NET 8 Web API for employee payroll management with authentication, attendance tracking, leave management, and payroll processing.

## Features

- **Authentication & Authorization** using JWT tokens and ASP.NET Core Identity
- **Employee Management** (CRUD operations)
- **Attendance Tracking** (mark attendance, bulk insert, monthly summaries)
- **Leave Management** (apply, approve, track leave requests)
- **Payroll Processing** (salary calculations, components)
- **Audit Logging** for tracking changes
- **Database Integration** using Entity Framework Core and Dapper

## Prerequisites

- .NET 8.0 SDK
- SQL Server
- Visual Studio 2022 or VS Code

## Setup Instructions

### 1. Environment Configuration

Create environment variables or update `appsettings.Development.json`:

```bash
# Database Connection
EMPLOYEE_DB_CONNECTION=Server=YOUR_SERVER;Database=EmployeePayRollDB;Trusted_Connection=True;TrustServerCertificate=True;

# JWT Secret Key (IMPORTANT: Use a strong, unique key in production)
JWT_SECRET_KEY=YourSuperSecretKeyHere1234567891234567890!
```

### 2. Database Setup

1. Ensure SQL Server is running
2. Update connection string in `appsettings.json` or set environment variable
3. Run Entity Framework migrations:
   ```bash
   dotnet ef database update
   ```

### 3. Run the Application

```bash
dotnet run
```

The API will be available at `https://localhost:7108`

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Attendance
- `POST /api/attendance/mark` - Mark individual attendance
- `POST /api/attendance/bulkInsert` - Bulk insert attendance records
- `GET /api/attendance/summary/{month}/{year}` - Monthly attendance summary

### Employees
- `GET /api/employees` - Get all employees
- `POST /api/employees` - Create new employee
- `PUT /api/employees/{id}` - Update employee
- `DELETE /api/employees/{id}` - Delete employee

### Leave Management
- `POST /api/leave/apply` - Apply for leave
- `POST /api/leave/approve` - Approve/reject leave
- `GET /api/leave/requests` - Get leave requests

### Payroll
- `GET /api/payroll/calculate` - Calculate payroll
- `GET /api/payroll/employee/{id}` - Get employee payroll

## Security Notes

- JWT secret key should be stored in environment variables, not in source code
- Use strong, unique keys in production
- Connection strings should be secured in production environments
- Consider using Azure Key Vault or similar services for production secrets

## Architecture

- **Controllers**: Handle HTTP requests and responses
- **Services**: Business logic implementation
- **Repositories**: Data access layer using Repository pattern
- **Models**: Entity models and DTOs
- **Data**: Entity Framework context and database configuration
- **Middleware**: Custom middleware for error handling

## Dependencies

- Microsoft.AspNetCore.Authentication.JwtBearer
- Microsoft.AspNetCore.Identity.EntityFrameworkCore
- Microsoft.EntityFrameworkCore.SqlServer
- Dapper (for performance-critical queries)
- Swashbuckle.AspNetCore (Swagger/OpenAPI)

## Development

- Swagger UI available at `/swagger` in development
- Error handling middleware for consistent error responses
- Comprehensive input validation
- Exception handling throughout the application
