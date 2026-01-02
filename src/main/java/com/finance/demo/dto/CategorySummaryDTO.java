package demo.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class CategorySummaryDTO {
    private String category;
    private BigDecimal amount;
    private BigDecimal percentage;
}