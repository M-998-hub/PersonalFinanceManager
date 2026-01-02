package demo.service;

import demo.entity.Transaction;
import demo.entity.TransactionType;
import demo.repository.TransactionRepository;
import demo.entity.User;
import demo.dto.TransactionDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    // 1. 获取所有交易记录
    public List<Transaction> getAllTransactions() {
        return transactionRepository.findAll();
    }

    // 2. 根据ID获取单个交易记录
    public Optional<Transaction> getTransactionById(Long id) {
        return transactionRepository.findById(id);
    }

    // 3. 创建或更新交易记录
    public Transaction saveTransaction(Transaction transaction) {
        // 业务逻辑验证
        if (transaction.getAmount() == null || transaction.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("金额必须大于0");
        }
        return transactionRepository.save(transaction);
    }

    /**
     * 从DTO创建交易
     */
    /**
     * 从DTO创建交易
     */
    public Transaction createTransactionFromDTO(TransactionDTO dto, User user) {
        Transaction transaction = new Transaction();
        transaction.setAmount(dto.getAmount());
        transaction.setType(TransactionType.valueOf(dto.getType()));
        transaction.setCategory(dto.getCategory() != null ? dto.getCategory() : "其他");
        transaction.setDescription(dto.getDescription() != null ? dto.getDescription() : "");

        // 处理日期：将 LocalDate 转换为 LocalDateTime（设置为当天的开始时间）
        if (dto.getDate() != null) {
            transaction.setDate(dto.getDate().atStartOfDay());
        } else {
            transaction.setDate(LocalDate.now().atStartOfDay());
        }

        transaction.setUser(user);

        return saveTransaction(transaction);
    }

    // 4. 根据ID删除交易记录
    public void deleteTransaction(Long id) {
        transactionRepository.deleteById(id);
    }

    /**
     * 获取用户的最近交易（DTO格式）
     */
    public List<TransactionDTO> getRecentTransactionsDTO(User user, int limit) {
        List<Transaction> transactions = transactionRepository.findTopByUserOrderByDateDesc(user, limit);
        return transactions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取用户的所有交易（DTO格式）
     */
    public List<TransactionDTO> getUserTransactionsDTO(User user) {
        List<Transaction> transactions = transactionRepository.findByUser(user);
        return transactions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取用户的月度交易统计
     */
    public Map<String, BigDecimal> getUserMonthlySummary(User user, int year, int month) {
        // 计算时间范围
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        // 转换为LocalDateTime
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        List<Transaction> monthlyTransactions = transactionRepository
                .findByUserAndDateBetween(user, startDateTime, endDateTime);

        BigDecimal totalIncome = BigDecimal.ZERO;
        BigDecimal totalExpense = BigDecimal.ZERO;

        for (Transaction transaction : monthlyTransactions) {
            if (transaction.getType() == TransactionType.INCOME) {
                totalIncome = totalIncome.add(transaction.getAmount());
            } else {
                totalExpense = totalExpense.add(transaction.getAmount());
            }
        }

        Map<String, BigDecimal> summary = new HashMap<>();
        summary.put("totalIncome", totalIncome);
        summary.put("totalExpense", totalExpense);
        summary.put("netBalance", totalIncome.subtract(totalExpense));

        return summary;
    }

    /**
     * 获取用户当前月度统计
     */
    public Map<String, BigDecimal> getUserCurrentMonthlySummary(User user) {
        LocalDate now = LocalDate.now();
        return getUserMonthlySummary(user, now.getYear(), now.getMonthValue());
    }

    /**
     * 按条件筛选用户交易
     */
    public List<TransactionDTO> searchUserTransactions(User user,
                                                       TransactionType type,
                                                       String category,
                                                       LocalDate startDate,
                                                       LocalDate endDate) {

        List<Transaction> transactions;

        // 转换为LocalDateTime
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        if (type != null && category != null && startDate != null && endDate != null) {
            // 所有条件都指定
            transactions = transactionRepository.findByUserAndCategoryAndTypeAndDateBetween(
                    user, category, type,
                    startDate.atStartOfDay(), endDate.plusDays(1).atStartOfDay());
        } else if (startDate != null && endDate != null) {
            // 只指定日期范围
            transactions = transactionRepository.findByUserAndDateBetween(user, startDateTime, endDateTime);

            // 进一步筛选
            if (type != null) {
                transactions = transactions.stream()
                        .filter(t -> t.getType() == type)
                        .collect(Collectors.toList());
            }
            if (category != null) {
                transactions = transactions.stream()
                        .filter(t -> category.equals(t.getCategory()))
                        .collect(Collectors.toList());
            }
        } else {
            // 没有条件，获取所有用户交易
            transactions = transactionRepository.findByUser(user);

            // 进一步筛选
            if (type != null) {
                transactions = transactions.stream()
                        .filter(t -> t.getType() == type)
                        .collect(Collectors.toList());
            }
            if (category != null) {
                transactions = transactions.stream()
                        .filter(t -> category.equals(t.getCategory()))
                        .collect(Collectors.toList());
            }
        }

        return transactions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 将Transaction实体转换为DTO
     */
    private TransactionDTO convertToDTO(Transaction transaction) {
        TransactionDTO dto = new TransactionDTO();
        dto.setId(transaction.getId());
        dto.setDate(transaction.getDate().toLocalDate());  // LocalDateTime -> LocalDate
        dto.setCategory(transaction.getCategory());
        dto.setType(transaction.getType().name());
        dto.setAmount(transaction.getAmount());
        dto.setDescription(transaction.getDescription());
        return dto;
    }

    /**
     * 根据类型获取总金额（简化版）
     */
    public BigDecimal getTotalAmountByType(String username, String type,
                                           LocalDateTime startDate, LocalDateTime endDate, String category) {

        try {
            List<Transaction> transactions;

            if (startDate != null && endDate != null && category != null) {
                // 使用Repository的自定义查询
                transactions = transactionRepository.findByUserAndFilters(
                        username, type, startDate, endDate, category
                );
            } else {
                // 简化查询 - 先获取用户的所有交易，然后过滤
                transactions = transactionRepository.findByUserUsernameAndTypeOrderByDateDesc(username, type);

                // 应用额外的过滤（如果提供了参数）
                if (startDate != null) {
                    transactions = transactions.stream()
                            .filter(t -> t.getDate().compareTo(startDate) >= 0)
                            .toList();
                }

                if (endDate != null) {
                    transactions = transactions.stream()
                            .filter(t -> t.getDate().compareTo(endDate) <= 0)
                            .toList();
                }

                if (category != null && !category.isEmpty()) {
                    transactions = transactions.stream()
                            .filter(t -> category.equals(t.getCategory()))
                            .toList();
                }
            }

            return transactions.stream()
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

        } catch (Exception e) {
            // 如果查询出错，返回0
            System.err.println("查询总金额失败: " + e.getMessage());
            return BigDecimal.ZERO;
        }
    }
}