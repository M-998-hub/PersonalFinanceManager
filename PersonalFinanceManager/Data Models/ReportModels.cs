using System;
using System.Collections.Generic;

namespace PersonalFinanceManager.Models
{
    public class MonthlyReport
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public decimal TotalIncome { get; set; }
        public decimal TotalExpense { get; set; }
        public decimal NetBalance => TotalIncome - TotalExpense;
        public int TransactionCount { get; set; }
        public List<CategorySummary> TopIncomeCategories { get; set; } = new();
        public List<CategorySummary> TopExpenseCategories { get; set; } = new();
    }

    public class CategorySummary
    {
        public string Category { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public decimal Percentage { get; set; }
    }

    public class TrendReport
    {
        public int Year { get; set; }
        public Dictionary<int, MonthlySummary> MonthlyData { get; set; } = new();
    }

    public class MonthlySummary
    {
        public decimal Income { get; set; }
        public decimal Expense { get; set; }
        public decimal Balance => Income - Expense;
    }
}