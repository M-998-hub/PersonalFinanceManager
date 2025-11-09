using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using PersonalFinanceManager.Models;

namespace PersonalFinanceManager.Data
{
    public class JsonFileRepository : IDataRepository
    {
        private readonly string _dataDirectory = "DataFiles";
        private readonly string _transactionsFile = "DataFiles/transactions.json";
        private readonly string _budgetsFile = "DataFiles/budgets.json";

        public JsonFileRepository()
        {
            // 确保数据目录存在
            if (!Directory.Exists(_dataDirectory))
            {
                Directory.CreateDirectory(_dataDirectory);
            }
        }
        
        // 具体的数据存储实现
        public void AddTransaction(Transaction transaction)
        {

            // 获取现有交易列表
            var transactions = GetAllTransactions().ToList();

            if (transactions.Count > 0)
            {
                transaction.Id = transactions.Count + 1;
            }
            else
            {
                transaction.Id = 1;
            }

            transactions.Add(transaction);

            // 保存到文件
            SaveTransactionsToFile(transactions);
        }

        public void DeleteTransaction(int id)
        {
            var transactions = GetAllTransactions().ToList();
            var transactionToRemove = transactions.FirstOrDefault(t => t.Id == id);
            if (transactionToRemove != null)
            {
                transactions.Remove(transactionToRemove);
                SaveTransactionsToFile(transactions);
            }
        }

        public IEnumerable<Transaction> GetAllTransactions()
        {
            if (!File.Exists(_transactionsFile))
            {
                return new List<Transaction>();
            }

            var json = File.ReadAllText(_transactionsFile);
            if (string.IsNullOrEmpty(json))
            {
                return new List<Transaction>();
            }

            return JsonSerializer.Deserialize<List<Transaction>>(json) ?? new List<Transaction>();
        }
        
        public IEnumerable<Transaction> GetTransactionsByCategory(string category)
        {
            var transactions = GetAllTransactions();
            return transactions.Where(t => t.Category == category).ToList();
        }
        public IEnumerable<Transaction> GetTransactionsByDate(System.DateTime start, System.DateTime end)
        {
            var transactions = GetAllTransactions();
            return transactions.Where(t => t.Date >= start && t.Date <= end).ToList();
        }
        
        public void SaveBudget(Budget budget)
        {
            var budgets = GetAllBudgets().ToList();
            var existingBudget = budgets.FirstOrDefault(b => b.Category == budget.Category);

            if (existingBudget != null)
            {
                budgets.Remove(existingBudget);
            }

            budgets.Add(budget);
            SaveBudgetToFile(budgets);
        }
        
        public Budget GetBudget(string category)
        {
            var budgets = GetAllBudgets();
            return budgets.FirstOrDefault(b => b.Category == category) ?? new Budget();
        }

        public IEnumerable<Budget> GetAllBudgets()
        {
            if (!File.Exists(_budgetsFile))
            {
                return new List<Budget>();
            }

            var json = File.ReadAllText(_budgetsFile);
            if (string.IsNullOrEmpty(json))
            {
                return new List<Budget>();
            }

            return JsonSerializer.Deserialize<List<Budget>>(json) ?? new List<Budget>();
        }

        private void SaveTransactionsToFile(List<Transaction> transactions)
        {
            var options = new JsonSerializerOptions { WriteIndented = true };
            var json = JsonSerializer.Serialize(transactions, options);
            File.WriteAllText(_transactionsFile, json);
        }
        
        private void SaveBudgetToFile(List<Budget> budgets)
        {
            var options = new JsonSerializerOptions { WriteIndented = true };
            var json = JsonSerializer.Serialize(budgets, options);
            File.WriteAllText(_budgetsFile, json);
        }
    }
}