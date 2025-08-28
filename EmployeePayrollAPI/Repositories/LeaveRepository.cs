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
            p.Add("@FromDate", dto.FromDate.ToDateTime(TimeOnly.MinValue));
            p.Add("@ToDate", dto.ToDate.ToDateTime(TimeOnly.MinValue));
            p.Add("@Reason", dto.Reason ?? "");

            return await conn.ExecuteScalarAsync<int>("dbo.usp_Leave_Apply",
                p, commandType: CommandType.StoredProcedure);       
        }

        public async Task<(string StatusCode, string Message)> ApproveLeaveAsync(LeaveApproveDto dto)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@LeaveRequestId", dto.LeaveRequestId);
            p.Add("@Status", dto.Approve ? "Approved" : "Rejected");
            p.Add("@ApprovedBy", dto.ApprovedBy);

            try
            {
                await conn.ExecuteAsync("dbo.usp_Leave_Approve", p, commandType: CommandType.StoredProcedure);
                return ("LeaveApprovedSuccessfully", "Leave request has been processed successfully");
            }
            catch (Exception ex)
            {
                return ("Error", $"Failed to process leave request: {ex.Message}");
            }
        }

        public async Task<IEnumerable<dynamic>>GetAllAsync(int? employeeId= null)
        {
            using var conn = _db.CreateConnection();
            
            string sql;
            if (employeeId.HasValue)
            {
                sql = @"
                    SELECT 
                        lr.LeaveRequestId,
                        lr.EmployeeId,
                        e.FullName as EmployeeName,
                        lr.FromDate,
                        lr.ToDate,
                        lr.Reason,
                        lr.Status,
                        lr.ApprovedBy,
                        lr.ApprovedDate,
                        lr.RequestDate
                    FROM LeaveRequests lr
                    INNER JOIN Employees e ON lr.EmployeeId = e.EmployeeId
                    WHERE lr.EmployeeId = @EmployeeId
                    ORDER BY lr.RequestDate DESC";
                return await conn.QueryAsync(sql, new { EmployeeId = employeeId });
            }
            else
            {
                sql = @"
                    SELECT 
                        lr.LeaveRequestId,
                        lr.EmployeeId,
                        e.FullName as EmployeeName,
                        lr.FromDate,
                        lr.ToDate,
                        lr.Reason,
                        lr.Status,
                        lr.ApprovedBy,
                        lr.ApprovedDate,
                        lr.RequestDate
                    FROM LeaveRequests lr
                    INNER JOIN Employees e ON lr.EmployeeId = e.EmployeeId
                    ORDER BY lr.RequestDate DESC";
                return await conn.QueryAsync(sql);
            }
        }

    }
}
