package demo.controller;

import demo.entity.User;
import demo.service.DashboardService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.math.BigDecimal;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("dashboard-page")
    public String dashboard(HttpSession session, Model model) {
        try {
            // 检查用户是否登录
            User currentUser = (User) session.getAttribute("currentUser");

            // 如果用户未登录，重定向到登录页面
            if (currentUser == null) {
                return "redirect:login-page";
            }

            // 获取月度统计
            Map<String, BigDecimal> summary = dashboardService.getMonthlySummary(currentUser);

            // 将数据传递给页面
            model.addAttribute("currentUser", currentUser);
            model.addAttribute("monthlyIncome", summary.get("monthlyIncome"));
            model.addAttribute("monthlyExpense", summary.get("monthlyExpense"));
            model.addAttribute("currentBalance", summary.get("currentBalance"));

            // 关键：设置激活页面为 dashboard
            model.addAttribute("activePage", "dashboard");

            // 获取最近交易
            model.addAttribute("recentTransactions", dashboardService.getRecentTransactions(currentUser, 5));

            return "pages/dashboard";

        } catch (Exception e) {
            // 记录错误并重定向到错误页面
            e.printStackTrace();
            return "redirect:/error?message=" + e.getMessage();
        }
    }
}