using EmployeePayrollAPI.Models.DTOs;
using EmployeePayrollAPI.Repositories;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System;

namespace EmployeePayrollAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AttendanceController : ControllerBase
    {
        private readonly IAttendanceRepository _attendanceRepo;
       
      public AttendanceController(IAttendanceRepository attendanceRepo)
        {
            _attendanceRepo = attendanceRepo;
        }

        // POST api/attendance/mark

        [HttpPost("mark")]
        public async Task<IActionResult> MarkAttendance([FromBody] AttendanceDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var result = await _attendanceRepo.MarkAttendanceAsync(dto);
                if (result.StatusCode == 200)
                {
                    return Ok(new { message = "Attendance Marked Successfully" });
                }
                return BadRequest(new { message = result.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while marking attendance", error = ex.Message });
            }
        }

        // POST api/attendance/bulkinsert

        [HttpPost("bulkInsert")]
        public async Task<IActionResult> BulkInsert([FromBody] List<AttendanceDto> list)
        {
            if (list == null || list.Count == 0)
                return BadRequest("No Attendance Records Provided");

            if (list.Count > 1000) // Limit bulk operations
                return BadRequest("Bulk insert limited to 1000 records at a time");

            try
            {
                var table = new DataTable();
                table.Columns.Add("EmployeeId", typeof(int));
                table.Columns.Add("AttendanceDate", typeof(DateTime));
                table.Columns.Add("InTime", typeof(TimeSpan));
                table.Columns.Add("OutTime", typeof(TimeSpan));
                table.Columns.Add("Status", typeof(string));

                foreach (var r in list)
                {
                    if (r.EmployeeId <= 0)
                        return BadRequest($"Invalid EmployeeId: {r.EmployeeId}");
                    
                    table.Rows.Add(r.EmployeeId, r.AttendanceDate, r.InTime, r.OutTime, r.Status);
                }

                await _attendanceRepo.BulkInsertAsync(table);
                return Ok(new { message = $"Bulk Insert Completed For {list.Count} records." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred during bulk insert", error = ex.Message });
            }
        }

        // GET api/attendance/summary/{month}/{year}
        [HttpGet("summary/{month}/{year}")]
        public async Task<IActionResult> GetMonthly(int month, int year)
        {
            if (month < 1 || month > 12)
                return BadRequest("Month must be between 1 and 12");
            
            if (year < 2000 || year > 2100)
                return BadRequest("Year must be between 2000 and 2100");

            try
            {
                var result = await _attendanceRepo.GetMonthlyAttendanceAsync(year, month);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while fetching monthly attendance", error = ex.Message });
            }
        }
    }
}
