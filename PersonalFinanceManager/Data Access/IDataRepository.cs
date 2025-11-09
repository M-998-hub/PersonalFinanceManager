using System.Collections.Generic;
using PersonalFinanceManager.Models;

namespace PersonalFinanceManager.Data
{
    public interface IDataRepository
    {
        // 数据持久化操作
        void AddTransaction(Transaction transaction);
        void DeleteTransaction(int id);
        IEnumerable<Transaction> GetAllTransactions();
        IEnumerable<Transaction> GetTransactionsByCategory(string category);
        IEnumerable<Transaction> GetTransactionsByDate(System.DateTime start, System.DateTime end);
        
        // 预算操作
        void SaveBudget(Budget budget);
        Budget GetBudget(string category);
        IEnumerable<Budget> GetAllBudgets();
    }
}