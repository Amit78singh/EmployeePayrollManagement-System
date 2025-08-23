using Dapper;
using EmployeePayrollAPI.Infrastructure;
using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public class LeaveRepository:ILeaveRepository
    {
        private readonly IDbConnectionFactory _db;

        public LeaveRepository(IDbConnectionFactory db )
        {
            _db = db;
       
        }

        public async Task<int> ApplyLeaveAsync(LeaveApplyDto dto)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", dto.EmployeeId);
            p.Add("@FromDate", dto.FromDate.Date);
            p.Add("@ToDate", dto.ToDate.Date);

           // p.Add("@Reason", dto.Reason);

            return await conn.ExecuteScalarAsync<int>("dbo.usp_LeaveRequest_Apply",
                p, commandType: CommandType.StoredProcedure);       
        }

        public async Task<(string StatusCode, string Message)> ApproveLeaveAsync(LeaveApproveDto dto)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@LeaveRequestId", dto.LeaveRequestId);
            p.Add("@NewStatus", dto.Approve ? "Approved" : "Rejected");
            p.Add("@ApprovedBy", dto.ApprovedBy);

            var result = await conn.QueryFirstOrDefaultAsync<dynamic>(
                "dbo.usp_LeaveRequest_Approve", p, commandType: CommandType.StoredProcedure);

            string statusCode = Convert.ToString(result?.StatusCode);
            string message = Convert.ToString(result?.Message);

            return (statusCode, message);
        }

        public async Task<IEnumerable<dynamic>>GetAllAsync(int? employeeId= null)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", employeeId);
            return await conn.QueryAsync("dbo.usp_LeaveRequest_GetAll", p, commandType: CommandType.StoredProcedure);
        }

    }
}
