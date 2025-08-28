namespace EmployeePayrollAPI.Models.DTOs
{
    public class AuditLogDto
    {
        public int LogId { get; set; }
        public string TableName { get; set; }
        public string Action { get; set; }
        public string ChangedBy { get; set; }
        public DateTime ChangeDate { get; set; }
        public string NewValues { get; set; }
    }
}