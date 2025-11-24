using Microsoft.EntityFrameworkCore;
using PersonalFinanceManager.Data;
using PersonalFinanceManager.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace PersonalFinanceManager.Data
{
    public class SqliteRepository : IDataRepository
    {
        private readonly FinanceDbContext _context;

        public SqliteRepository()
        {
            _context = new FinanceDbContext();
        }

        // 交易相关方法
        public void AddTransaction(Transaction transaction)
        {
            _context.Transactions.Add(transaction);
            _context.SaveChanges();
        }

        public IEnumerable<Transaction> GetAllTransactions()
        {
            return _context.Transactions
                          .AsNoTracking()
                          .OrderByDescending(t => t.Date)
                          .ToList();
        }

        public IEnumerable<Transaction> GetTransactionsByCategory(string category)
        {
            return _context.Transactions
                          .Where(t => t.Category == category)
                          .AsNoTracking()
                          .OrderByDescending(t => t.Date)
                          .ToList();
        }

        public IEnumerable<Transaction> GetTransactionsByDate(DateTime startDate, DateTime endDate)
        {
            return _context.Transactions
                          .Where(t => t.Date >= startDate && t.Date <= endDate)
                          .AsNoTracking()
                          .OrderByDescending(t => t.Date)
                          .ToList();
        }

        public IEnumerable<Transaction> GetTransactionsByType(TransactionType type)
        {
            return _context.Transactions
                          .Where(t => t.Type == type)
                          .AsNoTracking()
                          .OrderByDescending(t => t.Date)
                          .ToList();
        }

        public void UpdateTransaction(Transaction transaction)
        {
            try
            {
                using var dbContext = new FinanceDbContext();

                
                dbContext.Transactions.Attach(transaction);
                dbContext.Entry(transaction).State = EntityState.Modified;
                dbContext.SaveChanges();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"更新交易时出错: {ex.Message}");
            }
        }

        public void DeleteTransaction(int id)
        {
            var transaction = _context.Transactions.Find(id);
            if (transaction != null)
            {
                _context.Transactions.Remove(transaction);
                _context.SaveChanges();
            }
        }

        // 预算相关方法
        public void SaveBudget(Budget budget)
        {
            var existing = _context.Budgets.FirstOrDefault(b => b.Category == budget.Category);
            if (existing != null)
            {
                existing.MonthlyLimit = budget.MonthlyLimit;
                _context.Budgets.Update(existing);
            }
            else
            {
                _context.Budgets.Add(budget);
            }
            _context.SaveChanges();
        }

        public Budget GetBudget(string category)
        {
            return _context.Budgets
                          .AsNoTracking()
                          .FirstOrDefault(b => b.Category == category);
        }

        public IEnumerable<Budget> GetAllBudgets()
        {
            return _context.Budgets
                          .AsNoTracking()
                          .ToList();
        }

        public void DeleteBudget(string category)
        {
            var budget = _context.Budgets.FirstOrDefault(b => b.Category == category);
            if (budget != null)
            {
                _context.Budgets.Remove(budget);
                _context.SaveChanges();
            }
        }

        // 文件操作相关方法（在数据库版本中可能不需要，但为了接口兼容性实现）
        public void SaveTransactions(IEnumerable<Transaction> transactions)
        {
            // 数据库版本不需要这个方法，但为了接口兼容性实现空方法
            throw new NotImplementedException("数据库版本不需要手动保存事务");
        }

        public void ExportTransactionsToFile(List<Transaction> transactions, string filePath, string format)
        {
            // 可以实现数据导出功能
            // 这里可以调用JsonFileRepository的导出逻辑，或者重新实现
            throw new NotImplementedException("导出功能待实现");
        }

        public void BackupTransactions()
        {
            // 数据库备份逻辑
            throw new NotImplementedException("备份功能待实现");
        }

        public bool RestoreFromBackup(string backupPath)
        {
            // 数据库恢复逻辑
            throw new NotImplementedException("恢复功能待实现");
        }

        public void Dispose()
        {
            _context?.Dispose();
        }
    }
}