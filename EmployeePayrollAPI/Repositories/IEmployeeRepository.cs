namespace EmployeePayrollAPI.Repositories
{
    public interface IEmployeeRepository
    {
        Task<IEnumerable<dynamic>> GetAllAsync();
        Task<int> CreateAsync(Models.DTOs.EmployeeCreateDto dto);
        Task UpdateAsync(int id, Models.DTOs.EmployeeUpdateDto dto);
        Task DeleteAsync(int id);
        Task<dynamic?> GetByIdAsync(int id);
    }
}
