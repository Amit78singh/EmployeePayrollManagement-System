using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class Employee
{
    public int EmployeeId { get; set; }

    public string FullName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? Phone { get; set; }

    public string? Gender { get; set; }

    public DateOnly JoinDate { get; set; }

    public int? DepartmentId { get; set; }

    public int? RoleId { get; set; }

    public bool? IsActive { get; set; }

    public decimal? Salary { get; set; }

    public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();

    public virtual Department? Department { get; set; }

    public virtual ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();

    public virtual ICollection<Payroll> Payrolls { get; set; } = new List<Payroll>();

    public virtual Role? Role { get; set; }
}
