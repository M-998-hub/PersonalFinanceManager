using Microsoft.EntityFrameworkCore;
using PersonalFinanceManager.Models;

namespace PersonalFinanceManager.Data
{
    public class FinanceDbContext : DbContext
    {
        public DbSet<Transaction> Transactions { get; set; }
        public DbSet<Budget> Budgets { get; set; }

        // 使用完整路径
        private string DatabasePath => Path.Combine(Directory.GetCurrentDirectory(), "Data", "finance.db");

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            // 确保 Data 目录存在
            var dataDir = Path.GetDirectoryName(DatabasePath);
            if (!string.IsNullOrEmpty(dataDir) && !Directory.Exists(dataDir))
            {
                Directory.CreateDirectory(dataDir);
            }

            optionsBuilder.UseSqlite($"Data Source={DatabasePath}");
            
            // 启用详细错误信息（调试用）
            optionsBuilder.EnableSensitiveDataLogging();
            optionsBuilder.EnableDetailedErrors();
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // 配置Transaction表
            modelBuilder.Entity<Transaction>(entity =>
            {
                entity.HasKey(t => t.Id);
                entity.ToTable("Transactions"); // 明确指定表名

                entity.Property(t => t.Amount)
                      .HasColumnType("DECIMAL(18,2)")
                      .IsRequired();

                entity.Property(t => t.Category)
                      .IsRequired()
                      .HasMaxLength(100);

                entity.Property(t => t.Description)
                      .HasMaxLength(500);

                entity.Property(t => t.Date)
                      .IsRequired();

                entity.Property(t => t.Type)
                      .IsRequired()
                      .HasConversion<string>();

                // 创建索引
                entity.HasIndex(t => t.Date);
                entity.HasIndex(t => t.Category);
                entity.HasIndex(t => t.Type);
            });

            // 配置Budget表
            modelBuilder.Entity<Budget>(entity =>
            {
                entity.HasKey(b => b.Id);
                entity.ToTable("Budgets"); // 明确指定表名

                entity.Property(b => b.Category)
                      .IsRequired()
                      .HasMaxLength(100);
                      
                entity.Property(b => b.MonthlyLimit)
                      .HasColumnType("DECIMAL(18,2)");

                entity.HasIndex(b => b.Category);
            });
        }
    }
}