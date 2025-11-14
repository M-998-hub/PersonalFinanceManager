using System.Collections.Generic;
using System.Linq;
using System.ComponentModel;
using System.Data;
using PersonalFinanceManager.Data;
using PersonalFinanceManager.Models;
using System;

namespace PersonalFinanceManager.Services
{
    public class FinanceManager
    {
        private readonly IDataRepository _repository;

        public FinanceManager(IDataRepository repository)
        {
            _repository = repository;
        }


        #region 数据查询(Data-Query)
        public IEnumerable<Transaction> GetAllTransactions()
        {
            return _repository.GetAllTransactions();
        }
        public IEnumerable<Transaction> GetTransactionsByCategory(string category)
        {
            return _repository.GetAllTransactions()
                             .Where(t => t.Category.Contains(category))
                             .OrderByDescending(t => t.Date);
        }
        public IEnumerable<Transaction> GetTransactionsByDate(DateTime start, DateTime end)
        {
            return _repository.GetAllTransactions()
                             .Where(t => t.Date >= start && t.Date <= end)
                             .OrderByDescending(t => t.Date);
        }
        public IEnumerable<Transaction> GetTransactionsByType(TransactionType type)
        {
            return _repository.GetAllTransactions()
                             .Where(t => t.Type == type)
                             .OrderByDescending(t => t.Date);
        }
        public decimal GetCurrentBalance()
        {
            var transaction = _repository.GetAllTransactions();
            var income = transaction.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount);
            var expense = transaction.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);
            return income - expense;
        }
        #endregion

        #region 交易管理(TranasctionManager)
        public void AddIncome(decimal amount, string category, string description)
        {
            //业务逻辑：验证金额不能为负数
            if (amount <= 0) throw new ArgumentException("金额必须大于0");
            if (string.IsNullOrEmpty(category)) throw new ArgumentException("类别不能为空");

            //业务逻辑：创建交易对象
            var transaction = new Transaction
            {
                Amount = amount,
                Category = category,
                Description = description,
                Type = TransactionType.Income,
                Date = DateTime.Now
            };

            //不直接保存，委托给数据层
            _repository.AddTransaction(transaction);
        }
        public void AddExpense(decimal amount, string category, string description)
        {
            if (amount <= 0) throw new ArgumentException("金额必须大于0");
            if (string.IsNullOrEmpty(category)) throw new ArgumentException("类别不能为空");

            var transaction = new Transaction
            {
                Amount = amount,
                Category = category,
                Description = description,
                Type = TransactionType.Expense,
                Date = DateTime.Now
            };

            _repository.AddTransaction(transaction);
        }
        public void UpdateTransaction(Transaction transaction)
        {
            _repository.UpdateTransaction(transaction);
        }
        public void DeleteTransaction(int id)
        {
            _repository.DeleteTransaction(id);
        }
        #endregion


        #region 统计报表(StatisticalReportForm)
        public MonthlyReport GetMonthlyReport(int year, int month)
        {
            if (month < 1 || month > 12)
                throw new ArgumentException("月份必须在1-12之间");

            var monthlyTransactions = _repository.GetAllTransactions()
                .Where(t => t.Date.Year == year && t.Date.Month == month)
                .ToList();

            var incomeTransactions = monthlyTransactions.Where(t => t.Type == TransactionType.Income).ToList();
            var expenseTransactions = monthlyTransactions.Where(t => t.Type == TransactionType.Expense).ToList();

            var totalIncome = incomeTransactions.Sum(t => t.Amount);
            var totalExpense = expenseTransactions.Sum(t => t.Amount);

            return new MonthlyReport
            {
                Year = year,
                Month = month,
                TotalIncome = totalIncome,
                TotalExpense = totalExpense,
                TransactionCount = monthlyTransactions.Count,
                TopIncomeCategories = GetTopCategories(incomeTransactions, totalIncome, 3),
                TopExpenseCategories = GetTopCategories(expenseTransactions, totalExpense, 5)
            };
        }
        public TrendReport GetYearlyTrendReport(int year)
        {
            var yearlyTransactions = _repository.GetAllTransactions()
                .Where(t => t.Date.Year == year)
                .ToList();

            var trendReport = new TrendReport { Year = year };

            for (int month = 1; month <= 12; month++)
            {
                var monthlyData = yearlyTransactions
                    .Where(t => t.Date.Month == month)
                    .ToList();

                trendReport.MonthlyData[month] = new MonthlySummary
                {
                    Income = monthlyData.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount),
                    Expense = monthlyData.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount)
                };
            }

            return trendReport;
        }
        public Dictionary<string, decimal> GetCategoryAnalysis(DateTime? startDate = null, DateTime? endDate = null)
        {
            var transactions = _repository.GetAllTransactions();

            if (startDate.HasValue)
                transactions = transactions.Where(t => t.Date >= startDate.Value);
            if (endDate.HasValue)
                transactions = transactions.Where(t => t.Date <= endDate.Value);

            return transactions
                .GroupBy(t => t.Category)
                .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount))
                .OrderByDescending(kv => kv.Value)
                .ToDictionary(kv => kv.Key, kv => kv.Value);
        }
        private List<CategorySummary> GetTopCategories(List<Transaction> transactions, decimal total, int topCount)
        {
            if (total == 0) return new List<CategorySummary>();

            return transactions
                .GroupBy(t => t.Category)
                .Select(g => new CategorySummary
                {
                    Category = g.Key,
                    Amount = g.Sum(t => t.Amount),
                    Percentage = total > 0 ? (g.Sum(t => t.Amount) / total) * 100 : 0
                })
                .OrderByDescending(c => c.Amount)
                .Take(topCount)
                .ToList();
        }
        #endregion


        #region 预算管理(BudgetManager)
        public void SetBudget(string category, decimal monthlyLimit)
        {
            if (string.IsNullOrWhiteSpace(category))
                throw new ArgumentException("类别不能为空");

            if (monthlyLimit <= 0)
                throw new ArgumentException("预算限额必须大于0");

            var budget = new Budget
            {
                Category = category.Trim(),
                MonthlyLimit = monthlyLimit
            };

            _repository.SaveBudget(budget);
        }
        public Budget? GetBudget(string category)
        {
            return _repository.GetBudget(category);
        }
        public IEnumerable<Budget> GetAllBudgets()
        {
            return _repository.GetAllBudgets();
        }
        public void DeleteBudget(string category)
        {
            _repository.DeleteBudget(category);
        }
        public List<BudgetAlert> CheckBudgetAlerts(DateTime month)
        {
            var alerts = new List<BudgetAlert>();
            var budgets = _repository.GetAllBudgets();
            var transactions = _repository.GetAllTransactions();

            // 计算指定月份的支出
            var monthlyExpenses = transactions
                .Where(t => t.Type == TransactionType.Expense &&
                           t.Date.Year == month.Year &&
                           t.Date.Month == month.Month)
                .GroupBy(t => t.Category)
                .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));

            foreach (var budget in budgets)
            {
                if (monthlyExpenses.ContainsKey(budget.Category))
                {
                    var spending = monthlyExpenses[budget.Category];
                    var percentage = (spending / budget.MonthlyLimit) * 100;

                    if (spending > budget.MonthlyLimit)
                    {
                        alerts.Add(new BudgetAlert
                        {
                            Category = budget.Category,
                            BudgetLimit = budget.MonthlyLimit,
                            ActualSpending = spending,
                            OverAmount = spending - budget.MonthlyLimit,
                            AlertLevel = AlertLevel.OverBudget
                        });
                    }
                    else if (percentage >= 80) // 达到80%时预警
                    {
                        alerts.Add(new BudgetAlert
                        {
                            Category = budget.Category,
                            BudgetLimit = budget.MonthlyLimit,
                            ActualSpending = spending,
                            OverAmount = 0,
                            AlertLevel = AlertLevel.NearLimit
                        });
                    }
                }
            }

            return alerts;
        }
        #endregion
    }
}