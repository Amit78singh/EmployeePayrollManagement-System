using EmployeePayrollAPI.Models.DTOs;
using EmployeePayrollAPI.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace EmployeePayrollAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PayrollController : ControllerBase
    {
        private readonly IPayrollRepository _repo;

        public PayrollController(IPayrollRepository repo)
        {
            _repo = repo;
        }

        [HttpPost("CalculateSalary")]
        public async Task<IActionResult> CalculateSalary([FromBody] PayrollCalculateDto dto)
        {
            if(!ModelState.IsValid)

                return BadRequest(ModelState);

            await _repo.CalculateMonthlySalaryAsync(dto.EmployeeId, dto.Year, dto.Month);
            return Ok(new {message = " Monthly Salary Calculated"});

        }

        [HttpPost("GenerateMonthly")]
        public async Task<IActionResult> GenerateMonthlySalary([FromBody] PayrollCalculateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Manual validation
            if (dto.BasicSalary <= 0 || dto.WorkingDays <= 0)
                return BadRequest(new { message = "BasicSalary and WorkingDays are required and must be > 0." });


            await _repo.GenerateMonthlyAsync(dto);
            return Ok(new { message = "Monthly payroll Generated" });
        }

        [Authorize(Roles = "HR,Admin")]
        [HttpGet("slip")]
        public async Task<IActionResult> GetSlip(int employeeId , int year, int month)
        {
           var data = await _repo.GetSlipAsync(employeeId, year, month);
            if (data == null) return NotFound();
            return Ok(data);

        }
    }
}
