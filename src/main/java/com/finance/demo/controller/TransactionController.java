package demo.controller;

import demo.entity.Transaction;
import demo.entity.User;
import demo.service.TransactionService;
import demo.dto.TransactionDTO;
import demo.entity.TransactionType;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import java.time.YearMonth;
import java.time.LocalDateTime;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.*;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    @Autowired
    private TransactionService transactionService;

    /**
     * 创建新的交易记录 [POST /api/transactions]
     * 支持两种方式：接收Transaction实体或TransactionDTO
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createTransaction(
            @RequestBody TransactionDTO transactionDTO,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        // 获取当前用户
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 使用TransactionDTO创建交易
            Transaction transaction = transactionService.createTransactionFromDTO(transactionDTO, currentUser);

            response.put("success", true);
            response.put("message", "交易创建成功");
            response.put("transactionId", transaction.getId());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "创建交易失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 备份的POST方法，接收Transaction实体（保持向后兼容）
     */
    @PostMapping("/entity")
    public ResponseEntity<Transaction> createTransactionEntity(@RequestBody Transaction transaction) {
        Transaction savedTransaction = transactionService.saveTransaction(transaction);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedTransaction);
    }

    // 1. 添加DTO转换方法
    private TransactionDTO convertToDTO(Transaction transaction) {
        TransactionDTO dto = new TransactionDTO();
        dto.setId(transaction.getId());
        if (transaction.getDate() != null) {
            dto.setDate(transaction.getDate().toLocalDate());
        }
        dto.setCategory(transaction.getCategory());
        if (transaction.getType() != null) {
            dto.setType(transaction.getType().name());
        }
        dto.setAmount(transaction.getAmount());
        dto.setDescription(transaction.getDescription());
        return dto;
    }

    // 2. 修改getTransactionById方法 - 返回DTO
    @GetMapping(value = "/{id}", produces = "application/json")
    public ResponseEntity<?> getTransactionById(@PathVariable Long id) {
        Optional<Transaction> transaction = transactionService.getTransactionById(id);
        if (transaction.isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "交易不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        TransactionDTO dto = convertToDTO(transaction.get());
        return ResponseEntity.ok(dto);
    }


/*
    // 2. 根据ID获取交易记录 [GET /api/transactions/{id}]
    @GetMapping("/{id}")
    public ResponseEntity<Transaction> getTransactionById(@PathVariable Long id) {
        Optional<Transaction> transaction = transactionService.getTransactionById(id);
        return transaction.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
 */

    // 3. 修改updateTransaction方法 - 接收TransactionDTO
    @PutMapping(value = "/{id}", produces = "application/json", consumes = "application/json")
    public ResponseEntity<Map<String, Object>> updateTransaction(
            @PathVariable Long id,
            @RequestBody TransactionDTO transactionDTO,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        // 获取当前用户
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        try {
            Optional<Transaction> existingTransaction = transactionService.getTransactionById(id);
            if (existingTransaction.isEmpty()) {
                response.put("success", false);
                response.put("message", "交易不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            // 使用TransactionService中的方法从DTO更新交易
            Transaction transactionToUpdate = existingTransaction.get();

            // 更新字段
            transactionToUpdate.setAmount(transactionDTO.getAmount());
            if (transactionDTO.getType() != null) {
                transactionToUpdate.setType(TransactionType.valueOf(transactionDTO.getType()));
            }
            transactionToUpdate.setCategory(transactionDTO.getCategory());
            transactionToUpdate.setDescription(transactionDTO.getDescription());

            // 处理日期
            if (transactionDTO.getDate() != null) {
                transactionToUpdate.setDate(transactionDTO.getDate().atStartOfDay());
            }

            // 确保用户不变
            transactionToUpdate.setUser(currentUser);

            Transaction updatedTransaction = transactionService.saveTransaction(transactionToUpdate);

            response.put("success", true);
            response.put("message", "交易更新成功");
            response.put("transactionId", updatedTransaction.getId());
            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", "交易类型无效: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "更新交易失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

   /* // 4. 更新交易记录 [PUT /api/transactions/{id}]
    @PutMapping("/{id}")
    public ResponseEntity<Transaction> updateTransaction(@PathVariable Long id, @RequestBody Transaction transactionDetails) {
        Optional<Transaction> existingTransaction = transactionService.getTransactionById(id);
        if (existingTransaction.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Transaction transactionToUpdate = existingTransaction.get();
        transactionToUpdate.setAmount(transactionDetails.getAmount());
        transactionToUpdate.setType(transactionDetails.getType());
        transactionToUpdate.setCategory(transactionDetails.getCategory());
        transactionToUpdate.setDescription(transactionDetails.getDescription());
        transactionToUpdate.setDate(transactionDetails.getDate());

        Transaction updatedTransaction = transactionService.saveTransaction(transactionToUpdate);
        return ResponseEntity.ok(updatedTransaction);
    }
*/

    // 4. 修改deleteTransaction方法 - 返回统一格式
    @DeleteMapping(value = "/{id}", produces = "application/json")
    public ResponseEntity<Map<String, Object>> deleteTransaction(
            @PathVariable Long id,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        // 获取当前用户
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 检查交易是否存在且属于当前用户
            Optional<Transaction> transaction = transactionService.getTransactionById(id);
            if (transaction.isEmpty()) {
                response.put("success", false);
                response.put("message", "交易不存在");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            // 可选：检查交易是否属于当前用户
            if (!transaction.get().getUser().getId().equals(currentUser.getId())) {
                response.put("success", false);
                response.put("message", "无权删除此交易");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }

            transactionService.deleteTransaction(id);

            response.put("success", true);
            response.put("message", "交易删除成功");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "删除交易失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    /*
    // 5. 删除交易记录 [DELETE /api/transactions/{id}]
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTransaction(@PathVariable Long id) {
        if (transactionService.getTransactionById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        transactionService.deleteTransaction(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<Page<TransactionDTO>> getTransactions(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Page<TransactionDTO> emptyPage = Page.empty();
        return ResponseEntity.ok(emptyPage);
    }*/

    @GetMapping("/recent")
    public ResponseEntity<List<TransactionDTO>> getRecentTransactions(
            @RequestParam(defaultValue = "5") int limit,
            HttpSession session) {

        // 获取当前用户
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Collections.emptyList());
        }

        List<TransactionDTO> transactions = transactionService.getRecentTransactionsDTO(currentUser, limit);
        return ResponseEntity.ok(transactions);
    }

    /**
     * 获取用户的所有交易
     */
    @GetMapping("/user")
    public ResponseEntity<List<TransactionDTO>> getUserTransactions(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Collections.emptyList());
        }

        List<TransactionDTO> transactions = transactionService.getUserTransactionsDTO(currentUser);
        return ResponseEntity.ok(transactions);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getTransactionStats(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            HttpSession session) {  // 改为使用HttpSession而不是Authentication

        try {
            // 从session获取用户
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            String username = currentUser.getUsername();  // 获取用户名

            // 如果没有提供日期，则使用当前月份
            if (startDate == null || endDate == null) {
                LocalDate now = LocalDate.now();
                YearMonth currentMonth = YearMonth.from(now);
                startDate = currentMonth.atDay(1);
                endDate = currentMonth.atEndOfMonth();
            }

            LocalDateTime startDateTime = startDate != null ? startDate.atStartOfDay() : null;
            LocalDateTime endDateTime = endDate != null ? endDate.atTime(23, 59, 59) : null;

            // 获取收入总额
            BigDecimal totalIncome = transactionService.getTotalAmountByType(username, "INCOME",
                    startDateTime, endDateTime, category);

            // 获取支出总额
            BigDecimal totalExpense = transactionService.getTotalAmountByType(username, "EXPENSE",
                    startDateTime, endDateTime, category);

            Map<String, Object> stats = new HashMap<>();
            stats.put("totalIncome", totalIncome);
            stats.put("totalExpense", totalExpense);
            stats.put("netBalance", totalIncome.subtract(totalExpense));

            // 添加日期范围信息
            stats.put("startDate", startDate.toString());
            stats.put("endDate", endDate.toString());

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", stats);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "获取统计数据失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }



    /*
    // 在TransactionService中添加方法：
    public BigDecimal getTotalAmountByType(String username, String type,
                                           LocalDateTime startDate, LocalDateTime endDate, String category) {

        Specification<Transaction> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("user").get("username"), username));
            predicates.add(cb.equal(root.get("type"), type));

            if (startDate != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("date"), startDate));
            }
            if (endDate != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("date"), endDate));
            }
            if (category != null && !category.isEmpty()) {
                predicates.add(cb.equal(root.get("category"), category));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        List<Transaction> transactions = transactionRepository.findAll(spec);
        return transactions.stream()
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
     */
}