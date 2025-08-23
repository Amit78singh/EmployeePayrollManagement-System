using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class VwEmployeeSalarySlip
{
    public int PayrollId { get; set; }

    public int EmployeeId { get; set; }

    public string FullName { get; set; } = null!;

    public string DepartmentName { get; set; } = null!;

    public decimal? BasicSalary { get; set; }

    public decimal? Deductions { get; set; }

    public decimal? NetSalary { get; set; }

    public int? Month { get; set; }

    public int? Year { get; set; }
}
