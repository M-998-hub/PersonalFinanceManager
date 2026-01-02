package demo.repository;

import demo.entity.Transaction;
import demo.entity.TransactionType;
import demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long>,
        JpaSpecificationExecutor<Transaction> {

    // 基本查询方法
    List<Transaction> findByUser(User user);

    // 使用LocalDateTime参数
    List<Transaction> findByUserAndDateBetween(User user, LocalDateTime startDate, LocalDateTime endDate);

    List<Transaction> findByCategoryAndTypeAndDateBetween(String category, TransactionType type,
                                                          LocalDateTime startDate, LocalDateTime endDate);

    // 根据用户查找交易
    List<Transaction> findByUserUsernameOrderByDateDesc(String username);

    List<Transaction> findByUserOrderByDateDesc(User user);

    // 添加分页查询方法
    List<Transaction> findByUserOrderByDateDesc(User user, Pageable pageable);

    // 根据用户和类型查找
    List<Transaction> findByUserUsernameAndTypeOrderByDateDesc(String username, String type);

    // 根据用户、类型和日期范围查找
    List<Transaction> findByUserUsernameAndTypeAndDateBetweenOrderByDateDesc(
            String username, String type, LocalDateTime start, LocalDateTime end);

    // 查询特定分类的交易
    List<Transaction> findByUserUsernameAndCategoryOrderByDateDesc(String username, String category);

    List<Transaction> findByDateBetween(LocalDateTime startDate, LocalDateTime endDate);

    // 获取用户最近交易
    @Query("SELECT t FROM Transaction t WHERE t.user = :user ORDER BY t.date DESC, t.id DESC")
    List<Transaction> findTopByUserOrderByDateDesc(@Param("user") User user, @Param("limit") int limit);

    @Query("SELECT t FROM Transaction t WHERE t.user = :user ORDER BY t.date DESC, t.id DESC")
    List<Transaction> findTopByUserOrderByDateDesc(@Param("user") User user);

    // 添加这个方法到 TransactionRepository
    @Query("SELECT t FROM Transaction t WHERE t.user = :user AND t.category = :category AND t.type = :type AND t.date >= :startDate AND t.date < :endDate")
    List<Transaction> findByUserAndCategoryAndTypeAndDateBetween(
            @Param("user") User user,
            @Param("category") String category,
            @Param("type") TransactionType type,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    /**
     * 根据筛选条件查询交易
     */
    @Query("SELECT t FROM Transaction t WHERE t.user.username = :username " +
            "AND (:type IS NULL OR t.type = :type) " +
            "AND (:startDate IS NULL OR t.date >= :startDate) " +
            "AND (:endDate IS NULL OR t.date <= :endDate) " +
            "AND (:category IS NULL OR t.category = :category) " +
            "ORDER BY t.date DESC")
    List<Transaction> findByUserAndFilters(
            @Param("username") String username,
            @Param("type") String type,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            @Param("category") String category);
}