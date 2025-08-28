using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class LeaveRequest
{
    public int LeaveRequestId { get; set; }

    public int? EmployeeId { get; set; }

    public DateOnly? FromDate { get; set; }

    public DateOnly? ToDate { get; set; }

    public string? Status { get; set; }

    public string? ApprovedBy { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public string? Reason { get; set; }

    public DateTime? RequestDate { get; set; }

    public virtual Employee? Employee { get; set; }
}
