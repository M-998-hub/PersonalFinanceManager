using System.Collections.Generic;
using System.Linq;
using System.ComponentModel;
using System.Data;
using PersonalFinanceManager.Data;
using PersonalFinanceManager.Models;

namespace PersonalFinanceManager.Services
{
    public class FinanceManager
    {
        private readonly IDataRepository _repository;
        
        public FinanceManager(IDataRepository repository)
        {
            _repository = repository;
        }

        public void AddIncome(decimal amount, string category, string description)
        {
            //业务逻辑：验证金额不能为负数
            if (amount <= 0) throw new ArgumentException("金额必须大于0");

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
                Type = TransactionType.Income,
                Date = DateTime.Now
            };

            _repository.AddTransaction(transaction);
        }

        // 业务计算方法
        public decimal GetCurrentBalance()
        {
            var transaction = _repository.GetAllTransactions();
            var income = transaction.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount);
            var expense = transaction.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);
            return income - expense;
        }
        
        public decimal GetMonthlyExpense(DateTime month)
        {
            return _repository.GetAllTransactions()
                .Where(t => t.Type == TransactionType.Expense &&
                            t.Date.Month == month.Month &&
                            t.Date.Year == month.Year)
                .Sum(t => t.Amount);
        }
    }
}