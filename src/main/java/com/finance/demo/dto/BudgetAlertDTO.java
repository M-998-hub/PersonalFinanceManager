package demo.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.math.RoundingMode;

@Data
public class BudgetAlertDTO {
    private String category;
    private BigDecimal budgetLimit;
    private BigDecimal actualSpending;
    private BigDecimal overAmount; // 正数表示超支金额
    private BigDecimal usagePercentage; // 添加这个字段
    private AlertLevel alertLevel;

    // 可以添加一个便捷的计算方法
    public BigDecimal getUsagePercentage() {
        if (budgetLimit == null || budgetLimit.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        if (actualSpending == null) {
            return BigDecimal.ZERO;
        }
        return actualSpending
                .divide(budgetLimit, 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
    }

    // 添加setter方法
    public void setUsagePercentage(BigDecimal usagePercentage) {
        this.usagePercentage = usagePercentage;
    }
}