using Dapper;
using EmployeePayrollAPI.Data;
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
        
        private readonly string _connectionString;

        public AttendanceRepository(IConfiguration configuration)
        {
            
            _connectionString = configuration.GetConnectionString("EmployeeDB");

        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_connectionString);
        }

        // Mark Attendance  ->>>> usp_Attendance_Mark
        public async Task<(int StatusCode, string Message)> MarkAttendanceAsync(AttendanceDto request)
        {
            using var conn = CreateConnection();
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


        // 2. Get monthly attendance (report) -> dbo.usp_Attendance_GetPerfectEmployees

        public async Task<IEnumerable<dynamic>> GetMonthlyAttendanceAsync( int year, int month)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();

           // parameters.Add(@"EmployeeId", employeeId);
            parameters.Add(@"Year", year);
            parameters.Add(@"Month", month);


            return await conn.QueryAsync(
                "dbo.usp_Attendance_GetPerfectEmployees",
                parameters,
                commandType: CommandType.StoredProcedure);

        }

        // 3. Bulk insert -> dbo.usp_Attendance_BulkInsert (uses TVP)

        public async Task BulkInsertAsync(DataTable table)
        {
            using var conn = (SqlConnection)CreateConnection();
            await conn.OpenAsync();

            using var cmd = conn.CreateCommand();
            cmd.CommandType= CommandType.StoredProcedure;
            cmd.CommandText = "dbo.usp_Attendance_BulkInsert";


            var parameter = cmd.Parameters.AddWithValue("@AttendanceRecords", table);
            parameter.SqlDbType = SqlDbType.Structured;
            parameter.TypeName = "dbo.AttendanceTableType";

            await cmd.ExecuteNonQueryAsync();
      


        }   
    }
}
