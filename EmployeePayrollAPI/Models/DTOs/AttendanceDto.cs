using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class AttendanceDto
    {
        public int AttendanceId { get; set; }

        [Required(ErrorMessage = "EmployeeId is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Invalid EmployeeId.")]
        public int EmployeeId { get; set; }

        [Required(ErrorMessage = "AttendanceDate is required.")]
        public DateTime AttendanceDate { get; set; }

        public TimeSpan? InTime {  get; set; }
        public TimeSpan? OutTime { get; set; }

        [Required(ErrorMessage = "Status is required.")]
        [StringLength(20, ErrorMessage = "Status cannot be longer than 20 characters.")]
        public string Status { get; set; }  
    }
}
