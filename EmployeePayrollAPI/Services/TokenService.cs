using EmployeePayrollAPI.Models.Auth;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace EmployeePayrollAPI.Services
{
 
    
        public interface ITokenService
        {
            Task<string> CreateTokenAsync(AppUser  user, IList<string>roles);
            DateTime GetExpiryUtc();
        }

        public class TokenService : ITokenService
        {
            private readonly IConfiguration _config;

            public TokenService(IConfiguration config)
            {
                _config = config;
            }
           

            public DateTime GetExpiryUtc()
            {
               var minutes = int.TryParse(_config["JwtSettings:ExpiryMinutes"], out var m) ? m : 60;
                return DateTime.UtcNow.AddMinutes(minutes);
            }
        

        public async Task<string> CreateTokenAsync(AppUser user, IList<string> roles)
        {
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.Email ?? string.Empty),
            };

            if (user.EmployeeId.HasValue)
                claims.Add(new Claim("employeeId", user.EmployeeId.Value.ToString()));

            foreach (var role in roles)
                claims.Add(new Claim(ClaimTypes.Role, role));

            var jwtKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY") ?? _config["JwtSettings:Key"];
            if (string.IsNullOrEmpty(jwtKey))
            {
                throw new InvalidOperationException("JWT Key is not configured");
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["JwtSettings:Issuer"],
                audience: _config["JwtSettings:Audience"],
                claims: claims,
                expires: GetExpiryUtc(),
                signingCredentials: creds);

            return await Task.FromResult(new JwtSecurityTokenHandler().WriteToken(token));
        }
    }
}
