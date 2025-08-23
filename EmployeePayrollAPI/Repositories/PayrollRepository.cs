using Dapper;
using EmployeePayrollAPI.Infrastructure;
using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public class PayrollRepository: IPayrollRepository
    {
        private readonly IDbConnectionFactory _db;

        public PayrollRepository(IDbConnectionFactory db)
        {
            _db = db;
        }
        

        public async Task CalculateMonthlySalaryAsync(int employeeId, int year, int month)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", employeeId);
            p.Add("@Year", year);
            p.Add("@Month", month);

            await conn.ExecuteAsync("dbo.usp_Payroll_CalculateMonthlySalary",
                p, commandType: CommandType.StoredProcedure);

        }
        public async Task GenerateMonthlyAsync(PayrollCalculateDto dto)
        { 


            using var conn = _db.CreateConnection();

            var p = new DynamicParameters();
            p.Add("@EmployeeId", dto.EmployeeId);
            p.Add("@Month", dto.Month);
            p.Add("@Year", dto.Year);
            p.Add("@BasicSalary", dto.BasicSalary);
            p.Add("@HRA", dto.HRA);
            p.Add("@DA", dto.DA);
            p.Add("@TotalLeaves", dto.TotalLeaves);
            p.Add("@WorkingDays", dto.WorkingDays);
            p.Add("@PresentDays", dto.PresentDays);
            //p.Add("@LeaveDeductions", dto.LeaveDeductions);
            //p.Add("@GeneratedOn", dto.GeneratedOn == default ? DateTime.Now : dto.GeneratedOn);

            await conn.ExecuteAsync("dbo.usp_Payroll_GenerateMonthly",
                p, commandType: CommandType.StoredProcedure);
        }



        public async Task<dynamic> GetSlipAsync(int employeeId, int year, int month)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters(); ;
            p.Add("@EmployeeId", employeeId);
            p.Add("@Year", year);
            p.Add("@Month", month);

            return await conn.QueryFirstOrDefaultAsync<dynamic>("dbo.usp_Payroll_GetSlip", p, commandType: CommandType.StoredProcedure);
        }    

    }

}
