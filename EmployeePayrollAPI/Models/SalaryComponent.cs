using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class SalaryComponent
{
    public int ComponentId { get; set; }

    public int? PayrollId { get; set; }

    public string? ComponentName { get; set; }

    public decimal? Amount { get; set; }

    public virtual Payroll? Payroll { get; set; }
}
