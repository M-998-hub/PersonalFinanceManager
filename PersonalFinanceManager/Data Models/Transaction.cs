using System;

namespace PersonalFinanceManager.Models
{
    public class Transaction
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public decimal Amount { get; set; }
        public string Category { get; set; }
        public string Description { get; set; }
        public TransactionType Type { get; set; }
        
        // 添加构造函数，初始化属性
        public Transaction()
        {
            Category = string.Empty;
            Description = string.Empty;
            Date = DateTime.Now;
        }
    }
}