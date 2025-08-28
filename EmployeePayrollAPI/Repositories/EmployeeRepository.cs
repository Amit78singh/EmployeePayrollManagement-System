using Dapper;
using EmployeePayrollAPI.Infrastructure;
using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public class EmployeeRepository:IEmployeeRepository
    {
        private readonly IDbConnectionFactory _db;

        public EmployeeRepository(IDbConnectionFactory db)
        {
            _db = db;
        }

        public async Task<IEnumerable<dynamic>> GetAllAsync()
        {
            using var conn = _db.CreateConnection();
            return await conn.QueryAsync(@"
                SELECT 
                    e.EmployeeId,
                    e.FullName,
                    e.Email,
                    e.Phone,
                    e.Gender,
                    e.JoinDate,
                    e.DepartmentId,
                    d.Name AS DepartmentName,
                    e.RoleId,
                    r.RoleName,
                    e.Salary,
                    e.IsActive
                FROM Employees e
                LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId
                LEFT JOIN Roles r ON e.RoleId = r.RoleId
                WHERE e.IsActive = 1");
        }

        public async Task<int> CreateAsync(Models.DTOs.EmployeeCreateDto dto)
        {
            using var conn = _db.CreateConnection();
            return await conn.ExecuteScalarAsync<int>(@"
                INSERT INTO Employees (FullName, Email, Phone, Gender, JoinDate, DepartmentId, RoleId, Salary, IsActive)
                VALUES (@FullName, @Email, @Phone, @Gender, @JoinDate, @DepartmentId, @RoleId, @Salary, 1);
                SELECT CAST(SCOPE_IDENTITY() as int);", 
                new { 
                    FullName = dto.FullName,
                    Email = dto.Email,
                    Phone = dto.Phone,
                    Gender = dto.Gender,
                    JoinDate = dto.JoinDate.ToDateTime(TimeOnly.MinValue),
                    DepartmentId = dto.DepartmentId,
                    RoleId = dto.RoleId,
                    Salary = dto.Salary
                });
        }

       public async Task UpdateAsync(int id, EmployeeUpdateDto dto)
        {
            using var conn = _db.CreateConnection();
            await conn.ExecuteAsync(@"
                UPDATE Employees 
                SET FullName = @FullName, 
                    Phone = @Phone, 
                    Gender = @Gender, 
                    JoinDate = @JoinDate, 
                    DepartmentId = @DepartmentId, 
                    RoleId = @RoleId, 
                    Salary = @Salary,
                    IsActive = @IsActive
                WHERE EmployeeId = @EmployeeId", 
                new {
                    EmployeeId = id,
                    FullName = dto.FullName,
                    Phone = dto.Phone,
                    Gender = dto.Gender,
                    JoinDate = dto.JoinDate.ToDateTime(TimeOnly.MinValue),
                    DepartmentId = dto.DepartmentId,
                    RoleId = dto.RoleId,
                    Salary = dto.Salary,
                    IsActive = dto.IsActive
                });
        }

        public async Task DeleteAsync(int id)
        {
            using var conn = _db.CreateConnection();
            await conn.ExecuteAsync("UPDATE Employees SET IsActive = 0 WHERE EmployeeId = @EmployeeId", new { EmployeeId = id });
        }

        public async Task<dynamic?> GetByIdAsync(int id)
        {
            using var conn = _db.CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<dynamic>(@"
                SELECT 
                    e.EmployeeId,
                    e.FullName,
                    e.Email,
                    e.Phone,
                    e.Gender,
                    e.JoinDate,
                    e.DepartmentId,
                    d.Name AS DepartmentName,
                    e.RoleId,
                    r.RoleName,
                    e.Salary,
                    e.IsActive
                FROM Employees e
                LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId
                LEFT JOIN Roles r ON e.RoleId = r.RoleId
                WHERE e.EmployeeId = @EmployeeId", new { EmployeeId = id });
        }
    }
}
