using Microsoft.Data.SqlClient;
using System.Data;

namespace EmployeePayrollAPI.Infrastructure
{
    public interface IDbConnectionFactory
    {
        IDbConnection CreateConnection();

    }

    //2  implementation of factory
    public class SqlDbConnectionFactory:IDbConnectionFactory
        {
        private readonly string _connectionString;

        public SqlDbConnectionFactory(string connectionString)
            {
               _connectionString = connectionString;
            }
        public IDbConnection CreateConnection()
            {
              return new SqlConnection(_connectionString);
            }
        }

}
