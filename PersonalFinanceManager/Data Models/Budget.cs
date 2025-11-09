namespace PersonalFinanceManager.Models
{
    public class Budget
    {
        public string Category { get; set; }
        public decimal MonthlyLimit { get; set; }
        
        // 添加构造函数
        public Budget()
        {
            Category = string.Empty;
        }
    }
}