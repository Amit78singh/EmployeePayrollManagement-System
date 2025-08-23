using EmployeePayrollAPI.Models.DTOs;

namespace EmployeePayrollAPI.Repositories
{
    public interface ILeaveRepository
    {
        Task<int> ApplyLeaveAsync(Models.DTOs.LeaveApplyDto dto);
        Task<(string StatusCode, string Message)> ApproveLeaveAsync(LeaveApproveDto dto);
        Task<IEnumerable<dynamic>> GetAllAsync(int? employeeId = null);

    }
}
