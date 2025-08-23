using EmployeePayrollAPI.Data;
using EmployeePayrollAPI.Models.Auth;
using EmployeePayrollAPI.Models.DTOs;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using EmployeePayrollAPI.Services;
using System.Data;
using static EmployeePayrollAPI.Services.TokenService;

namespace EmployeePayrollAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<AppUser> _userMgr;
        private readonly SignInManager<AppUser> _signInMgr;
        private readonly RoleManager<IdentityRole> _roleMgr;
        private readonly ITokenService _tokenService;

        public AuthController(
            UserManager<AppUser> userMgr,
            SignInManager<AppUser> signInMgr,
            RoleManager<IdentityRole> roleMgr,
            ITokenService tokenService)

        {
            _userMgr = userMgr;
            _signInMgr = signInMgr;
            _roleMgr = roleMgr;
            _tokenService = tokenService;
        }

      
        [HttpPost("register")]
     
        [AllowAnonymous]
     
        public async Task<IActionResult> Register([FromBody] RegisterRequest req)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (!await _roleMgr.RoleExistsAsync(req.Role))
                await _roleMgr.CreateAsync(new IdentityRole(req.Role));

            var user = new AppUser
            {
                UserName = req.Email,
                Email = req.Email,
                EmployeeId = req.EmployeeId
            };
            var result = await _userMgr.CreateAsync(user,req.Password);
            if(!result.Succeeded)
                return BadRequest(new {errors= result.Errors.Select(e => e.Description)});

            await _userMgr.AddToRoleAsync(user, req.Role);
            return Ok(new { message = "User Registered", email = user.Email, role = req.Role });
        }


        [HttpPost("login")]
    
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest req)
        {
            if(!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _userMgr.FindByEmailAsync(req.Email);
            if (user == null)
                return Unauthorized(new { message = "Invalid Credentials" });

            var signIn = await _signInMgr.CheckPasswordSignInAsync(user, req.Password, lockoutOnFailure: true);
            if (!signIn.Succeeded) 
                return Unauthorized(new { message = "Invalid Credentials" });

            var roles = await _userMgr.GetRolesAsync(user);
            var token = await _tokenService.CreateTokenAsync(user, roles);

            return Ok(new AuthResponse
            {
                Token = token,
                ExpiresAtUtc = _tokenService.GetExpiryUtc(),
                Email = user.Email!,
                Roles = roles
            });

        }



    }

}

