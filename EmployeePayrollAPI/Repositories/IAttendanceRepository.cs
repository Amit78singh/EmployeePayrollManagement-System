using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public interface IAttendanceRepository
    {
        Task<(int StatusCode, string Message)> MarkAttendanceAsync(AttendanceDto request);
        Task<IEnumerable<dynamic>> GetMonthlyAttendanceAsync(int year, int month);
        Task BulkInsertAsync(DataTable table);
        Task<IEnumerable<dynamic>> GetEmployeeAttendanceAsync(int employeeId, int? month, int? year);
    }
}