using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using PersonalFinanceManager.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;


namespace PersonalFinanceManager.Data
{
    public class JsonFileRepository : IDataRepository
    {
        private readonly string _dataDirectory;
        private readonly string _transactionsFile;
        private readonly string _budgetsFile;

        public JsonFileRepository()
        {
            // 使用应用程序基目录
            var appDirectory = AppDomain.CurrentDomain.BaseDirectory;
            _dataDirectory = Path.Combine(appDirectory, "DataFiles");
            _transactionsFile = Path.Combine(_dataDirectory, "transactions.json");
            _budgetsFile = Path.Combine(_dataDirectory, "budgets.json");

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
                SaveTransactions(transactions);
                Console.WriteLine($"✅ 已删除交易: {transactionToRemove.Description}");
            }
            else
            {
                throw new ArgumentException($"未找到ID为 {id} 的交易");
            }
        }
        public void UpdateTransaction(Transaction updatedTransaction)
        {
            var transactions = GetAllTransactions().ToList();
            var existingTransaction = transactions.FirstOrDefault(t => t.Id == updatedTransaction.Id);

            if (existingTransaction != null)
            {
                // 更新交易信息
                existingTransaction.Amount = updatedTransaction.Amount;
                existingTransaction.Category = updatedTransaction.Category;
                existingTransaction.Description = updatedTransaction.Description;
                existingTransaction.Type = updatedTransaction.Type;
                existingTransaction.Date = DateTime.Now; // 更新修改时间

                SaveTransactions(transactions);
            }
            else
            {
                throw new ArgumentException($"未找到ID为 {updatedTransaction.Id} 的交易");
            }
        }
        // 具体的JSON文件读取实现
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
            return transactions.Where(t => t.Date.Date >= start.Date && t.Date.Date <= end.Date).ToList();
        }

        public IEnumerable<Transaction> GetTransactionsByType(TransactionType type)
        {
            var transactions = GetAllTransactions();
            return transactions.Where(t => t.Type == type).OrderByDescending(t => t.Date);
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

        public void SaveTransactions(IEnumerable<Transaction> transactions)
        {
            SaveTransactionsToFile(transactions.ToList());
        }

        public Budget? GetBudget(string category)
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

            try
            {
                var json = File.ReadAllText(_budgetsFile);
                return JsonSerializer.Deserialize<List<Budget>>(json) ?? new List<Budget>();
            }
            catch (Exception)
            {
                return new List<Budget>();
            }
        }

        public void DeleteBudget(string category)
        {
            var budgets = GetAllBudgets().ToList();
            var budgetToRemove = budgets.FirstOrDefault(b => b.Category == category);

            if (budgetToRemove != null)
            {
                budgets.Remove(budgetToRemove);
                SaveBudgetToFile(budgets);
            }
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

        public void ExportTransactionsToFile(List<Transaction> transactions, string filePath, string format = "json")
        {
            var options = new JsonSerializerOptions { WriteIndented = true };

            if (format.ToLower() == "json")
            {
                var json = JsonSerializer.Serialize(transactions, options);
                File.WriteAllText(filePath, json);
            }
            else if (format.ToLower() == "csv")
            {
                var csv = new StringBuilder();
                csv.AppendLine("ID,Date,Type,Amount,Category,Description");
                foreach (var transaction in transactions)
                {
                    csv.AppendLine($"{transaction.Id},{transaction.Date:yyyy-MM-dd HH:mm},{transaction.Type},{transaction.Amount},{transaction.Category},{transaction.Description}");
                }
                File.WriteAllText(filePath, csv.ToString());
            }
        }

        public void BackupTransactions()
        {
            string backupDir = "Backups";
            if (!Directory.Exists(backupDir))
                Directory.CreateDirectory(backupDir);

            string backupFile = Path.Combine(backupDir, $"transactions_backup_{DateTime.Now:yyyyMMdd_HHmmss}.json");
            File.Copy(_transactionsFile, backupFile, true);
        }

        public bool RestoreFromBackup(string backupFilePath)
        {
            if (!File.Exists(backupFilePath))
                return false;

            File.Copy(backupFilePath, _transactionsFile, true);
            return true;
        }
    }
}