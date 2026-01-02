package demo.service;

import demo.entity.Transaction;
import demo.entity.User;
import demo.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final TransactionRepository transactionRepository;

    /**
     * 获取用户的月度统计
     */
    public Map<String, BigDecimal> getMonthlySummary(User user) {
        Map<String, BigDecimal> summary = new HashMap<>();

        // 获取当前月份
        YearMonth currentMonth = YearMonth.now();
        LocalDate startDate = currentMonth.atDay(1);
        LocalDate endDate = currentMonth.atEndOfMonth();

        // 转换为LocalDateTime
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        // 获取当前月份的所有交易
        List<Transaction> monthlyTransactions = transactionRepository
                .findByUserAndDateBetween(user, startDateTime, endDateTime);

        // 计算收入和支出
        BigDecimal monthlyIncome = BigDecimal.ZERO;
        BigDecimal monthlyExpense = BigDecimal.ZERO;

        for (Transaction transaction : monthlyTransactions) {
            if ("INCOME".equals(transaction.getType().name())) {
                monthlyIncome = monthlyIncome.add(transaction.getAmount());
            } else if ("EXPENSE".equals(transaction.getType().name())) {
                monthlyExpense = monthlyExpense.add(transaction.getAmount());
            }
        }

        // 计算余额（总收入 - 总支出）
        BigDecimal currentBalance = monthlyIncome.subtract(monthlyExpense);

        summary.put("monthlyIncome", monthlyIncome);
        summary.put("monthlyExpense", monthlyExpense);
        summary.put("currentBalance", currentBalance);

        return summary;
    }

    /**
     * 获取最近交易（简化版）
     */
    public List<Transaction> getRecentTransactions(User user, int limit) {
        return transactionRepository.findTopByUserOrderByDateDesc(user, limit);
    }
}