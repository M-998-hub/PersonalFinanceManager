package demo.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class MonthlyReportDTO {
    private int year;
    private int month;
    private int transactionCount;
    private BigDecimal totalIncome;
    private BigDecimal totalExpense;
    private List<CategorySummaryDTO> topExpenseCategories;
    private List<CategorySummaryDTO> topIncomeCategories;

    public BigDecimal getNetIncome() {
        return totalIncome.subtract(totalExpense);
    }
}