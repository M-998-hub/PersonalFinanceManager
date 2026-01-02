package demo.controller;

import demo.entity.Budget;
import demo.entity.User;
import demo.service.BudgetService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;



import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/budgets")
@RequiredArgsConstructor
public class BudgetController {

    @Autowired
    private BudgetService budgetService;

    // 1. 获取当前用户的所有预算 [GET /api/budgets]
    @GetMapping
    public ResponseEntity<List<Budget>> getUserBudgets(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<Budget> budgets = budgetService.getUserBudgets(currentUser);
        return ResponseEntity.ok(budgets);
    }

    // 2. 根据ID获取预算 [GET /api/budgets/{id}]
    @GetMapping("/{id}")
    public ResponseEntity<Budget> getBudgetById(@PathVariable Long id, HttpSession session) {
        Optional<Budget> budget = budgetService.getBudgetById(id);

        if (budget.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // 检查权限 - 假设Budget有getUser方法
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null) {
            // 确保用户只能访问自己的预算
            Budget budgetEntity = budget.get();
            if (budgetEntity.getUser() != null &&
                    !budgetEntity.getUser().getUsername().equals(currentUser.getUsername())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }

        return ResponseEntity.ok(budget.get());
    }

    // 3. 创建预算 [POST /api/budgets]
    @PostMapping
    public ResponseEntity<Map<String, Object>> createBudget(
            @RequestBody Budget budgetDetails,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        // 获取当前用户
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        // 验证必要字段
        if (budgetDetails == null ||
                budgetDetails.getCategory() == null ||
                budgetDetails.getCategory().trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "分类不能为空");
            return ResponseEntity.badRequest().body(response);
        }

        // 验证月度限额
        if (budgetDetails.getMonthlyLimit() == null ||
                budgetDetails.getMonthlyLimit().compareTo(BigDecimal.ZERO) <= 0) {
            response.put("success", false);
            response.put("message", "月度预算限额必须大于0");
            return ResponseEntity.badRequest().body(response);
        }

        // 设置用户
        budgetDetails.setUser(currentUser);

        // 如果未设置月份，设置为当前月
        if (budgetDetails.getMonth() == null) {
            budgetDetails.setMonth(LocalDate.now().withDayOfMonth(1));
        }

        // 初始化其他字段
        budgetDetails.setCurrentSpent(BigDecimal.ZERO);
        budgetDetails.setUsagePercentage(BigDecimal.ZERO);

        try {
            Budget savedBudget = budgetService.saveBudget(budgetDetails);
            response.put("success", true);
            response.put("message", "预算创建成功");
            response.put("budgetId", savedBudget.getId());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "创建预算失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // 4. 更新预算 [PUT /api/budgets/{id}]
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateBudget(@PathVariable Long id,
                                                            @RequestBody Budget budgetDetails,
                                                            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        // 检查预算是否存在且属于当前用户
        Optional<Budget> existingBudget = budgetService.getBudgetById(id);
        if (existingBudget.isEmpty()) {
            response.put("success", false);
            response.put("message", "预算不存在");
            return ResponseEntity.notFound().build();
        }

        Budget budgetToUpdate = existingBudget.get();
        if (!budgetToUpdate.getUser().getId().equals(currentUser.getId())) {
            response.put("success", false);
            response.put("message", "无权修改此预算");
            return ResponseEntity.status(403).body(response);
        }

        // 更新字段
        if (budgetDetails.getCategory() != null) {
            budgetToUpdate.setCategory(budgetDetails.getCategory().trim());
        }

        if (budgetDetails.getMonthlyLimit() != null) {
            if (budgetDetails.getMonthlyLimit().compareTo(BigDecimal.ZERO) <= 0) {
                response.put("success", false);
                response.put("message", "预算金额必须大于0");
                return ResponseEntity.badRequest().body(response);
            }
            budgetToUpdate.setMonthlyLimit(budgetDetails.getMonthlyLimit());
        }

        try {
            Budget updatedBudget = budgetService.saveBudget(budgetToUpdate);

            response.put("success", true);
            response.put("message", "预算更新成功");
            response.put("budgetId", updatedBudget.getId());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "更新预算失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // 5. 删除预算 [DELETE /api/budgets/{id}]
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteBudget(@PathVariable Long id, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        // 检查预算是否存在且属于当前用户
        Optional<Budget> existingBudget = budgetService.getBudgetById(id);
        if (existingBudget.isEmpty()) {
            response.put("success", false);
            response.put("message", "预算不存在");
            return ResponseEntity.notFound().build();
        }

        Budget budgetToDelete = existingBudget.get();
        if (!budgetToDelete.getUser().getId().equals(currentUser.getId())) {
            response.put("success", false);
            response.put("message", "无权删除此预算");
            return ResponseEntity.status(403).body(response);
        }

        try {
            budgetService.deleteBudget(id);

            response.put("success", true);
            response.put("message", "预算删除成功");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "删除预算失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // 6. 检查预算预警 [GET /api/budgets/alert/{category}]
    @GetMapping("/alert/{category}")
    public ResponseEntity<Map<String, Object>> checkBudgetAlert(@PathVariable String category,
                                                                HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 这里需要添加预算预警检查逻辑
            // BudgetAlertDTO alert = budgetService.checkBudgetAlert(category, currentUser);

            response.put("success", true);
            response.put("message", "预算预警功能开发中");
            response.put("category", category);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "检查预算预警失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}