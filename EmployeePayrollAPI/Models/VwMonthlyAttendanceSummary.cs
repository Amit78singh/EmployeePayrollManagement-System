using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class VwMonthlyAttendanceSummary
{
    public int EmployeeId { get; set; }

    public string FullName { get; set; } = null!;

    public string? MonthName { get; set; }

    public int? YearNum { get; set; }

    public int? TotalPresent { get; set; }

    public int? TotalAbsent { get; set; }

    public int? TotalLeave { get; set; }
}
