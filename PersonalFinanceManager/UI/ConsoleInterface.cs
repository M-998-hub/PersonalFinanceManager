using PersonalFinanceManager.Services;
using System;

namespace PersonalFinanceManager.UI
{
    public class ConsoleInterface
    {
        private readonly FinanceManager _manager;

        public ConsoleInterface(FinanceManager manager)
        {
            _manager = manager;
        }
        
        // 主运行方法
        public void Run()
        {
            bool exit = false;

            while(!exit)
            {
                ShowMainMenu();
                var input = Console.ReadLine();

                switch (input)
                {
                    case "1":
                        AddNewIncome();  // 调用添加收入方法
                        break;
                    case "2":
                        AddNewExpense(); // 调用添加支出方法
                        break;
                    case "3":
                        ShowBalance();   // 调用显示余额方法
                        break;
                    case "4":
                        exit = true;
                        Console.WriteLine("感谢使用！再见！");
                        break;
                    default:
                        Console.WriteLine("无效选择，请重新输入。");
                        break;
                }

                if(!exit)
                {
                    Console.WriteLine("按任意键继续...");
                    Console.ReadKey();
                    Console.Clear();
                }
            }
        }

        public void ShowMainMenu()
        {
            System.Console.WriteLine("=== 个人财务管理系统 ===");
            System.Console.WriteLine("1. 添加收入");
            System.Console.WriteLine("2. 添加支出");
            System.Console.WriteLine("3. 查看余额");
            System.Console.WriteLine("4. 退出");
            System.Console.Write("请选择操作: ");
        }

        public void AddNewIncome()
        {
            try
            {
                Console.WriteLine("\n--- 添加收入 ---");

                Console.Write("请输入金额: ");
                decimal amount = decimal.Parse(Console.ReadLine());

                Console.Write("请输入类别: ");
                string category = Console.ReadLine();

                Console.Write("请输入描述: ");
                string description = Console.ReadLine();

                // 调用业务逻辑层
                _manager.AddIncome(amount, category, description);

                Console.WriteLine("✅ 收入添加成功！");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 错误: {ex.Message}");
            }
        }

        // 新增：添加支出方法
        public void AddNewExpense()
        {
            try
            {
                Console.WriteLine("\n--- 添加支出 ---");

                Console.Write("请输入金额: ");
                decimal amount = decimal.Parse(Console.ReadLine());

                Console.Write("请输入类别: ");
                string category = Console.ReadLine();

                Console.Write("请输入描述: ");
                string description = Console.ReadLine();

                // 调用业务逻辑层
                _manager.AddExpense(amount, category, description);

                Console.WriteLine("✅ 支出添加成功！");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 错误: {ex.Message}");
            }
        }
        
        // 新增：显示余额方法
        public void ShowBalance()
        {
            try
            {
                Console.WriteLine("\n--- 当前余额 ---");
                
                decimal balance = _manager.GetCurrentBalance();
                Console.WriteLine($"当前余额: {balance:C}");
                
                // 可以添加更多统计信息
                Console.WriteLine("更多统计功能开发中...");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 错误: {ex.Message}");
            }
        }
    }
}