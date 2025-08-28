using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class LeaveApplyDto
    {
        [Required]
        public int EmployeeId { get; set; }

        [Required]
        public DateOnly FromDate { get; set; }

        [Required]
        public DateOnly ToDate { get; set; }

        [MaxLength(500)]
        public string? Reason { get; set; }

    }
}
