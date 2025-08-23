using System;
using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.DTOs
{
    public class EmployeeCreateDto
    {
        [Required]
        public string FullName { get; set; }
        [Required, EmailAddress]
        public string Email { get; set; }
        public string? Phone { get; set; }
        public string? Gender { get; set; }
        [Required]
        public DateTime JoinDate { get; set; }
        public int? DepartmentId { get; set; }
        public int? RoleId { get; set; }
    }
}
