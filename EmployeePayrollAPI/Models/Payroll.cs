using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class Payroll
{
    public int PayrollId { get; set; }

    public int? EmployeeId { get; set; }

    public int? Month { get; set; }

    public int? Year { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? Hra { get; set; }

    public decimal? Da { get; set; }

    public decimal? Deductions { get; set; }

    public decimal? NetSalary { get; set; }

    public DateTime? GeneratedOn { get; set; }

    public int? TotalLeaves { get; set; }

    public int? WorkingDays { get; set; }

    public int? PresentDays { get; set; }

    public decimal? LeaveDeductions { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual ICollection<SalaryComponent> SalaryComponents { get; set; } = new List<SalaryComponent>();
}
