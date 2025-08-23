using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public interface IAttendanceRepository
    {
        //  Task MarkAttendanceAsync(Models.DTOs.AttendanceDto request);
        Task<(int StatusCode, string Message)> MarkAttendanceAsync(AttendanceDto request);

        Task<IEnumerable<dynamic>> GetMonthlyAttendanceAsync( int year , int month);
        Task BulkInsertAsync(DataTable table);  // for dbo.usp_attendance
        


    }
}