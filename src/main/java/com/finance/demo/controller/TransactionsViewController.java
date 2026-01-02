package demo.controller;

import demo.entity.User;
import demo.service.TransactionService;
import demo.dto.TransactionDTO;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.beans.factory.annotation.Autowired;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import java.util.List;

@Controller
public class TransactionsViewController {

    private final TransactionService transactionService;

    @Autowired
    public TransactionsViewController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @GetMapping("/transactions")
    public String transactionsPage(HttpSession session, Model model) {
        // 检查用户登录
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login-page";
        }

        // 1. 设置页面属性
        model.addAttribute("pageTitle", "交易管理 - 个人经济管理系统");
        model.addAttribute("activePage", "transactions");
        model.addAttribute("currentUser", currentUser);

        // 2. 加载当前月度统计数据
        Map<String, BigDecimal> stats = transactionService.getUserCurrentMonthlySummary(currentUser);
        model.addAttribute("totalIncome", stats.get("totalIncome"));
        model.addAttribute("totalExpense", stats.get("totalExpense"));
        model.addAttribute("netBalance", stats.get("netBalance"));

        // 3. 加载最近交易（最多10条）
        List<TransactionDTO> recentTransactions = transactionService.getRecentTransactionsDTO(currentUser, 10);
        model.addAttribute("recentTransactions", recentTransactions);

        // 4. 设置当前日期（用于表单默认值）
        model.addAttribute("currentDate", LocalDate.now().toString());

        return "pages/transactions";
    }
}