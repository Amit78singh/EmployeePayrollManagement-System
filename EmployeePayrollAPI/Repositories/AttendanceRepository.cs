using Dapper;
using EmployeePayrollAPI.Infrastructure;
using EmployeePayrollAPI.Models.DTOs;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
namespace EmployeePayrollAPI.Repositories
{
    public class AttendanceRepository : IAttendanceRepository
    {
        private readonly IDbConnectionFactory _db;

        public AttendanceRepository(IDbConnectionFactory db)
        {
            _db = db;
        }

        // Mark Attendance - Using stored procedure usp_Attendance_Mark
        public async Task<(int StatusCode, string Message)> MarkAttendanceAsync(AttendanceDto request)
        {
            using var conn = _db.CreateConnection();
            var parameters = new DynamicParameters();

            parameters.Add("@EmployeeId", request.EmployeeId);
            parameters.Add("@AttendanceDate", request.AttendanceDate);
            parameters.Add("@InTime", request.InTime);
            parameters.Add("@OutTime", request.OutTime);
            parameters.Add("@Status", request.Status);
            parameters.Add("@StatusCode", dbType: DbType.Int32, direction: ParameterDirection.Output);
            parameters.Add("@Message", dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

            await conn.ExecuteAsync("usp_Attendance_Mark", parameters, commandType: CommandType.StoredProcedure);

            return (parameters.Get<int>("@StatusCode"), parameters.Get<string>("@Message"));
        }

        // Get monthly attendance (report) - Using stored procedure usp_Attendance_GetPerfectEmployees
        public async Task<IEnumerable<dynamic>> GetMonthlyAttendanceAsync(int year, int month)
        {
            using var conn = _db.CreateConnection();
            var parameters = new DynamicParameters();

            parameters.Add("@Year", year);
            parameters.Add("@Month", month);

            return await conn.QueryAsync(
                "usp_Attendance_GetPerfectEmployees",
                parameters,
                commandType: CommandType.StoredProcedure);
        }

        // Bulk insert - Using stored procedure usp_Attendance_BulkInsert
        public async Task BulkInsertAsync(DataTable table)
        {
            using var conn = (SqlConnection)_db.CreateConnection();
            await conn.OpenAsync();

            using var cmd = conn.CreateCommand();
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "usp_Attendance_BulkInsert";

            var parameter = cmd.Parameters.AddWithValue("@AttendanceRecords", table);
            parameter.SqlDbType = SqlDbType.Structured;
            parameter.TypeName = "dbo.AttendanceTableType";

            await cmd.ExecuteNonQueryAsync();
        }

        // Get employee attendance
        public async Task<IEnumerable<dynamic>> GetEmployeeAttendanceAsync(int employeeId, int? month, int? year)
        {
            using var conn = _db.CreateConnection();
            var parameters = new DynamicParameters();

            parameters.Add("@EmployeeId", employeeId);
            if (month.HasValue) parameters.Add("@Month", month.Value);
            if (year.HasValue) parameters.Add("@Year", year.Value);

            var sql = @"
                SELECT 
                    a.AttendanceId, 
                    a.EmployeeId, 
                    a.AttendanceDate, 
                    a.InTime, 
                    a.OutTime, 
                    a.Status,
                    e.FullName as EmployeeName
                FROM Attendance a
                INNER JOIN Employees e ON a.EmployeeId = e.EmployeeId
                WHERE a.EmployeeId = @EmployeeId
                AND (@Month IS NULL OR MONTH(a.AttendanceDate) = @Month)
                AND (@Year IS NULL OR YEAR(a.AttendanceDate) = @Year)
                ORDER BY a.AttendanceDate DESC";

            return await conn.QueryAsync(sql, parameters);
        }
    }
}
