using EmployeePayrollAPI.Models.DTOs;

namespace EmployeePayrollAPI.Repositories
{
    public interface IPayrollRepository
    {
        Task CalculateMonthlySalaryAsync(int employeeId, int year, int month);
        Task GenerateMonthlyAsync(PayrollCalculateDto dto);
        Task<dynamic> GetSlipAsync(int employeeId, int year, int month);

    }
}
