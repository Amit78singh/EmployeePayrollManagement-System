using System;
using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class EmployeeUpdateDto
    {
        [Required]
        public string FullName { get; set; }
        public string? Phone { get; set; }
        public string? Gender { get; set; }
        [Required]
        public DateTime JoinDate { get; set; }
        public int? DepartmentId { get; set; }
        public int? RoleId { get; set; }
        public bool IsActive { get; set; }
    }
}
