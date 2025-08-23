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
            return await conn.QueryAsync("dbo.usp_Employee_GetAll", commandType: CommandType.StoredProcedure);

        }

        public async Task<int> CreateAsync(Models.DTOs.EmployeeCreateDto dto)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@FullName", dto.FullName);
            p.Add("@Email", dto.Email);
            p.Add("@Phone", dto.Phone);
            p.Add("@Gender", dto.Gender);
            p.Add("@JoinDate", dto.JoinDate);
            p.Add("@DepartmentId", dto.DepartmentId);
            p.Add("@RoleId", dto.RoleId);
            return await conn.ExecuteScalarAsync<int>("dbo.usp_Employee_Create",p, commandType: CommandType.StoredProcedure);
        }

       public async Task UpdateAsync(int id, EmployeeUpdateDto dto)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", id);
            p.Add("@FullName", dto.FullName);
            p.Add("@Phone", dto.Phone);
            p.Add("@Gender", dto.Gender);
            p.Add("@JoinDate", dto.JoinDate);
            p.Add("@DepartmentId", dto.DepartmentId);
            p.Add("@RoleId", dto.RoleId);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("dbo.usp_Employee_Update",p, commandType: CommandType.StoredProcedure);
        }
    }
}
