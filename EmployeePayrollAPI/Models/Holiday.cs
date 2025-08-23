using System;
using System.Collections.Generic;

namespace EmployeePayrollAPI.Models;

public partial class Holiday
{
    public int HolidayId { get; set; }

    public string? HolidayName { get; set; }

    public DateOnly? HolidayDate { get; set; }
}
