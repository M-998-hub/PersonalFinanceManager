package demo.service;

import demo.dto.TransactionDTO;
import demo.entity.Transaction;
import demo.entity.User;
import demo.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import jakarta.persistence.criteria.Predicate;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DataQueryService {

    private final TransactionRepository transactionRepository;

    /**
     * 查询交易数据
     */
    public Page<TransactionDTO> queryTransactions(
            User user,
            LocalDate startDate,
            LocalDate endDate,
            String type,
            String category,
            BigDecimal minAmount,
            BigDecimal maxAmount,
            String keyword,
            int page,
            int size) {

        Specification<Transaction> spec = buildSpecification(
                user, startDate, endDate, type, category,
                minAmount, maxAmount, keyword
        );

        Pageable pageable = PageRequest.of(page, size,
                Sort.by(Sort.Direction.DESC, "date", "id"));

        Page<Transaction> transactionPage = transactionRepository.findAll(spec, pageable);

        return transactionPage.map(this::convertToDTO);
    }

    /**
     * 获取查询统计信息
     */
    public Map<String, Object> getQueryStats(
            User user,
            LocalDate startDate,
            LocalDate endDate,
            String type,
            String category,
            BigDecimal minAmount,
            BigDecimal maxAmount,
            String keyword) {

        Specification<Transaction> spec = buildSpecification(
                user, startDate, endDate, type, category,
                minAmount, maxAmount, keyword
        );

        List<Transaction> transactions = transactionRepository.findAll(spec);

        BigDecimal totalIncome = BigDecimal.ZERO;
        BigDecimal totalExpense = BigDecimal.ZERO;
        int incomeCount = 0;
        int expenseCount = 0;
        BigDecimal maxTransaction = BigDecimal.ZERO;
        BigDecimal minTransaction = transactions.isEmpty() ? BigDecimal.ZERO : null;

        for (Transaction transaction : transactions) {
            BigDecimal amount = transaction.getAmount();

            if (transaction.getType().name().equals("INCOME")) {
                totalIncome = totalIncome.add(amount);
                incomeCount++;
            } else {
                totalExpense = totalExpense.add(amount);
                expenseCount++;
            }

            // 更新最大最小值
            if (maxTransaction.compareTo(amount) < 0) {
                maxTransaction = amount;
            }
            if (minTransaction == null || minTransaction.compareTo(amount) > 0) {
                minTransaction = amount;
            }
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalIncome", totalIncome);
        stats.put("totalExpense", totalExpense);
        stats.put("netBalance", totalIncome.subtract(totalExpense));
        stats.put("incomeCount", incomeCount);
        stats.put("expenseCount", expenseCount);
        stats.put("totalCount", transactions.size());
        stats.put("maxAmount", maxTransaction);
        stats.put("minAmount", minTransaction);
        stats.put("averageAmount", transactions.isEmpty() ? BigDecimal.ZERO :
                totalIncome.add(totalExpense).divide(BigDecimal.valueOf(transactions.size()), 2, BigDecimal.ROUND_HALF_UP));

        return stats;
    }

    /**
     * 构建查询条件
     */
    private Specification<Transaction> buildSpecification(
            User user,
            LocalDate startDate,
            LocalDate endDate,
            String type,
            String category,
            BigDecimal minAmount,
            BigDecimal maxAmount,
            String keyword) {

        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // 用户条件
            predicates.add(cb.equal(root.get("user"), user));

            // 日期范围条件
            if (startDate != null) {
                predicates.add(cb.greaterThanOrEqualTo(
                        root.get("date"), startDate.atStartOfDay()
                ));
            }
            if (endDate != null) {
                predicates.add(cb.lessThanOrEqualTo(
                        root.get("date"), endDate.atTime(23, 59, 59)
                ));
            }

            // 交易类型条件
            if (type != null && !type.isEmpty()) {
                predicates.add(cb.equal(root.get("type"), type));
            }

            // 分类条件
            if (category != null && !category.isEmpty()) {
                predicates.add(cb.equal(root.get("category"), category));
            }

            // 金额范围条件
            if (minAmount != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("amount"), minAmount));
            }
            if (maxAmount != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("amount"), maxAmount));
            }

            // 关键词搜索（描述和分类）
            if (keyword != null && !keyword.trim().isEmpty()) {
                String keywordPattern = "%" + keyword.trim() + "%";
                Predicate descriptionPredicate = cb.like(root.get("description"), keywordPattern);
                Predicate categoryPredicate = cb.like(root.get("category"), keywordPattern);
                predicates.add(cb.or(descriptionPredicate, categoryPredicate));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    /**
     * 导出为CSV
     */
    public String exportToCsv(
            User user,
            LocalDate startDate,
            LocalDate endDate,
            String type,
            String category,
            BigDecimal minAmount,
            BigDecimal maxAmount,
            String keyword) {

        Specification<Transaction> spec = buildSpecification(
                user, startDate, endDate, type, category,
                minAmount, maxAmount, keyword
        );

        List<Transaction> transactions = transactionRepository.findAll(spec);

        StringBuilder csv = new StringBuilder();
        // CSV头部
        csv.append("日期,类型,分类,金额,描述\n");

        // 数据行
        for (Transaction transaction : transactions) {
            csv.append(String.format("\"%s\",", transaction.getDate().toLocalDate()));
            csv.append(String.format("\"%s\",", transaction.getType()));
            csv.append(String.format("\"%s\",", transaction.getCategory()));
            csv.append(String.format("\"%.2f\",", transaction.getAmount()));
            csv.append(String.format("\"%s\"\n",
                    transaction.getDescription() != null ?
                            transaction.getDescription().replace("\"", "\"\"") : ""));
        }

        return csv.toString();
    }

    /**
     * 获取用户的所有分类
     */
    public List<String> getUserCategories(User user) {
        return transactionRepository.findByUser(user)
                .stream()
                .map(Transaction::getCategory)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    /**
     * 转换为DTO
     */
    private TransactionDTO convertToDTO(Transaction transaction) {
        TransactionDTO dto = new TransactionDTO();
        dto.setId(transaction.getId());
        dto.setDate(transaction.getDate().toLocalDate());
        dto.setCategory(transaction.getCategory());
        dto.setType(transaction.getType().name());
        dto.setAmount(transaction.getAmount());
        dto.setDescription(transaction.getDescription());
        return dto;
    }
}