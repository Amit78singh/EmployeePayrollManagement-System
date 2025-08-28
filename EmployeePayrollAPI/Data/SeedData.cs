using Microsoft.AspNetCore.Identity;
using EmployeePayrollAPI.Models.Auth;

namespace EmployeePayrollAPI.Data
{
    public static class SeedData
    {
        public static async Task InitializeAsync(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<AppUser>>();
            var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

            // Create roles if they don't exist
            string[] roles = { "Admin", "HR", "Employee" };
            foreach (var role in roles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                {
                    await roleManager.CreateAsync(new IdentityRole(role));
                }
            }

            // Create default admin user
            var adminEmail = "admin@test.com";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            
            if (adminUser == null)
            {
                adminUser = new AppUser
                {
                    UserName = adminEmail,
                    Email = adminEmail,
                    EmployeeId = 1,
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(adminUser, "Password123");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(adminUser, "Admin");
                }
            }

            // Create default HR user
            var hrEmail = "hr@test.com";
            var hrUser = await userManager.FindByEmailAsync(hrEmail);
            
            if (hrUser == null)
            {
                hrUser = new AppUser
                {
                    UserName = hrEmail,
                    Email = hrEmail,
                    EmployeeId = 2,
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(hrUser, "Password123");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(hrUser, "HR");
                }
            }

            // Create default employee user
            var empEmail = "employee@test.com";
            var empUser = await userManager.FindByEmailAsync(empEmail);
            
            if (empUser == null)
            {
                empUser = new AppUser
                {
                    UserName = empEmail,
                    Email = empEmail,
                    EmployeeId = 3,
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(empUser, "Password123");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(empUser, "Employee");
                }
            }
        }
    }
}
