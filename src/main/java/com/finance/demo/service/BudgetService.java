package demo.service;

import demo.dto.BudgetAlertDTO;
import demo.dto.AlertLevel;
import demo.entity.Transaction;
import demo.entity.TransactionType;
import demo.entity.Budget;
import demo.entity.User;
import demo.repository.TransactionRepository;
import demo.repository.BudgetRepository;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.ArrayList;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final TransactionRepository transactionRepository;

    // 1. 获取所有预算
    public List<Budget> getAllBudgets() {
        return budgetRepository.findAll();
    }

    // 2. 根据ID获取预算
    public Optional<Budget> getBudgetById(Long id) {
        return budgetRepository.findById(id);
    }

    // 3. 根据分类获取预算
    public Optional<Budget> getBudgetByCategory(String category) {
        return budgetRepository.findByCategory(category);
    }

    // 4. 创建或更新预算
    public Budget saveBudget(Budget budget) {
        if (budget.getMonthlyLimit().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("预算金额不能为负数");
        }
        return budgetRepository.save(budget);
    }

    // 5. 删除预算
    public void deleteBudget(Long id) {
        budgetRepository.deleteById(id);
    }

    /**
     * 检查预算预警（需要当前用户）
     */
    public BudgetAlertDTO checkBudgetAlert(String category, User user) {
        // 1. 查找该分类的预算
        Optional<Budget> budgetOpt = budgetRepository.findByCategoryAndUser(category, user);
        if (budgetOpt.isEmpty()) {
            return null;
        }
        Budget budget = budgetOpt.get();

        // 2. 计算当前周期（本月）该分类的实际支出总额
        YearMonth currentMonth = YearMonth.now();
        LocalDate startDate = currentMonth.atDay(1);
        LocalDate endDate = currentMonth.atEndOfMonth();

        // 查询该分类、本月的所有支出交易（需要用户信息）
        List<Transaction> categoryExpenses = transactionRepository
                .findByUserAndCategoryAndTypeAndDateBetween(
                        user,
                        category,
                        TransactionType.EXPENSE,
                        startDate.atStartOfDay(),
                        endDate.plusDays(1).atStartOfDay()  // 结束时间不包含
                );

        // 计算总支出金额
        BigDecimal actualSpending = categoryExpenses.stream()
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 3. 计算超支金额和使用率
        BigDecimal budgetLimit = budget.getMonthlyLimit();
        BigDecimal overAmount = actualSpending.subtract(budgetLimit).max(BigDecimal.ZERO);
        BigDecimal usagePercentage = BigDecimal.ZERO;
        if (budgetLimit.compareTo(BigDecimal.ZERO) > 0) {
            usagePercentage = actualSpending
                    .divide(budgetLimit, 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"));
        }

        // 4. 确定预警等级
        AlertLevel alertLevel = determineAlertLevel(usagePercentage, overAmount);

        // 5. 构建并返回DTO
        BudgetAlertDTO alert = new BudgetAlertDTO();
        alert.setCategory(category);
        alert.setBudgetLimit(budgetLimit);
        alert.setActualSpending(actualSpending);
        alert.setOverAmount(overAmount);
        alert.setUsagePercentage(usagePercentage);
        alert.setAlertLevel(alertLevel);

        return alert;
    }

    private AlertLevel determineAlertLevel(BigDecimal usagePercentage, BigDecimal overAmount) {
        if (overAmount.compareTo(BigDecimal.ZERO) > 0) {
            return AlertLevel.OVER_BUDGET;
        }
        if (usagePercentage.compareTo(new BigDecimal("80")) >= 0) {
            return AlertLevel.NEAR_LIMIT;
        }
        return AlertLevel.NORMAL;
    }

    /**
     * 获取用户的预算
     */
    public List<Budget> getUserBudgets(User user) {
        return budgetRepository.findByUser(user);
    }

    /**
     * 更新预算的实际花费
     */
    public void updateBudgetSpending(User user, String category, BigDecimal amount) {
        LocalDate currentMonth = LocalDate.now().withDayOfMonth(1);

        Optional<Budget> budgetOpt = budgetRepository.findByUserAndCategoryAndMonth(
                user, category, currentMonth
        );

        if (budgetOpt.isPresent()) {
            Budget budget = budgetOpt.get();
            budget.setCurrentSpent(budget.getCurrentSpent().add(amount));
            budgetRepository.save(budget);
        }
    }

    /**
     * 获取用户本月所有预算
     */
    public List<Budget> getCurrentMonthBudgets(User user) {
        LocalDate currentMonth = LocalDate.now().withDayOfMonth(1);
        return budgetRepository.findByUserAndMonth(user, currentMonth);
    }

    /**
     * 检查所有预算的预警状态
     */
    public List<BudgetAlertDTO> checkAllBudgetAlerts(User user) {
        List<Budget> budgets = getCurrentMonthBudgets(user);
        List<BudgetAlertDTO> alerts = new ArrayList<>();

        for (Budget budget : budgets) {
            BudgetAlertDTO alert = checkBudgetAlert(budget.getCategory(), user);
            if (alert != null) {
                alerts.add(alert);
            }
        }

        return alerts;
    }
}