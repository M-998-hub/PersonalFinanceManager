// Models/BudgetAlert.cs
using System;

namespace PersonalFinanceManager.Models
{
    public class BudgetAlert
    {
        public string Category { get; set; } = string.Empty;
        public decimal BudgetLimit { get; set; }
        public decimal ActualSpending { get; set; }
        public decimal OverAmount { get; set; }
        public AlertLevel AlertLevel { get; set; }
    }

    public enum AlertLevel
    {
        NearLimit,   // 接近预算
        OverBudget   // 超预算
    }
}