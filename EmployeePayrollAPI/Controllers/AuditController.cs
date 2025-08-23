using EmployeePayrollAPI.Repositories;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace EmployeePayrollAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuditController : ControllerBase
    {
        private readonly IAuditRepository _repo;

        public AuditController(IAuditRepository repo)
        {
          _repo=repo;
          
        }

        // GET: api/audit
        [HttpGet("{employeeId}")]
        public async Task<IActionResult> Get(int employeeId)
        {
            var logs = await _repo.GetAuditLogAsync(employeeId);
            return Ok(logs);
        }

        // POST api/audit/login/{employeeId} --> insert login log
        [HttpPost("login/{employeeId}")]
        public async Task<IActionResult> Login(int employeeId)
        {
            var (status, message) = await _repo.LogLoginAsync(employeeId);

            if (!string.IsNullOrEmpty(status) && status != "0")
                return BadRequest(new { status, message });

            return Ok(new { message });
        }

    }
}
