using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class LeaveApproveDto
    {
        [Required]
        public int LeaveRequestId { get; set; }

        [Required]
        public string ApprovedBy { get; set; } = string.Empty;

        [Required]
        public bool Approve { get; set; }
      
    }

}
