// src/main/java/demo/dto/CategoryReportDTO.java
package demo.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class CategoryReportDTO {
    private List<String> categories;  // 分类名称
    private List<BigDecimal> amounts; // 分类金额
    private BigDecimal total;         // 总额
}