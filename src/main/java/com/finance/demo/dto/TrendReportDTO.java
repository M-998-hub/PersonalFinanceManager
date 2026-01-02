// src/main/java/demo/dto/TrendReportDTO.java
package demo.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class TrendReportDTO {
    private List<String> labels;        // 月份标签，如 ["2024-01", "2024-02"]
    private List<BigDecimal> incomes;   // 每月收入
    private List<BigDecimal> expenses;  // 每月支出
}