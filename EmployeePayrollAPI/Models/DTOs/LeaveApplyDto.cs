using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class LeaveApplyDto
    {
        [Required]
        public int EmployeeId { get; set; }

        [Required]
        public  DateTime FromDate{get; set;}

        [Required]
        public DateTime ToDate{get; set;}

        //[Required]
        //[MaxLength(200)]
        //public string Reason { get; set; }

    }
}
