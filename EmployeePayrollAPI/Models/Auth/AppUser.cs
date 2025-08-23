using Microsoft.AspNetCore.Identity;

namespace EmployeePayrollAPI.Models.Auth
{
    public class AppUser:IdentityUser
    {
        public int? EmployeeId {  get; set; }
    }
}
