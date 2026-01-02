package demo.service;

import demo.dto.*;
import demo.entity.Transaction;
import demo.entity.TransactionType;
import demo.entity.User;
import demo.repository.ReportRepository;
import demo.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReportService {

    private final ReportRepository reportRepository;
    private final TransactionRepository transactionRepository;

    // 默认显示前6个分类
    private static final int TOP_CATEGORIES_LIMIT = 6;

    /**
     * 获取月度收支报告
     */
    @Transactional(readOnly = true)
    public MonthlyReportDTO getMonthlyReport(User user, int year, int month) {
        log.info("获取月度报告: user={}, year={}, month={}", user.getId(), year, month);

        MonthlyReportDTO report = new MonthlyReportDTO();
        report.setYear(year);
        report.setMonth(month);

        try {
            // 获取交易数量
            Long transactionCount = reportRepository.countMonthlyTransactions(user, year, month);
            report.setTransactionCount(transactionCount != null ? transactionCount.intValue() : 0);

            // 获取总收入
            BigDecimal totalIncome = reportRepository.getMonthlyTotalByType(
                    user, TransactionType.INCOME.name(), year, month);
            report.setTotalIncome(totalIncome != null ? totalIncome : BigDecimal.ZERO);

            // 获取总支出
            BigDecimal totalExpense = reportRepository.getMonthlyTotalByType(
                    user, TransactionType.EXPENSE.name(), year, month);
            report.setTotalExpense(totalExpense != null ? totalExpense : BigDecimal.ZERO);

            // 获取支出分类排名
            List<Object[]> expenseCategories = reportRepository.getMonthlyCategorySummary(
                    user, TransactionType.EXPENSE.name(), year, month);
            report.setTopExpenseCategories(convertToCategorySummary(expenseCategories, totalExpense));

            // 获取收入分类排名
            List<Object[]> incomeCategories = reportRepository.getMonthlyCategorySummary(
                    user, TransactionType.INCOME.name(), year, month);
            report.setTopIncomeCategories(convertToCategorySummary(incomeCategories, totalIncome));

        } catch (Exception e) {
            log.error("生成月度报告失败: ", e);
            throw new RuntimeException("生成月度报告失败: " + e.getMessage());
        }

        return report;
    }

    /**
     * 获取年度趋势报告
     */
    @Transactional(readOnly = true)
    public TrendReportDTO getYearlyTrendReport(User user, int year) {
        log.info("获取年度趋势报告: user={}, year={}", user.getId(), year);

        TrendReportDTO trendReport = new TrendReportDTO();

        try {
            List<Object[]> trendData = reportRepository.getYearlyTrend(user, year, year);

            // 准备12个月的数据
            List<String> labels = new ArrayList<>();
            List<BigDecimal> incomes = new ArrayList<>();
            List<BigDecimal> expenses = new ArrayList<>();

            // 初始化12个月的数据为0
            for (int month = 1; month <= 12; month++) {
                labels.add(String.format("%d-%02d", year, month));
                incomes.add(BigDecimal.ZERO);
                expenses.add(BigDecimal.ZERO);
            }

            // 填充实际数据
            for (Object[] data : trendData) {
                int dataYear = (int) data[0];
                int dataMonth = (int) data[1];
                BigDecimal income = (BigDecimal) data[2];
                BigDecimal expense = (BigDecimal) data[3];

                // 确保是请求的年份
                if (dataYear == year && dataMonth >= 1 && dataMonth <= 12) {
                    incomes.set(dataMonth - 1, income);
                    expenses.set(dataMonth - 1, expense);
                }
            }

            trendReport.setLabels(labels);
            trendReport.setIncomes(incomes);
            trendReport.setExpenses(expenses);

        } catch (Exception e) {
            log.error("生成年度趋势报告失败: ", e);
            throw new RuntimeException("生成年度趋势报告失败: " + e.getMessage());
        }

        return trendReport;
    }

    /**
     * 获取多年度趋势报告（最近3年）
     */
    @Transactional(readOnly = true)
    public Map<String, TrendReportDTO> getMultiYearTrendReport(User user) {
        log.info("获取多年度趋势报告: user={}", user.getId());

        Map<String, TrendReportDTO> result = new LinkedHashMap<>();
        int currentYear = LocalDate.now().getYear();

        for (int year = currentYear - 2; year <= currentYear; year++) {
            TrendReportDTO yearlyReport = getYearlyTrendReport(user, year);
            result.put(String.valueOf(year), yearlyReport);
        }

        return result;
    }

    /**
     * 获取类别占比分析报告
     */
    @Transactional(readOnly = true)
    public CategoryReportDTO getCategoryAnalysis(User user, LocalDate startDate, LocalDate endDate) {
        log.info("获取类别分析报告: user={}, startDate={}, endDate={}",
                user.getId(), startDate, endDate);

        CategoryReportDTO report = new CategoryReportDTO();

        try {
            List<Object[]> analysisData = reportRepository.getCategoryAnalysis(user, startDate, endDate);

            // 按类型分组
            Map<String, BigDecimal> incomeCategories = new HashMap<>();
            Map<String, BigDecimal> expenseCategories = new HashMap<>();
            BigDecimal totalIncome = BigDecimal.ZERO;
            BigDecimal totalExpense = BigDecimal.ZERO;

            for (Object[] data : analysisData) {
                String category = (String) data[0];
                String type = (String) data[1];
                BigDecimal amount = (BigDecimal) data[2];

                if (TransactionType.INCOME.name().equals(type)) {
                    incomeCategories.put(category, amount);
                    totalIncome = totalIncome.add(amount);
                } else if (TransactionType.EXPENSE.name().equals(type)) {
                    expenseCategories.put(category, amount);
                    totalExpense = totalExpense.add(amount);
                }
            }

            // 合并所有分类
            Set<String> allCategories = new HashSet<>(incomeCategories.keySet());
            allCategories.addAll(expenseCategories.keySet());

            // 计算总额
            BigDecimal totalAmount = totalIncome.add(totalExpense);
            report.setTotal(totalAmount);

            // 准备数据
            List<String> categories = new ArrayList<>();
            List<BigDecimal> amounts = new ArrayList<>();

            // 添加收入分类
            incomeCategories.entrySet().stream()
                    .sorted(Map.Entry.<String, BigDecimal>comparingByValue().reversed())
                    .limit(TOP_CATEGORIES_LIMIT)
                    .forEach(entry -> {
                        categories.add(entry.getKey() + " (收入)");
                        amounts.add(entry.getValue());
                    });

            // 添加支出分类
            expenseCategories.entrySet().stream()
                    .sorted(Map.Entry.<String, BigDecimal>comparingByValue().reversed())
                    .limit(TOP_CATEGORIES_LIMIT)
                    .forEach(entry -> {
                        categories.add(entry.getKey() + " (支出)");
                        amounts.add(entry.getValue());
                    });

            report.setCategories(categories);
            report.setAmounts(amounts);

        } catch (Exception e) {
            log.error("生成类别分析报告失败: ", e);
            throw new RuntimeException("生成类别分析报告失败: " + e.getMessage());
        }

        return report;
    }

    /**
     * 获取快速余额统计
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getQuickBalance(User user) {
        log.info("获取快速余额统计: user={}", user.getId());

        Map<String, Object> result = new HashMap<>();

        try {
            Object[] balanceData = reportRepository.getQuickBalance(user);

            BigDecimal totalIncome = (BigDecimal) balanceData[0];
            BigDecimal totalExpense = (BigDecimal) balanceData[1];
            BigDecimal netIncome = totalIncome.subtract(totalExpense);

            // 月度数据
            LocalDate today = LocalDate.now();
            Object[] monthlyData = reportRepository.getMonthlyBalance(user, today.getYear(), today.getMonthValue());
            BigDecimal monthlyIncome = (BigDecimal) monthlyData[0];
            BigDecimal monthlyExpense = (BigDecimal) monthlyData[1];
            BigDecimal monthlyNet = monthlyIncome.subtract(monthlyExpense);

            // 最近交易 - 使用分页查询
            Pageable pageable = PageRequest.of(0, 5);
            List<Transaction> recentTransactions = transactionRepository
                    .findByUserOrderByDateDesc(user, pageable);

            result.put("totalIncome", totalIncome);
            result.put("totalExpense", totalExpense);
            result.put("netIncome", netIncome);
            result.put("monthlyIncome", monthlyIncome);
            result.put("monthlyExpense", monthlyExpense);
            result.put("monthlyNet", monthlyNet);
            result.put("recentTransactions", recentTransactions);

            // 计算月度预算执行情况（如果有预算模块）
            calculateBudgetProgress(user, today, result);

        } catch (Exception e) {
            log.error("获取快速余额统计失败: ", e);
            result.put("error", "获取统计数据失败: " + e.getMessage());
        }

        return result;
    }

    /**
     * 获取月度概览（用于仪表盘）
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getMonthlyOverview(User user, int year, int month) {
        log.info("获取月度概览: user={}, year={}, month={}", user.getId(), year, month);

        Map<String, Object> overview = new HashMap<>();

        try {
            // 获取收支数据
            Object[] balanceData = reportRepository.getMonthlyBalance(user, year, month);
            BigDecimal income = (BigDecimal) balanceData[0];
            BigDecimal expense = (BigDecimal) balanceData[1];

            // 获取交易数量
            Long count = reportRepository.countMonthlyTransactions(user, year, month);

            // 获取前5大支出分类
            List<Object[]> expenseCategories = reportRepository.getMonthlyCategorySummary(
                    user, TransactionType.EXPENSE.name(), year, month);

            // 获取前5大收入分类
            List<Object[]> incomeCategories = reportRepository.getMonthlyCategorySummary(
                    user, TransactionType.INCOME.name(), year, month);

            overview.put("year", year);
            overview.put("month", month);
            overview.put("income", income != null ? income : BigDecimal.ZERO);
            overview.put("expense", expense != null ? expense : BigDecimal.ZERO);
            overview.put("balance", income.subtract(expense));
            overview.put("transactionCount", count != null ? count : 0);
            overview.put("topExpenseCategories",
                    convertToCategorySummary(expenseCategories, expense, 5));
            overview.put("topIncomeCategories",
                    convertToCategorySummary(incomeCategories, income, 5));

        } catch (Exception e) {
            log.error("获取月度概览失败: ", e);
            overview.put("error", "获取月度概览失败: " + e.getMessage());
        }

        return overview;
    }

    /**
     * 获取最近N个月的趋势数据
     */
    @Transactional(readOnly = true)
    public TrendReportDTO getRecentMonthsTrend(User user, int months) {
        log.info("获取最近{}个月趋势: user={}", months, user.getId());

        TrendReportDTO trend = new TrendReportDTO();

        try {
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusMonths(months - 1).withDayOfMonth(1);

            List<String> labels = new ArrayList<>();
            List<BigDecimal> incomes = new ArrayList<>();
            List<BigDecimal> expenses = new ArrayList<>();

            LocalDate current = startDate;
            while (!current.isAfter(endDate)) {
                YearMonth yearMonth = YearMonth.from(current);
                int year = yearMonth.getYear();
                int month = yearMonth.getMonthValue();

                Object[] balanceData = reportRepository.getMonthlyBalance(user, year, month);
                BigDecimal income = (BigDecimal) balanceData[0];
                BigDecimal expense = (BigDecimal) balanceData[1];

                labels.add(String.format("%d-%02d", year, month));
                incomes.add(income != null ? income : BigDecimal.ZERO);
                expenses.add(expense != null ? expense : BigDecimal.ZERO);

                current = current.plusMonths(1);
            }

            trend.setLabels(labels);
            trend.setIncomes(incomes);
            trend.setExpenses(expenses);

        } catch (Exception e) {
            log.error("获取最近月份趋势失败: ", e);
            throw new RuntimeException("获取趋势数据失败: " + e.getMessage());
        }

        return trend;
    }

    /**
     * 转换分类汇总数据
     */
    private List<CategorySummaryDTO> convertToCategorySummary(
            List<Object[]> rawData, BigDecimal total, int limit) {

        if (rawData == null || rawData.isEmpty()) {
            return new ArrayList<>();
        }

        return rawData.stream()
                .limit(limit)
                .map(data -> {
                    CategorySummaryDTO summary = new CategorySummaryDTO();
                    summary.setCategory((String) data[0]);
                    summary.setAmount((BigDecimal) data[1]);

                    if (total.compareTo(BigDecimal.ZERO) != 0) {
                        BigDecimal percentage = summary.getAmount()
                                .divide(total, 4, RoundingMode.HALF_UP)
                                .multiply(new BigDecimal("100"))
                                .setScale(2, RoundingMode.HALF_UP);
                        summary.setPercentage(percentage);
                    } else {
                        summary.setPercentage(BigDecimal.ZERO);
                    }

                    return summary;
                })
                .collect(Collectors.toList());
    }

    /**
     * 转换分类汇总数据（使用默认限制）
     */
    private List<CategorySummaryDTO> convertToCategorySummary(
            List<Object[]> rawData, BigDecimal total) {
        return convertToCategorySummary(rawData, total, TOP_CATEGORIES_LIMIT);
    }

    /**
     * 计算预算执行进度（如果有预算模块）
     */
    private void calculateBudgetProgress(User user, LocalDate month, Map<String, Object> result) {
        // 这里可以集成预算模块
        // 暂时返回空进度
        result.put("budgetProgress", new HashMap<>());
    }
}