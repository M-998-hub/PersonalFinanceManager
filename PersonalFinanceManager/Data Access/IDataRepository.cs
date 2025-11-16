using System.Collections.Generic;
using PersonalFinanceManager.Models;
using System;

namespace PersonalFinanceManager.Data
{
    public interface IDataRepository
    {
        #region 基础CRUD操作
        void AddTransaction(Transaction transaction);
        IEnumerable<Transaction> GetAllTransactions();
        void SaveTransactions(IEnumerable<Transaction> transactions);
        void DeleteTransaction(int id);
        void UpdateTransaction(Transaction updatedTransaction);
        public void ExportTransactionsToFile(List<Transaction> transactions, string filePath, string format = "json");
        public void BackupTransactions();
        public bool RestoreFromBackup(string backupFilePath);
        #endregion

        #region 基础查询
        IEnumerable<Transaction> GetTransactionsByCategory(string category);
        IEnumerable<Transaction> GetTransactionsByDate(System.DateTime start, System.DateTime end);
        IEnumerable<Transaction> GetTransactionsByType(TransactionType type);
        #endregion

        #region 预算管理
        void SaveBudget(Budget budget);
        Budget? GetBudget(string category);
        IEnumerable<Budget> GetAllBudgets();
        void DeleteBudget(string category);
        #endregion
    }
}