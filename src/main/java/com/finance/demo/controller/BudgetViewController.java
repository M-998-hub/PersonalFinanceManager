package demo.controller;

import demo.entity.User;
import demo.service.BudgetService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
@RequiredArgsConstructor
public class BudgetViewController {

    private final BudgetService budgetService;

    @GetMapping("/budgets")
    public String budgetsPage(
            HttpSession session,
            Model model,
            @RequestParam(required = false) String alertCategory) {

        // 检查用户登录
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login-page";
        }

        // 设置页面属性
        model.addAttribute("pageTitle", "预算管理 - 个人经济管理系统");
        model.addAttribute("activePage", "budgets");
        model.addAttribute("currentUser", currentUser);

        // 获取当前月份的所有预算
        model.addAttribute("budgets", budgetService.getCurrentMonthBudgets(currentUser));

        // 获取预算预警信息
        model.addAttribute("budgetAlerts", budgetService.checkAllBudgetAlerts(currentUser));

        // 如果有特定的预警分类
        if (alertCategory != null) {
            model.addAttribute("alertCategory", alertCategory);
        }

        // 设置当前月份（用于表单默认值）
        LocalDate today = LocalDate.now();
        model.addAttribute("today", today.toString());
        model.addAttribute("currentMonth", today.withDayOfMonth(1).toString());

        // 获取常用分类（可以从交易数据中提取）
        model.addAttribute("commonCategories", getCommonCategories(currentUser));

        return "pages/budgets";
    }

    /**
     * 获取用户常用的分类列表
     */
    private String[] getCommonCategories(User user) {
        return new String[]{
                "餐饮", "交通", "购物", "娱乐",
                "房租", "水电费", "通讯费", "医疗",
                "教育", "旅行", "投资", "其他支出"
        };
    }
}