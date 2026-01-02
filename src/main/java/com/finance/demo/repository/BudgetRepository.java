package demo.repository;

import demo.entity.Budget;
import demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.math.BigDecimal;

@Repository // 可选，但推荐，明确这是一个Spring管理的Repository Bean
public interface BudgetRepository extends JpaRepository<Budget, Long> {

    // 根据用户、分类和月份查找预算
    Optional<Budget> findByUserAndCategoryAndMonth(User user, String category, LocalDate month);

    // 根据用户和月份查找所有预算
    List<Budget> findByUserAndMonth(User user, LocalDate month);

    // 根据用户查找所有预算
    List<Budget> findByUser(User user);

    // 查找接近或超过预算的条目
    List<Budget> findByUserAndUsagePercentageGreaterThanEqual(User user, BigDecimal percentage);

    // 根据分类查找预算（确保分类唯一性）
    Optional<Budget> findByCategory(String category);

    // 根据分类和用户查找预算
    Optional<Budget> findByCategoryAndUser(String category, User user);
}