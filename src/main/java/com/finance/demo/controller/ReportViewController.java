package demo.controller;

import demo.entity.User;
import demo.service.ReportService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;

@Controller
@RequiredArgsConstructor
public class ReportViewController {

    private final ReportService reportService;

    @GetMapping("/reports")
    public String reportsPage(
            HttpSession session,
            Model model,
            @RequestParam(required = false) String reportType) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login-page";
        }

        // 设置页面属性
        model.addAttribute("pageTitle", "报表统计 - 个人经济管理系统");
        model.addAttribute("activePage", "reports");
        model.addAttribute("currentUser", currentUser);

        // 设置当前日期
        LocalDate today = LocalDate.now();
        model.addAttribute("currentDate", today);
        model.addAttribute("currentDateFormatted", today.toString()); // 添加字符串格式
        model.addAttribute("currentYear", today.getYear());
        model.addAttribute("currentMonth", today.getMonthValue());

        // 上个月日期
        LocalDate lastMonth = today.minusMonths(1);
        model.addAttribute("lastMonth", lastMonth);
        model.addAttribute("lastMonthFormatted", lastMonth.toString()); // 添加字符串格式

        // 将LocalDate转换为Date（兼容fmt:formatDate）
        model.addAttribute("currentDateAsDate",
                Date.from(today.atStartOfDay(ZoneId.systemDefault()).toInstant()));
        model.addAttribute("lastMonthAsDate",
                Date.from(lastMonth.atStartOfDay(ZoneId.systemDefault()).toInstant()));

        // 获取快速统计（用于仪表盘）
        try {
            model.addAttribute("quickStats", reportService.getQuickBalance(currentUser));
        } catch (Exception e) {
            model.addAttribute("quickStatsError", "加载统计数据失败");
        }

        // 设置默认报表类型
        if (reportType != null) {
            model.addAttribute("defaultReportType", reportType);
        } else {
            model.addAttribute("defaultReportType", "monthly");
        }

        return "pages/reports";
    }

    @GetMapping("/reports/monthly")
    public String monthlyReportPage(
            HttpSession session,
            Model model,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month) {

        return reportsPage(session, model, "monthly");
    }

    @GetMapping("/reports/trend")
    public String trendReportPage(
            HttpSession session,
            Model model,
            @RequestParam(required = false) Integer year) {

        return reportsPage(session, model, "trend");
    }

    @GetMapping("/reports/categories")
    public String categoryReportPage(
            HttpSession session,
            Model model) {

        return reportsPage(session, model, "categories");
    }

    @GetMapping("/reports/export")
    public String exportReportPage(
            HttpSession session,
            Model model) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login-page";
        }

        model.addAttribute("pageTitle", "报表导出 - 个人经济管理系统");
        model.addAttribute("activePage", "reports");
        model.addAttribute("currentUser", currentUser);

        // 设置日期格式
        LocalDate today = LocalDate.now();
        LocalDate threeMonthsAgo = today.minusMonths(3);

        model.addAttribute("exportStartDate", threeMonthsAgo.toString());
        model.addAttribute("exportEndDate", today.toString());
        model.addAttribute("exportStartDateAsDate",
                Date.from(threeMonthsAgo.atStartOfDay(ZoneId.systemDefault()).toInstant()));
        model.addAttribute("exportEndDateAsDate",
                Date.from(today.atStartOfDay(ZoneId.systemDefault()).toInstant()));

        return "pages/report-export";
    }
}