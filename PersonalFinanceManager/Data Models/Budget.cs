namespace PersonalFinanceManager.Models
{
    public class Budget
    {
        public int Id { get; set; }
        public string Category { get; set; }
        public decimal MonthlyLimit { get; set; }
        public DateTime CreatedAt { get; set; }
        
        public Budget()
        {
            Category = string.Empty;
            MonthlyLimit = 0;
            CreatedAt = DateTime.Now;
        }
        
        // 可选：添加便利构造函数
        public Budget(string category, decimal monthlyLimit)
        {
            Category = category;
            MonthlyLimit = monthlyLimit;
            CreatedAt = DateTime.Now;
        }
    }
}