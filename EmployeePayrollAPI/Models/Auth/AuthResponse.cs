using System.ComponentModel.DataAnnotations;

namespace EmployeePayrollAPI.Models.Auth
{
    public class AuthResponse
    {
        [Required]
        public string Token { get; set; } = default!;
        [Required]
        public DateTime ExpiresAtUtc { get; set; }
        [Required]
        public string Email { get; set; } = default!;
        [Required]
        public IEnumerable<string> Roles { get; set; } = Enumerable.Empty<string>();
    }
}
