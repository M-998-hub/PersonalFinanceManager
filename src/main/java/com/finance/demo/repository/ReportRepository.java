package demo.repository;

import demo.entity.Transaction;
import demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Transaction, Long> {

    // 月度收支统计
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.user = :user AND t.type = :type " +
            "AND YEAR(t.date) = :year AND MONTH(t.date) = :month")
    BigDecimal getMonthlyTotalByType(
            @Param("user") User user,
            @Param("type") String type,
            @Param("year") int year,
            @Param("month") int month);

    // 获取月度交易数量
    @Query("SELECT COUNT(t) FROM Transaction t " +
            "WHERE t.user = :user " +
            "AND YEAR(t.date) = :year AND MONTH(t.date) = :month")
    Long countMonthlyTransactions(
            @Param("user") User user,
            @Param("year") int year,
            @Param("month") int month);

    // 月度分类统计
    @Query("SELECT t.category, COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.user = :user AND t.type = :type " +
            "AND YEAR(t.date) = :year AND MONTH(t.date) = :month " +
            "GROUP BY t.category " +
            "ORDER BY SUM(t.amount) DESC")
    List<Object[]> getMonthlyCategorySummary(
            @Param("user") User user,
            @Param("type") String type,
            @Param("year") int year,
            @Param("month") int month);

    // 年度趋势统计
    @Query("SELECT YEAR(t.date) as year, MONTH(t.date) as month, " +
            "COALESCE(SUM(CASE WHEN t.type = 'INCOME' THEN t.amount ELSE 0 END), 0) as income, " +
            "COALESCE(SUM(CASE WHEN t.type = 'EXPENSE' THEN t.amount ELSE 0 END), 0) as expense " +
            "FROM Transaction t " +
            "WHERE t.user = :user " +
            "AND YEAR(t.date) >= :startYear AND YEAR(t.date) <= :endYear " +
            "GROUP BY YEAR(t.date), MONTH(t.date) " +
            "ORDER BY YEAR(t.date), MONTH(t.date)")
    List<Object[]> getYearlyTrend(
            @Param("user") User user,
            @Param("startYear") int startYear,
            @Param("endYear") int endYear);

    // 类别占比分析（按时间范围）
    @Query("SELECT t.category, t.type, COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.user = :user " +
            "AND t.date >= :startDate AND t.date <= :endDate " +
            "GROUP BY t.category, t.type " +
            "ORDER BY t.type, SUM(t.amount) DESC")
    List<Object[]> getCategoryAnalysis(
            @Param("user") User user,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    // 快速余额统计
    @Query("SELECT " +
            "COALESCE(SUM(CASE WHEN t.type = 'INCOME' THEN t.amount ELSE 0 END), 0) as totalIncome, " +
            "COALESCE(SUM(CASE WHEN t.type = 'EXPENSE' THEN t.amount ELSE 0 END), 0) as totalExpense " +
            "FROM Transaction t " +
            "WHERE t.user = :user")
    Object[] getQuickBalance(@Param("user") User user);

    // 月度余额统计
    @Query("SELECT " +
            "COALESCE(SUM(CASE WHEN t.type = 'INCOME' THEN t.amount ELSE 0 END), 0) as income, " +
            "COALESCE(SUM(CASE WHEN t.type = 'EXPENSE' THEN t.amount ELSE 0 END), 0) as expense " +
            "FROM Transaction t " +
            "WHERE t.user = :user " +
            "AND YEAR(t.date) = :year AND MONTH(t.date) = :month")
    Object[] getMonthlyBalance(
            @Param("user") User user,
            @Param("year") int year,
            @Param("month") int month);
}