using Microsoft.EntityFrameworkCore; // 添加这个
using PersonalFinanceManager.Data;
using PersonalFinanceManager.Services;
using PersonalFinanceManager.UI;

namespace PersonalFinanceManager
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("应用程序启动...");
                
                // 先初始化数据库
                InitializeDatabase();

                // 只有在需要测试时才取消注释下面这行
                // ResetDatabaseForTesting();
                
                // 创建数据仓库和业务逻辑
                IDataRepository repository = new SqliteRepository();
                FinanceManager manager = new FinanceManager(repository);

                // 快速功能测试(可选)
                //QuickTest(manager);

                ConsoleInterface ui = new ConsoleInterface(manager);
                ui.Run();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"程序启动失败: {ex.Message}");
                Console.WriteLine($"详细错误: {ex.InnerException?.Message ?? ex.Message}");
                Console.ReadKey();
            }
        }

        static void InitializeDatabase()
        {
            try
            {
                Console.WriteLine("正在创建数据库和表...");
                
                using var dbContext = new FinanceDbContext();
                
                
                // 创建数据库和表
                dbContext.Database.EnsureCreated();

                Console.WriteLine("✅ 数据库初始化成功");
                
                // 显示当前数据状态
                var transactionCount = dbContext.Transactions.Count();
                Console.WriteLine($"当前交易记录数: {transactionCount}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 数据库初始化失败: {ex.Message}");
                Console.WriteLine($"详细错误: {ex}");
                throw;
            }
        }

        static void ResetDatabaseForTesting()
        {
            try
            {
                Console.WriteLine("⚠️  警告：这将删除所有数据！");
                Console.WriteLine("按 Y 确认重置，其他键取消...");
                if (Console.ReadKey().Key != ConsoleKey.Y)
                {
                    Console.WriteLine("\n取消重置");
                    return;
                }
                
                Console.WriteLine("\n正在重置数据库...");
                using var dbContext = new FinanceDbContext();
                dbContext.Database.EnsureDeleted();
                dbContext.Database.EnsureCreated();
                Console.WriteLine("✅ 数据库已重置为初始状态");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 重置失败: {ex.Message}");
            }
        }

        static void QuickTest(FinanceManager manager)
        {
            try
            {
                Console.WriteLine("=== 快速功能测试 ===");

                // 测试添加交易
                manager.AddIncome(1000, "工资", "月薪");
                manager.AddExpense(50, "餐饮", "午餐");
                Console.WriteLine("✅ 交易添加测试通过");

                // 测试查询
                var allTransactions = manager.GetAllTransactions();
                Console.WriteLine($"总交易数: {allTransactions.Count()}");

                var foodTransactions = manager.GetTransactionsByCategory("餐饮");
                Console.WriteLine($"餐饮支出: {foodTransactions.Count()}笔");

                Console.WriteLine("✅ 查询功能测试通过\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 测试失败: {ex.Message}");
                throw;
            }
        }
    }
}