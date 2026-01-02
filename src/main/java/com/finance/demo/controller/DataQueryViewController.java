package demo.controller;

import demo.entity.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
public class DataQueryViewController {

    @GetMapping("/data-query")
    public String dataQueryPage(
            HttpSession session,
            Model model,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String minAmount,
            @RequestParam(required = false) String maxAmount,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        // 检查用户登录
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login-page";
        }

        // 设置页面属性
        model.addAttribute("pageTitle", "数据查询 - 个人经济管理系统");
        model.addAttribute("activePage", "data-query");
        model.addAttribute("currentUser", currentUser);

        // 计算日期
        LocalDate today = LocalDate.now();
        LocalDate firstDay = today.withDayOfMonth(1);
        LocalDate lastDay = today.withDayOfMonth(today.lengthOfMonth());

        // 如果没有提供日期，使用默认值
        if (startDate == null) {
            startDate = firstDay.toString();
        }
        if (endDate == null) {
            endDate = today.toString();
        }

        // 设置查询参数（用于回显表单）
        model.addAttribute("queryParams", new QueryParams(
                startDate, endDate, type, category,
                minAmount, maxAmount, keyword, page, size
        ));


        // 设置当前日期（用于表单默认值）
        model.addAttribute("today", LocalDate.now().toString());
        model.addAttribute("firstDayOfMonth",
                LocalDate.now().withDayOfMonth(1).toString());
        model.addAttribute("lastDayOfMonth",
                LocalDate.now().withDayOfMonth(
                        LocalDate.now().lengthOfMonth()
                ).toString());

        return "pages/data-query";
    }

    // 内部类用于封装查询参数
    public static class QueryParams {
        private String startDate;
        private String endDate;
        private String type;
        private String category;
        private String minAmount;
        private String maxAmount;
        private String keyword;
        private int page;
        private int size;

        // 构造函数、getters、setters
        public QueryParams(String startDate, String endDate, String type,
                           String category, String minAmount, String maxAmount,
                           String keyword, int page, int size) {
            this.startDate = startDate;
            this.endDate = endDate;
            this.type = type;
            this.category = category;
            this.minAmount = minAmount;
            this.maxAmount = maxAmount;
            this.keyword = keyword;
            this.page = page;
            this.size = size;
        }

        // getters 和 setters
        public String getStartDate() { return startDate; }
        public void setStartDate(String startDate) { this.startDate = startDate; }
        public String getEndDate() { return endDate; }
        public void setEndDate(String endDate) { this.endDate = endDate; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public String getMinAmount() { return minAmount; }
        public void setMinAmount(String minAmount) { this.minAmount = minAmount; }
        public String getMaxAmount() { return maxAmount; }
        public void setMaxAmount(String maxAmount) { this.maxAmount = maxAmount; }
        public String getKeyword() { return keyword; }
        public void setKeyword(String keyword) { this.keyword = keyword; }
        public int getPage() { return page; }
        public void setPage(int page) { this.page = page; }
        public int getSize() { return size; }
        public void setSize(int size) { this.size = size; }
    }
}