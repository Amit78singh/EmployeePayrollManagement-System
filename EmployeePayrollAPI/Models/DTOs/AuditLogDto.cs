namespace EmployeePayrollAPI.Models.DTOs
{
    public class AuditLogDto
    {
        public int AuditLogId { get; set; }
        public string TableName { get; set; }
        public string Action { get; set; }
        public string ChangedBy { get; set; }
        public DateTime ChangedOn { get; set; }
        public string Details { get; set; }
    }
}
    