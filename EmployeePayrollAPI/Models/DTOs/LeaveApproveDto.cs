using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class LeaveApproveDto
    {
        [Required]
        public int LeaveRequestId { get; set; }

        [Required]
        public string ApprovedBy { get; set; }

        [Required]
        public bool Approve { get; set; }
      
    }

}
