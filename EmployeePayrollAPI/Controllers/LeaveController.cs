using EmployeePayrollAPI.Models.DTOs;
using EmployeePayrollAPI.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace EmployeePayrollAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LeaveController : ControllerBase
    {
        private readonly ILeaveRepository _repo;

        public LeaveController(ILeaveRepository repo)
        {
            _repo = repo;
        }

        [HttpPost("apply")]
        public async Task<IActionResult> ApplyLeave([FromBody] LeaveApplyDto dto)
        {
            if(!ModelState.IsValid)
                return BadRequest(ModelState);

            var id = await _repo.ApplyLeaveAsync(dto);
            return Ok(new {message = "Leave applied", LeaveRequestId=id});

        }
        [Authorize(Roles = "HR,Admin")]
        [HttpPost("approve")]
        public async Task<IActionResult> ApproveLeave([FromBody] LeaveApproveDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (statusCode, message) = await _repo.ApproveLeaveAsync(dto);

            if (statusCode == "LeaveApprovedSuccessfully" || statusCode == "LeaveRejectedSuccessfully")
            {
                // Success: return HTTP 200
                return Ok(new { statusCode, message });
            }
            return BadRequest(new { statusCode, message });
        }

        [HttpGet("list")]
        public async Task<IActionResult> GetList (int? employeeId)
        {
            var result = await _repo.GetAllAsync(employeeId);
            return Ok(result);
        }
      

    }
}
