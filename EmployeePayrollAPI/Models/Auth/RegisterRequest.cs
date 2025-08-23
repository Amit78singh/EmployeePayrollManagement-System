using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.Auth
{
    public class RegisterRequest
    {
        [Required,EmailAddress]
        public string Email { get; set; }

        [Required]
        [MinLength(6)]
        public string Password { get; set; }

        [Required]
        public string Role { get; set; } = default!;

        public int? EmployeeId {  get; set; }
    }
}
