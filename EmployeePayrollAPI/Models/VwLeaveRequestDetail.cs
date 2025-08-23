using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class VwLeaveRequestDetail
{
    public int LeaveRequestId { get; set; }

    public string FullName { get; set; } = null!;

    public string DepartmentName { get; set; } = null!;

    public DateOnly? StartDate { get; set; }

    public DateOnly? EndDate { get; set; }

    public string? Status { get; set; }

    public string? ApprovedBy { get; set; }
}
