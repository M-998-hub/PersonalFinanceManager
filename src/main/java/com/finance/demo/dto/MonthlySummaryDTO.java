package demo.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Data
class MonthlySummaryDTO {
    private BigDecimal income = BigDecimal.ZERO;
    private BigDecimal expense = BigDecimal.ZERO;

    public BigDecimal getBalance() {
        return income.subtract(expense);
    }
}