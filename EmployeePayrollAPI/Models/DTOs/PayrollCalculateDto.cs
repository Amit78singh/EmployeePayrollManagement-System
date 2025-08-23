using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class PayrollCalculateDto
    {
        [Required]
        public int EmployeeId { get; set; }

        [Required]
        public int Year { get; set; }

        [Required]
        public int Month { get; set; }

        [Required]
        public decimal BasicSalary { get; set; }

        public decimal HRA { get; set; }

        public decimal DA { get; set; }

        public int TotalLeaves { get; set; }

        public int WorkingDays { get; set; }

        public int PresentDays { get; set; }
        public decimal LeaveDeductions { get; set; }
        public DateTime GeneratedOn { get; set; } = DateTime.Now;
    }
}
