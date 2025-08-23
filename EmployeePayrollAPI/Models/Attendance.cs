using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class Attendance
{
    public int AttendanceId { get; set; }

    public int? EmployeeId { get; set; }

    public DateOnly AttendanceDate { get; set; }

    public TimeOnly? InTime { get; set; }

    public TimeOnly? OutTime { get; set; }

    public string? Status { get; set; }

    public virtual Employee? Employee { get; set; }
}
