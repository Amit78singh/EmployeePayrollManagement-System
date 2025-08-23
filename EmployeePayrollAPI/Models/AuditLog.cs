using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class AuditLog
{
    public int LogId { get; set; }

    public string? TableName { get; set; }

    public string? Action { get; set; }

    public string? ChangedBy { get; set; }

    public DateTime? ChangedOn { get; set; }

    public string? Details { get; set; }
}
