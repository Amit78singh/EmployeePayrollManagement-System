using System;
using System.Collections.Generic;
using EmployeePayrollAPI.Models;
using EmployeePayrollAPI.Models.Auth;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace EmployeePayrollAPI.Data;

public partial class EmployeeDBContext : IdentityDbContext<AppUser>
{
   
    public EmployeeDBContext(DbContextOptions<EmployeeDBContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Attendance> Attendances { get; set; }

    public virtual DbSet<AuditLog> AuditLogs { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<Holiday> Holidays { get; set; }

    public virtual DbSet<LeaveRequest> LeaveRequests { get; set; }

    public virtual DbSet<Payroll> Payrolls { get; set; }

    public new virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<SalaryComponent> SalaryComponents { get; set; }

    public virtual DbSet<VwEmployeeSalarySlip> VwEmployeeSalarySlips { get; set; }

    public virtual DbSet<VwLeaveRequestDetail> VwLeaveRequestDetails { get; set; }

    public virtual DbSet<VwMonthlyAttendanceSummary> VwMonthlyAttendanceSummaries { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseSqlServer("Name=EmployeeDB");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Attendance>(entity =>
        {
            entity.HasKey(e => e.AttendanceId).HasName("PK__Attendan__8B69261C9B074A30");

            entity.ToTable("Attendance", tb => tb.HasTrigger("trg_AfterAttendanceInsert"));

            entity.HasIndex(e => e.EmployeeId, "IX_Attendance_EmployeeId");

            entity.HasIndex(e => new { e.EmployeeId, e.AttendanceDate }, "IX_Attendance_EmployeeId_AttendanceDate");

            entity.Property(e => e.Status).HasMaxLength(20);

            entity.HasOne(d => d.Employee).WithMany(p => p.Attendances)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK__Attendanc__Statu__534D60F1");
        });

        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.HasKey(e => e.LogId).HasName("PK__AuditLog__5E548648CE38BD90");

            entity.HasIndex(e => new { e.TableName, e.ChangedOn }, "IX_AuditLogs_TableName_ChangedOn");

            entity.Property(e => e.Action).HasMaxLength(20);
            entity.Property(e => e.ChangedBy).HasMaxLength(100);
            entity.Property(e => e.ChangedOn)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.TableName).HasMaxLength(100);
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.HasKey(e => e.DepartmentId).HasName("PK__Departme__B2079BEDF953D3F1");

            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.HasKey(e => e.EmployeeId).HasName("PK__Employee__7AD04F11E1D361B9");

            entity.HasIndex(e => e.DepartmentId, "IX_Employees_DepartmentId");

            entity.HasIndex(e => e.RoleId, "IX_Employees_RoleId");

            entity.HasIndex(e => e.Email, "UQ__Employee__A9D10534F9E61C44").IsUnique();

            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.Gender)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Phone).HasMaxLength(20);

            entity.HasOne(d => d.Department).WithMany(p => p.Employees)
                .HasForeignKey(d => d.DepartmentId)
                .HasConstraintName("FK__Employees__Depar__4F7CD00D");

            entity.HasOne(d => d.Role).WithMany(p => p.Employees)
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("FK__Employees__RoleI__5070F446");
        });

        modelBuilder.Entity<Holiday>(entity =>
        {
            entity.HasKey(e => e.HolidayId).HasName("PK__Holidays__2D35D57A476ED32D");

            entity.HasIndex(e => e.HolidayDate, "IX_Holidays_HolidayDate");

            entity.Property(e => e.HolidayName).HasMaxLength(100);
        });

        modelBuilder.Entity<LeaveRequest>(entity =>
        {
            entity.HasKey(e => e.LeaveRequestId).HasName("PK__LeaveReq__609421EE13BFF6E3");

            entity.ToTable(tb => tb.HasTrigger("trg_AfterLeaveUpdate"));

            entity.HasIndex(e => e.EmployeeId, "IX_Attendance_EmployeeId");

            entity.HasIndex(e => new { e.EmployeeId, e.Status, e.FromDate, e.ToDate }, "IX_LeaveRequests_Emp_Status_From_To");

            entity.HasIndex(e => new { e.EmployeeId, e.FromDate, e.ToDate }, "IX_LeaveRequests_Pending").HasFilter("([Status]='Pending')");

            entity.Property(e => e.ApprovedBy).HasMaxLength(100);
            entity.Property(e => e.ApprovedDate).HasColumnType("datetime");
            entity.Property(e => e.Status).HasMaxLength(20);

            entity.HasOne(d => d.Employee).WithMany(p => p.LeaveRequests)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK__LeaveRequ__Emplo__5629CD9C");
        });

        modelBuilder.Entity<Payroll>(entity =>
        {
            entity.HasKey(e => e.PayrollId).HasName("PK__Payroll__99DFC6724FEE3961");

            entity.ToTable("Payroll");

            entity.HasIndex(e => new { e.EmployeeId, e.Year, e.Month }, "IX_Payroll_Employee_Year_Month");

            entity.Property(e => e.BasicSalary).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Da)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("DA");
            entity.Property(e => e.Deductions).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.GeneratedOn)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Hra)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("HRA");
            entity.Property(e => e.LeaveDeductions).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.NetSalary)
                .HasComputedColumnSql("((([BasicSalary]+[HRA])+[DA])-[Deductions])", true)
                .HasColumnType("decimal(21, 2)");

            entity.HasOne(d => d.Employee).WithMany(p => p.Payrolls)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK__Payroll__Employe__59FA5E80");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PK__Roles__8AFACE1AB126C821");

            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<SalaryComponent>(entity =>
        {
            entity.HasKey(e => e.ComponentId).HasName("PK__SalaryCo__D79CF04E39F99E30");

            entity.HasIndex(e => e.PayrollId, "IX_SalaryComponents_PayrollId");

            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.ComponentName).HasMaxLength(100);

            entity.HasOne(d => d.Payroll).WithMany(p => p.SalaryComponents)
                .HasForeignKey(d => d.PayrollId)
                .HasConstraintName("FK__SalaryCom__Payro__5EBF139D");
        });

        modelBuilder.Entity<VwEmployeeSalarySlip>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_EmployeeSalarySlip");

            entity.Property(e => e.BasicSalary).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Deductions).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.DepartmentName)
                .HasMaxLength(100)
                .HasColumnName("DEpartmentName");
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.NetSalary).HasColumnType("decimal(21, 2)");
        });

        modelBuilder.Entity<VwLeaveRequestDetail>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_LeaveRequestDetails");

            entity.Property(e => e.ApprovedBy).HasMaxLength(100);
            entity.Property(e => e.DepartmentName).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.Status).HasMaxLength(20);
        });

        modelBuilder.Entity<VwMonthlyAttendanceSummary>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_MonthlyAttendanceSummary");

            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.MonthName).HasMaxLength(30);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
