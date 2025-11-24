using PersonalFinanceManager.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;  // 为了 Thread.Sleep
using PersonalFinanceManager.Data;
using PersonalFinanceManager.Models;

namespace PersonalFinanceManager.UI
{
    public class ConsoleInterface
    {
        private readonly FinanceManager _manager;
        private bool _isRunning;

        public ConsoleInterface(FinanceManager manager)
        {
            // 默认使用数据库，但保留切换到JSON的能力
            var useDatabase = true; // 可以通过配置控制

            IDataRepository repository = useDatabase
                ? new SqliteRepository()
                : new JsonFileRepository();

            _manager = new FinanceManager(repository);
            _isRunning = true;
        }

        #region 主流程(MainProcess)
        public void Run()
        {
            while (_isRunning)
            {
                ShowMainMenu();
                HandleMainMenuInput();
            }
        }
        public void ShowMainMenu()
        {
            Console.Clear();
            Console.WriteLine("=== 个人财务管理系统 ===");
            Console.WriteLine("1. 📝 交易管理");
            Console.WriteLine("2. 🔍 数据查询");
            Console.WriteLine("3. 📊 统计报表");
            Console.WriteLine("4. 💰 预算管理");
            Console.WriteLine("5. 🚪 退出系统");
            Console.Write("请选择操作: ");
        }
        private void HandleMainMenuInput()
        {
            var input = Console.ReadLine();
            switch (input)
            {
                case "1": ShowTransactionMenu(); break;
                case "2": ShowQueryMenu(); break;
                case "3": ShowReportMenu(); break;
                case "4": ShowBudgetMenu(); break;
                case "5": Exit(); break;
                default: ShowInvalidInputMessage(); break;
            }
        }
        #endregion

        #region 工具方法(ToolMethod)
        private void ShowInvalidInputMessage()
        {
            Console.WriteLine("❌ 输入无效，请重新选择！");
            Console.Beep(); // 可选：添加提示音
            Thread.Sleep(1000); // 暂停1秒，让用户看到错误信息
        }
        private void DisplayTransactions(IEnumerable<Transaction> transactions, string title)
        {
            Console.Clear();
            Console.WriteLine($"=== {title} ===");
            Console.WriteLine("=".PadRight(60, '='));

            if (!transactions.Any())
            {
                Console.WriteLine("📭 没有找到交易记录");
                return;
            }

            // 表头
            Console.WriteLine($"{"ID",-4} {"日期",-12} {"类型",-8} {"金额",-12} {"类别",-12} {"描述"}");
            Console.WriteLine("-".PadRight(60, '-'));

            // 表格内容
            foreach (var transaction in transactions)
            {

                string amountText = transaction.Amount.ToString("C");
                string dateText = transaction.Date.ToString("MM/dd HH:mm");
                string typeText = transaction.Type == TransactionType.Income ? "💰 收入" : "💸 支出";

                Console.WriteLine($"{transaction.Id,-4} {dateText,-12} {typeText,-8} {amountText,-12} {transaction.Category,-12} {transaction.Description}");
            }

            // 统计信息
            Console.WriteLine("-".PadRight(60, '-'));
            decimal totalAmount = transactions.Sum(t => t.Amount);
            int count = transactions.Count();

            Console.WriteLine($"总计: {totalAmount:C} | 记录数: {count}");
        }
        // 重载版本，用于显示简单的交易列表（不带统计）
        private void DisplaySimpleTransactions(IEnumerable<Transaction> transactions, string title)
        {
            Console.Clear();
            Console.WriteLine($"=== {title} ===");

            if (!transactions.Any())
            {
                Console.WriteLine("📭 没有找到交易记录");
                return;
            }

            foreach (var transaction in transactions)
            {
                string typeIcon = transaction.Type == TransactionType.Income ? "💰" : "💸";
                Console.WriteLine($"{typeIcon} [{transaction.Id}] {transaction.Date:MM/dd} {transaction.Amount:C} - {transaction.Category} - {transaction.Description}");
            }
        }
        private void Exit()
        {
            Console.WriteLine("感谢使用个人财务管理系统！再见！👋");
            _isRunning = false;
        }
        private void WaitForAnyKey()
        {
            Console.WriteLine("\n按任意键继续...");
            Console.ReadKey();
        }
        private void ShowSuccessMessage(string message)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"✅ {message}");
            Console.ResetColor();
        }
        private void ShowErrorMessage(string message)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"❌ {message}");
            Console.ResetColor();
        }
        private void ShowWarningMessage(string message)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"⚠️ {message}");
            Console.ResetColor();
        }
        private void ShowInfoMessage(string message)
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine($"ℹ️ {message}");
            Console.ResetColor();
        }
        private bool ConfirmAction(string message)
        {
            Console.Write($"\n⚠️ {message} (y/n): ");
            var input = Console.ReadLine()?.Trim().ToLower();

            // 默认选择"否"以保护用户数据
            if (string.IsNullOrEmpty(input))
            {
                ShowInfoMessage("操作已取消");
                return false;
            }

            return input == "y" || input == "yes" || input == "是";
        }
        private bool ConfirmDangerousAction(string message)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Write($"\n🚨 {message} (输入 'DELETE' 确认): ");
            Console.ResetColor();

            var input = Console.ReadLine()?.Trim();
            return input == "DELETE";
        }
        private void DisplayMonthlyReport(MonthlyReport report)
        {
            Console.Clear();
            Console.WriteLine("=== 📅 月度收支统计 ===");
            Console.WriteLine("=".PadRight(50, '='));

            Console.WriteLine($"统计期间: {report.Year}年{report.Month}月");
            Console.WriteLine($"总交易笔数: {report.TransactionCount} 笔");
            Console.WriteLine();

            // 收入支出概览
            Console.WriteLine($"💰 总收入: {report.TotalIncome:C}");
            Console.WriteLine($"💸 总支出: {report.TotalExpense:C}");
            Console.WriteLine($"💳 净余额: {report.NetBalance:C}");

            // 余额状态
            string balanceStatus = report.NetBalance > 0 ? "盈余 🎉" :
                                  report.NetBalance < 0 ? "赤字 ⚠️" : "收支平衡 ⚖️";
            Console.WriteLine($"📊 财务状况: {balanceStatus}");
            Console.WriteLine();

            // 收入类别分析
            if (report.TopIncomeCategories.Any())
            {
                Console.WriteLine("🏆 主要收入来源:");
                foreach (var category in report.TopIncomeCategories)
                {
                    Console.WriteLine($"  {category.Category}: {category.Amount:C} ({category.Percentage:F1}%)");
                }
                Console.WriteLine();
            }

            // 支出类别分析
            if (report.TopExpenseCategories.Any())
            {
                Console.WriteLine("📋 主要支出类别:");
                foreach (var category in report.TopExpenseCategories)
                {
                    Console.WriteLine($"  {category.Category}: {category.Amount:C} ({category.Percentage:F1}%)");
                }
            }
        }
        private void DisplayYearlyTrendReport(TrendReport report)
        {
            Console.Clear();
            Console.WriteLine($"=== 📈 {report.Year}年度趋势分析 ===");
            Console.WriteLine("=".PadRight(60, '='));

            Console.WriteLine($"{"月份",-8} {"收入",-12} {"支出",-12} {"余额",-12} {"状态",-8}");
            Console.WriteLine("-".PadRight(60, '-'));

            for (int month = 1; month <= 12; month++)
            {
                if (report.MonthlyData.ContainsKey(month))
                {
                    var data = report.MonthlyData[month];
                    string status = data.Balance > 0 ? "盈余" : data.Balance < 0 ? "赤字" : "平衡";
                    string statusIcon = data.Balance > 0 ? "📈" : data.Balance < 0 ? "📉" : "➖";

                    Console.WriteLine($"{month,2}月     {data.Income,-12:C} {data.Expense,-12:C} {data.Balance,-12:C} {statusIcon} {status}");
                }
            }

            // 年度汇总
            var totalIncome = report.MonthlyData.Values.Sum(m => m.Income);
            var totalExpense = report.MonthlyData.Values.Sum(m => m.Expense);
            var totalBalance = totalIncome - totalExpense;

            Console.WriteLine("-".PadRight(60, '-'));
            Console.WriteLine($"{"年度汇总",-8} {totalIncome,-12:C} {totalExpense,-12:C} {totalBalance,-12:C}");
        }
        private void DisplayCategoryAnalysis(Dictionary<string, decimal> analysis)
        {
            Console.Clear();
            Console.WriteLine("=== 🏷️ 类别占比分析 ===");
            Console.WriteLine("=".PadRight(40, '='));

            if (!analysis.Any())
            {
                Console.WriteLine("📭 没有找到交易数据");
                return;
            }

            var total = analysis.Values.Sum();

            Console.WriteLine($"{"类别",-15} {"金额",-12} {"占比",-8}");
            Console.WriteLine("-".PadRight(40, '-'));

            foreach (var item in analysis)
            {
                decimal percentage = total > 0 ? (item.Value / total) * 100 : 0;
                Console.WriteLine($"{item.Key,-15} {item.Value,-12:C} {percentage,6:F1}%");
            }

            Console.WriteLine("-".PadRight(40, '-'));
            Console.WriteLine($"{"总计",-15} {total,-12:C} {"100.0%",-8}");
        }
        private void DisplayQuickBalance(List<Transaction> transactions, MonthlyReport monthlyReport, decimal balance)
        {
            Console.Clear();
            Console.WriteLine("=== 💰 快速余额统计 ===");
            Console.WriteLine("=".PadRight(40, '='));

            // 总体统计
            Console.WriteLine($"💳 当前总余额: {balance:C}");
            Console.WriteLine($"📊 总交易笔数: {transactions.Count} 笔");
            Console.WriteLine();

            // 本月统计
            Console.WriteLine($"📅 本月统计 ({DateTime.Now:yyyy年MM月}):");
            Console.WriteLine($"  💰 收入: {monthlyReport.TotalIncome:C}");
            Console.WriteLine($"  💸 支出: {monthlyReport.TotalExpense:C}");
            Console.WriteLine($"  ⚖️ 净额: {monthlyReport.NetBalance:C}");
            Console.WriteLine();

            // 简单建议
            if (monthlyReport.NetBalance < 0)
            {
                Console.WriteLine("💡 建议: 本月支出超过收入，注意控制开销！");
            }
            else if (monthlyReport.NetBalance > monthlyReport.TotalIncome * 0.3m)
            {
                Console.WriteLine("💡 很棒！储蓄率很高，继续保持！");
            }
        }
        public class BudgetAlert
        {
            public string Category { get; set; } = string.Empty;
            public decimal BudgetLimit { get; set; }
            public decimal ActualSpending { get; set; }
            public decimal OverAmount { get; set; }
            public AlertLevel AlertLevel { get; set; }
        }
        #endregion

        #region 交易管理(TranasctionManager)
        private void ShowTransactionMenu()
        {
            bool inQueryMenu = true;

            while (inQueryMenu)
            {
                Console.Clear();
                Console.WriteLine("=== 交易管理 ===");
                Console.WriteLine("1. 添加收入");
                Console.WriteLine("2. 添加支出");
                Console.WriteLine("3. 查看余额");
                Console.WriteLine("4. 编辑交易");
                Console.WriteLine("5. 删除交易");
                Console.WriteLine("6. 返回主菜单");
                Console.Write("请选择操作: ");

                var input = Console.ReadLine();
                switch (input)
                {
                    case "1": AddNewIncome(); break;
                    case "2": AddNewExpense(); break;
                    case "3": ShowBalance(); break;
                    case "4": EditTransaction(); break;
                    case "5": DeleteTransaction(); break;
                    case "6": inQueryMenu = false; break;
                    default: ShowInvalidInputMessage(); break;
                }

                if (inQueryMenu && input != "6")
                {
                    Console.WriteLine("\n按任意键继续...");
                    Console.ReadKey();
                }
            }
        }
        private void AddNewIncome()
        {
            try
            {
                Console.WriteLine("\n--- 添加收入 ---");

                Console.Write("请输入金额: ");
                string amountInput = Console.ReadLine();
                if (string.IsNullOrEmpty(amountInput))
                {
                    ShowErrorMessage("金额不能为空");
                    return;
                }

                if (!decimal.TryParse(amountInput, out decimal amount) || amount <= 0)
                {
                    ShowErrorMessage("请输入有效的正数金额");
                    return;
                }

                Console.Write("请输入类别: ");
                string category = Console.ReadLine() ?? "";
                if (string.IsNullOrWhiteSpace(category))
                {
                    ShowErrorMessage("类别不能为空");
                    return;
                }

                Console.Write("请输入描述: ");
                string description = Console.ReadLine() ?? "";

                _manager.AddIncome(amount, category.Trim(), description.Trim());
                ShowSuccessMessage("收入添加成功！");
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"添加失败: {ex.Message}");
            }
        }
        private void AddNewExpense()
        {
            try
            {
                Console.WriteLine("\n--- 添加支出 ---");

                Console.Write("请输入金额: ");
                string amountInput = Console.ReadLine();
                if (string.IsNullOrEmpty(amountInput))
                {
                    ShowErrorMessage("金额不能为空");
                    return;
                }

                if (!decimal.TryParse(amountInput, out decimal amount) || amount <= 0)
                {
                    ShowErrorMessage("请输入有效的正数金额");
                    return;
                }

                Console.Write("请输入类别: ");
                string category = Console.ReadLine() ?? "";
                if (string.IsNullOrWhiteSpace(category))
                {
                    ShowErrorMessage("类别不能为空");
                    return;
                }

                Console.Write("请输入描述: ");
                string description = Console.ReadLine() ?? "";

                _manager.AddExpense(amount, category.Trim(), description.Trim());
                ShowSuccessMessage("支出添加成功！");
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"添加失败: {ex.Message}");
            }
        }
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
        private void EditTransaction()
        {
            try
            {
                // 显示所有交易供选择
                var allTransactions = _manager.GetAllTransactions();
                if (!allTransactions.Any())
                {
                    ShowWarningMessage("📭 当前没有交易记录可编辑");
                    return;
                }

                DisplayTransactions(allTransactions, "所有交易记录");

                Console.WriteLine("\n✏️ 编辑操作说明:");
                Console.WriteLine("• 输入交易ID → 编辑指定交易");
                Console.WriteLine("• 输入 0 或 e → 返回上一级");
                Console.WriteLine("• 直接回车 → 返回上一级");

                Console.Write("\n请选择要编辑的交易ID: ");
                string input = Console.ReadLine()?.Trim().ToLower();

                // 检查返回条件
                if (string.IsNullOrEmpty(input) || input == "0" || input == "e" || input == "exit")
                {
                    ShowInfoMessage("返回上一级");
                    return;
                }

                if (int.TryParse(input, out int transactionId))
                {
                    if (transactionId <= 0)
                    {
                        ShowInfoMessage("返回上一级");
                        return;
                    }

                    var transactionToEdit = allTransactions.FirstOrDefault(t => t.Id == transactionId);
                    if (transactionToEdit != null)
                    {
                        EditTransactionDetails(transactionToEdit);
                    }
                    else
                    {
                        ShowErrorMessage($"未找到ID为 {transactionId} 的交易");
                    }
                }
                else
                {
                    ShowErrorMessage("请输入有效的交易ID或返回指令");
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"编辑失败: {ex.Message}");
            }
        }
        private void EditTransactionDetails(Transaction transaction)
        {
            Console.WriteLine($"\n正在编辑交易: {transaction.Description}");
            Console.WriteLine("=".PadRight(40, '='));

            // 编辑金额
            Console.Write($"新金额 (当前: {transaction.Amount:C}) [直接回车保持原值]: ");
            var amountInput = Console.ReadLine();
            if (!string.IsNullOrEmpty(amountInput) && decimal.TryParse(amountInput, out decimal newAmount))
            {
                transaction.Amount = newAmount;
            }

            // 编辑类别
            Console.Write($"新类别 (当前: {transaction.Category}) [直接回车保持原值]: ");
            var categoryInput = Console.ReadLine();
            if (!string.IsNullOrEmpty(categoryInput))
            {
                transaction.Category = categoryInput;
            }

            // 编辑描述
            Console.Write($"新描述 (当前: {transaction.Description}) [直接回车保持原值]: ");
            var descriptionInput = Console.ReadLine();
            if (!string.IsNullOrEmpty(descriptionInput))
            {
                transaction.Description = descriptionInput;
            }

            // 编辑类型
            Console.WriteLine($"当前类型: {(transaction.Type == TransactionType.Income ? "收入" : "支出")}");
            Console.Write("是否更改类型？(y/n): ");
            var changeType = Console.ReadLine();
            if (changeType?.ToLower() == "y")
            {
                transaction.Type = transaction.Type == TransactionType.Income ? TransactionType.Expense : TransactionType.Income;
            }

            // 保存更改
            _manager.UpdateTransaction(transaction);
            Console.WriteLine("✅ 交易更新成功！");
        }
        private void DeleteTransaction()
        {
            try
            {
                // 先显示所有交易，让用户知道有哪些可以删除
                var allTransactions = _manager.GetAllTransactions();
                if (!allTransactions.Any())
                {
                    ShowWarningMessage("📭 当前没有交易记录可删除");
                    return;
                }

                DisplayTransactions(allTransactions, "所有交易记录");

                Console.WriteLine("\n🗑️ 删除操作说明:");
                Console.WriteLine("• 输入交易ID → 删除指定交易");
                Console.WriteLine("• 输入 0 或 e → 返回上一级");
                Console.WriteLine("• 直接回车 → 返回上一级");

                Console.Write("\n请选择: ");
                string input = Console.ReadLine()?.Trim().ToLower();

                // 检查返回条件
                if (string.IsNullOrEmpty(input) || input == "0" || input == "e" || input == "exit")
                {
                    ShowInfoMessage("返回上一级");
                    return;
                }

                if (int.TryParse(input, out int transactionId))
                {
                    if (transactionId <= 0)
                    {
                        ShowInfoMessage("返回上一级");
                        return;
                    }

                    // 确认要删除的交易是否存在
                    var transactionToDelete = allTransactions.FirstOrDefault(t => t.Id == transactionId);
                    if (transactionToDelete == null)
                    {
                        ShowErrorMessage($"❌ 未找到ID为 {transactionId} 的交易");
                        return;
                    }

                    // 显示要删除的交易详情
                    Console.WriteLine("\n⚠️ 将要删除的交易:");
                    Console.WriteLine($"   ID: {transactionToDelete.Id}");
                    Console.WriteLine($"   日期: {transactionToDelete.Date:yyyy-MM-dd HH:mm}");
                    Console.WriteLine($"   类型: {(transactionToDelete.Type == TransactionType.Income ? "💰 收入" : "💸 支出")}");
                    Console.WriteLine($"   金额: {transactionToDelete.Amount:C}");
                    Console.WriteLine($"   类别: {transactionToDelete.Category}");
                    Console.WriteLine($"   描述: {transactionToDelete.Description}");

                    // 确认删除
                    if (ConfirmAction($"确定要删除这条交易吗？"))
                    {
                        _manager.DeleteTransaction(transactionId);
                        ShowSuccessMessage("交易删除成功！");
                    }
                    else
                    {
                        ShowInfoMessage("取消删除操作");
                    }
                }
                else
                {
                    ShowErrorMessage("❌ 请输入有效的交易ID或返回指令");
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"❌ 删除失败: {ex.Message}");
            }
        }
        #endregion

        #region 数据查询(Data-Query)
        private void ShowQueryMenu()
        {
            bool inQueryMenu = true;

            while (inQueryMenu)
            {
                Console.Clear();
                Console.WriteLine("=== 数据查询 ===");
                Console.WriteLine("1. 📂 按类别查询");
                Console.WriteLine("2. 📅 按时间查询");
                Console.WriteLine("3. 🔄 按类型查询(收入/支出)");
                Console.WriteLine("4. 📋 显示所有交易");
                Console.WriteLine("5. ↩️ 返回主菜单");
                Console.Write("请选择查询方式: ");

                var input = Console.ReadLine();
                switch (input)
                {
                    case "1": QueryByCategory(); break;
                    case "2": QueryByDate(); break;
                    case "3": QueryByType(); break;
                    case "4": QueryAllTransactions(); break;
                    case "5": inQueryMenu = false; break;
                    default: ShowInvalidInputMessage(); break;
                }

                if (inQueryMenu && input != "5")
                {
                    Console.WriteLine("\n按任意键继续...");
                    Console.ReadKey();
                }
            }
        }
        private void QueryByCategory()
        {
            Console.Write("请输入要查询的类别: ");
            string category = Console.ReadLine() ?? "";

            if (string.IsNullOrWhiteSpace(category))
            {
                ShowErrorMessage("类别不能为空");
                return;
            }

            var transactions = _manager.GetTransactionsByCategory(category.Trim());
            DisplayTransactions(transactions, $"类别: {category}");
        }
        private void QueryByDate()
        {
            try
            {
                Console.Write("请输入开始日期 (yyyy-MM-dd): ");
                string startInput = Console.ReadLine();
                if (string.IsNullOrEmpty(startInput))
                {
                    ShowErrorMessage("开始日期不能为空");
                    return;
                }

                Console.Write("请输入结束日期 (yyyy-MM-dd): ");
                string endInput = Console.ReadLine();
                if (string.IsNullOrEmpty(endInput))
                {
                    ShowErrorMessage("结束日期不能为空");
                    return;
                }

                DateTime startDate = DateTime.Parse(startInput);
                DateTime endDate = DateTime.Parse(endInput);

                var transactions = _manager.GetTransactionsByDate(startDate, endDate);
                DisplayTransactions(transactions, $"时间段: {startDate:yyyy-MM-dd} 到 {endDate:yyyy-MM-dd}");
            }
            catch (FormatException)
            {
                ShowErrorMessage("日期格式不正确，请使用 yyyy-MM-dd 格式");
            }
        }
        private void QueryByType()
        {
            Console.WriteLine("选择类型: 1. 收入 2. 支出");
            var typeInput = Console.ReadLine();

            TransactionType type = typeInput == "1" ? TransactionType.Income : TransactionType.Expense;
            var transactions = _manager.GetTransactionsByType(type);

            string typeName = type == TransactionType.Income ? "收入" : "支出";
            DisplayTransactions(transactions, $"类型: {typeName}");
        }
        private void QueryAllTransactions()
        {
            var allTransactions = _manager.GetAllTransactions();
            DisplayTransactions(allTransactions, "所有交易记录");
        }
        #endregion

        #region 统计报表(StatisticalReportForm)
        private void ShowReportMenu()
        {
            bool inReportMenu = true;

            while (inReportMenu)
            {
                Console.Clear();
                Console.WriteLine("=== 📊 统计报表 ===");
                Console.WriteLine("1. 📅 月度收支统计");
                Console.WriteLine("2. 📈 年度趋势分析");
                Console.WriteLine("3. 🏷️ 类别占比分析");
                Console.WriteLine("4. 💰 快速余额统计");
                Console.WriteLine("5. ↩️ 返回主菜单");
                Console.Write("请选择报表类型: ");

                var input = Console.ReadLine();
                switch (input)
                {
                    case "1": ShowMonthlyReport(); break;
                    case "2": ShowYearlyTrendReport(); break;
                    case "3": ShowCategoryAnalysis(); break;
                    case "4": ShowQuickBalance(); break;
                    case "5": inReportMenu = false; break;
                    default: ShowInvalidInputMessage(); break;
                }

                if (inReportMenu && input != "5")
                {
                    WaitForAnyKey();
                }
            }
        }
        private void ShowMonthlyReport()
        {
            try
            {
                Console.Write("请输入年份 (如 2024): ");
                if (!int.TryParse(Console.ReadLine(), out int year) || year < 2000 || year > 2100)
                {
                    ShowErrorMessage("请输入有效的年份 (2000-2100)");
                    return;
                }

                Console.Write("请输入月份 (1-12): ");
                if (!int.TryParse(Console.ReadLine(), out int month) || month < 1 || month > 12)
                {
                    ShowErrorMessage("请输入有效的月份 (1-12)");
                    return;
                }

                var report = _manager.GetMonthlyReport(year, month);
                DisplayMonthlyReport(report);
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"生成报表失败: {ex.Message}");
            }
        }
        private void ShowYearlyTrendReport()
        {
            try
            {
                Console.Write("请输入年份 (如 2024): ");
                if (!int.TryParse(Console.ReadLine(), out int year) || year < 2000 || year > 2100)
                {
                    ShowErrorMessage("请输入有效的年份 (2000-2100)");
                    return;
                }

                var report = _manager.GetYearlyTrendReport(year);
                DisplayYearlyTrendReport(report);
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"生成趋势报告失败: {ex.Message}");
            }
        }
        private void ShowCategoryAnalysis()
        {
            try
            {
                Console.WriteLine("选择分析范围:");
                Console.WriteLine("1. 📊 全部数据");
                Console.WriteLine("2. 📅 指定时间段");

                var choice = Console.ReadLine();
                DateTime? startDate = null;
                DateTime? endDate = null;

                if (choice == "2")
                {
                    Console.Write("开始日期 (yyyy-MM-dd): ");
                    if (DateTime.TryParse(Console.ReadLine(), out DateTime start))
                        startDate = start;

                    Console.Write("结束日期 (yyyy-MM-dd): ");
                    if (DateTime.TryParse(Console.ReadLine(), out DateTime end))
                        endDate = end;
                }

                var analysis = _manager.GetCategoryAnalysis(startDate, endDate);
                DisplayCategoryAnalysis(analysis);
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"类别分析失败: {ex.Message}");
            }
        }
        private void ShowQuickBalance()
        {
            try
            {
                var balance = _manager.GetCurrentBalance();
                var transactions = _manager.GetAllTransactions().ToList();

                var currentMonth = DateTime.Now;
                var monthlyReport = _manager.GetMonthlyReport(currentMonth.Year, currentMonth.Month);

                DisplayQuickBalance(transactions, monthlyReport, balance);
            }
            catch (Exception ex)
            {
                ShowErrorMessage($"快速统计失败: {ex.Message}");
            }
        }
        #endregion

        #region 预算管理(BudgetManager)
        private void ShowBudgetMenu()
        {
            bool inBudgetMenu = true;

            while (inBudgetMenu)
            {
                Console.Clear();
                Console.WriteLine("=== 预算管理 ===");
                Console.WriteLine("1. 📊 设置预算警戒线");
                Console.WriteLine("2. 📋 查看预算限额");
                Console.WriteLine("3. 🚨 检查预算预警");
                Console.WriteLine("4. 🗑️ 删除预算预警");
                Console.WriteLine("5. ↩️ 返回主菜单");
                Console.Write("请选择操作: ");

                var input = Console.ReadLine();
                switch (input)
                {
                    case "1": SetBudget(); break;
                    case "2": ShowAllBudgets(); break;
                    case "3": CheckBudgetAlerts(); break;
                    case "4": DeleteBudget(); break;
                    case "5": inBudgetMenu = false; break;
                    default: ShowInvalidInputMessage(); break;
                }

                if (inBudgetMenu && input != "5")
                {
                    Console.WriteLine("\n按任意键继续...");
                    Console.ReadKey();
                }
            }
        }
        private void SetBudget()
        {
            try
            {
                Console.Write("请输入预算类别: ");
                string category = Console.ReadLine() ?? "";

                Console.Write("请输入月度预算限额: ");
                decimal limit = decimal.Parse(Console.ReadLine() ?? "0");

                _manager.SetBudget(category, limit);
                Console.WriteLine("✅ 预算设置成功！");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 设置预算失败: {ex.Message}");
            }
        }
        private void ShowAllBudgets()
        {
            var budgets = _manager.GetAllBudgets();

            Console.Clear();
            Console.WriteLine("=== 所有预算 ===");
            Console.WriteLine("=".PadRight(40, '='));

            if (!budgets.Any())
            {
                Console.WriteLine("📭 还没有设置任何预算");
                return;
            }

            Console.WriteLine($"{"类别",-15} {"预算限额",-15} {"设置时间"}");
            Console.WriteLine("-".PadRight(40, '-'));

            foreach (var budget in budgets)
            {
                Console.WriteLine($"{budget.Category,-15} {budget.MonthlyLimit,-15:C} {budget.CreatedAt:yyyy-MM-dd}");
            }
        }
        private void CheckBudgetAlerts()
        {
            var alerts = _manager.CheckBudgetAlerts(DateTime.Now);

            Console.Clear();
            Console.WriteLine("=== 预算预警检查 ===");
            Console.WriteLine($"检查时间: {DateTime.Now:yyyy-MM-dd}");
            Console.WriteLine("=".PadRight(50, '='));

            if (!alerts.Any())
            {
                Console.WriteLine("✅ 所有预算都在安全范围内！");
                return;
            }

            foreach (var alert in alerts)
            {
                if (alert.AlertLevel == AlertLevel.OverBudget)
                {
                    Console.WriteLine($"🚨 超预算预警: {alert.Category}");
                    Console.WriteLine($"   预算: {alert.BudgetLimit:C} | 实际: {alert.ActualSpending:C}");
                    Console.WriteLine($"   超支: {alert.OverAmount:C}");
                }
                else
                {
                    Console.WriteLine($"⚠️  预算接近: {alert.Category}");
                    Console.WriteLine($"   预算: {alert.BudgetLimit:C} | 当前: {alert.ActualSpending:C}");
                    Console.WriteLine($"   使用率: {(alert.ActualSpending / alert.BudgetLimit) * 100:F1}%");
                }
                Console.WriteLine();
            }
        }
        private void DeleteBudget()
        {
            try
            {
                Console.Write("请输入要删除的预算类别: ");
                string category = Console.ReadLine() ?? "";

                var budget = _manager.GetBudget(category);
                if (budget == null)
                {
                    Console.WriteLine("❌ 未找到该预算");
                    return;
                }

                Console.Write($"确认删除 {category} 的预算？(y/n): ");
                var confirm = Console.ReadLine()?.ToLower();

                if (confirm == "y")
                {
                    _manager.DeleteBudget(category);
                    Console.WriteLine("✅ 预算删除成功！");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ 删除预算失败: {ex.Message}");
            }
        }
        #endregion
    }
}