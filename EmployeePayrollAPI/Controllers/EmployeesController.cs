using EmployeePayrollAPI.Models.DTOs;
using EmployeePayrollAPI.Repositories;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;

namespace EmployeePayrollAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EmployeesController : ControllerBase
    {
        private readonly IEmployeeRepository _repo;
        public EmployeesController(IEmployeeRepository repo)
        {
            _repo = repo;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var list = await _repo.GetAllAsync();
                return Ok(list);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while fetching employees", error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] EmployeeCreateDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            try
            {
                int id = await _repo.CreateAsync(dto);
                return Ok(new { message = "Employee created successfully.", id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while creating employee", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] EmployeeUpdateDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            
            if (id <= 0)
                return BadRequest("Invalid employee ID");
                
            try
            {
                await _repo.UpdateAsync(id, dto);
                return Ok(new { message = "Employee updated successfully." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while updating employee", error = ex.Message });
            }
        }
    }
}
