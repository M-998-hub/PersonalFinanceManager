// src/main/java/demo/dto/TransactionDTO.java
package demo.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class TransactionDTO {
    private Long id;
    private LocalDate date;
    private String category;
    private String type; // "INCOME" 或 "EXPENSE"
    private BigDecimal amount;
    private String description;
}