using System;
using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class EmployeeUpdateDto
    {
        [Required]
        public string FullName { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Gender { get; set; }
        [Required]
        public DateOnly JoinDate { get; set; }
        public int? DepartmentId { get; set; }
        public int? RoleId { get; set; }
        public decimal? Salary { get; set; }
        public bool IsActive { get; set; }
    }
}
