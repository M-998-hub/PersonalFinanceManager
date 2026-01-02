package demo.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalDate;

@Entity
@Table(name = "budgets", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "category", "month"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Budget {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 100)
    private String category;

    @Column(name = "monthly_limit", nullable = false, precision = 10, scale = 2)
    private BigDecimal monthlyLimit;

    @Column(name = "current_spent", precision = 10, scale = 2)
    private BigDecimal currentSpent = BigDecimal.ZERO;

    @Column(name = "usage_percentage", precision = 5, scale = 2)
    private BigDecimal usagePercentage = BigDecimal.ZERO;

    @Column(nullable = false)
    private LocalDate month;  // 格式：YYYY-MM-01

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    // 便捷构造函数
    public Budget(User user, String category, BigDecimal monthlyLimit, LocalDate month) {
        this.user = user;
        this.category = category;
        this.monthlyLimit = monthlyLimit;
        this.month = month.withDayOfMonth(1); // 确保是月份的第一天
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // 计算使用百分比
    public void calculateUsagePercentage() {
        if (monthlyLimit != null && monthlyLimit.compareTo(BigDecimal.ZERO) > 0) {
            this.usagePercentage = currentSpent
                    .multiply(BigDecimal.valueOf(100))
                    .divide(monthlyLimit, 2, java.math.RoundingMode.HALF_UP);
        } else {
            this.usagePercentage = BigDecimal.ZERO;
        }
    }

    // 检查是否超支
    public boolean isOverBudget() {
        return currentSpent.compareTo(monthlyLimit) > 0;
    }

    // 检查是否接近预算（达到80%）
    public boolean isNearLimit() {
        if (monthlyLimit.compareTo(BigDecimal.ZERO) == 0) return false;
        BigDecimal percentage = currentSpent
                .multiply(BigDecimal.valueOf(100))
                .divide(monthlyLimit, 2, java.math.RoundingMode.HALF_UP);
        return percentage.compareTo(BigDecimal.valueOf(80)) >= 0;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        calculateUsagePercentage();
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        calculateUsagePercentage();

        // 确保month是月份的第一天
        if (this.month != null) {
            this.month = this.month.withDayOfMonth(1);
        }
    }
}