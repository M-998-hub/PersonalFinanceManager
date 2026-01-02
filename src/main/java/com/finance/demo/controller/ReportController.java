package demo.controller;

import demo.dto.CategoryReportDTO;
import demo.dto.MonthlyReportDTO;
import demo.dto.TrendReportDTO;
import demo.entity.User;
import demo.service.ReportService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
@Slf4j
public class ReportController {

    private final ReportService reportService;

    /**
     * 获取月度收支报告
     * GET /api/reports/monthly?year=2024&month=12
     */
    @GetMapping("/monthly")
    public ResponseEntity<Map<String, Object>> getMonthlyReport(
            @RequestParam(defaultValue = "0") int year,
            @RequestParam(defaultValue = "0") int month,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            // 如果未指定年月，使用当前年月
            LocalDate today = LocalDate.now();
            int targetYear = year > 0 ? year : today.getYear();
            int targetMonth = month > 0 ? month : today.getMonthValue();

            MonthlyReportDTO report = reportService.getMonthlyReport(
                    currentUser, targetYear, targetMonth);

            response.put("success", true);
            response.put("data", report);
            response.put("message", "月度报告获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取月度报告失败: ", e);
            response.put("success", false);
            response.put("message", "获取月度报告失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取年度趋势报告
     * GET /api/reports/trend/yearly?year=2024
     */
    @GetMapping("/trend/yearly")
    public ResponseEntity<Map<String, Object>> getYearlyTrendReport(
            @RequestParam(defaultValue = "0") int year,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            // 如果未指定年份，使用当前年份
            int targetYear = year > 0 ? year : LocalDate.now().getYear();

            TrendReportDTO trendReport = reportService.getYearlyTrendReport(
                    currentUser, targetYear);

            response.put("success", true);
            response.put("data", trendReport);
            response.put("message", "年度趋势报告获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取年度趋势报告失败: ", e);
            response.put("success", false);
            response.put("message", "获取年度趋势报告失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取最近多年度趋势报告
     * GET /api/reports/trend/multi-year
     */
    @GetMapping("/trend/multi-year")
    public ResponseEntity<Map<String, Object>> getMultiYearTrendReport(
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            Map<String, TrendReportDTO> trendReports =
                    reportService.getMultiYearTrendReport(currentUser);

            response.put("success", true);
            response.put("data", trendReports);
            response.put("message", "多年度趋势报告获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取多年度趋势报告失败: ", e);
            response.put("success", false);
            response.put("message", "获取多年度趋势报告失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取类别占比分析报告
     * GET /api/reports/category-analysis?startDate=2024-01-01&endDate=2024-12-31
     */
    @GetMapping("/category-analysis")
    public ResponseEntity<Map<String, Object>> getCategoryAnalysis(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            // 验证日期范围
            if (startDate.isAfter(endDate)) {
                response.put("success", false);
                response.put("message", "开始日期不能晚于结束日期");
                return ResponseEntity.badRequest().body(response);
            }

            CategoryReportDTO categoryReport = reportService.getCategoryAnalysis(
                    currentUser, startDate, endDate);

            response.put("success", true);
            response.put("data", categoryReport);
            response.put("message", "类别分析报告获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取类别分析报告失败: ", e);
            response.put("success", false);
            response.put("message", "获取类别分析报告失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取快速余额统计
     * GET /api/reports/quick-balance
     */
    @GetMapping("/quick-balance")
    public ResponseEntity<Map<String, Object>> getQuickBalance(
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            Map<String, Object> balanceData = reportService.getQuickBalance(currentUser);

            response.put("success", true);
            response.put("data", balanceData);
            response.put("message", "快速余额统计获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取快速余额统计失败: ", e);
            response.put("success", false);
            response.put("message", "获取快速余额统计失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取月度概览
     * GET /api/reports/monthly-overview?year=2024&month=12
     */
    @GetMapping("/monthly-overview")
    public ResponseEntity<Map<String, Object>> getMonthlyOverview(
            @RequestParam(defaultValue = "0") int year,
            @RequestParam(defaultValue = "0") int month,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            // 如果未指定年月，使用当前年月
            LocalDate today = LocalDate.now();
            int targetYear = year > 0 ? year : today.getYear();
            int targetMonth = month > 0 ? month : today.getMonthValue();

            Map<String, Object> overview = reportService.getMonthlyOverview(
                    currentUser, targetYear, targetMonth);

            response.put("success", true);
            response.put("data", overview);
            response.put("message", "月度概览获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取月度概览失败: ", e);
            response.put("success", false);
            response.put("message", "获取月度概览失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取最近N个月的趋势
     * GET /api/reports/trend/recent?months=6
     */
    @GetMapping("/trend/recent")
    public ResponseEntity<Map<String, Object>> getRecentMonthsTrend(
            @RequestParam(defaultValue = "6") int months,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            // 验证月份数量
            if (months < 1 || months > 24) {
                response.put("success", false);
                response.put("message", "月份数量必须在1到24之间");
                return ResponseEntity.badRequest().body(response);
            }

            TrendReportDTO trend = reportService.getRecentMonthsTrend(currentUser, months);

            response.put("success", true);
            response.put("data", trend);
            response.put("message", "最近月份趋势获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取最近月份趋势失败: ", e);
            response.put("success", false);
            response.put("message", "获取最近月份趋势失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 获取自定义日期范围的报告
     * POST /api/reports/custom
     */
    @PostMapping("/custom")
    public ResponseEntity<Map<String, Object>> getCustomReport(
            @RequestBody Map<String, Object> request,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                response.put("success", false);
                response.put("message", "用户未登录");
                return ResponseEntity.status(401).body(response);
            }

            // 解析请求参数
            LocalDate startDate = LocalDate.parse((String) request.get("startDate"));
            LocalDate endDate = LocalDate.parse((String) request.get("endDate"));
            String reportType = (String) request.get("reportType");

            Map<String, Object> result = new HashMap<>();

            switch (reportType) {
                case "category-analysis":
                    CategoryReportDTO categoryReport = reportService.getCategoryAnalysis(
                            currentUser, startDate, endDate);
                    result.put("categoryAnalysis", categoryReport);
                    break;

                case "monthly-summary":
                    // 按月汇总
                    result.put("monthlySummary", generateMonthlySummary(
                            currentUser, startDate, endDate));
                    break;

                default:
                    response.put("success", false);
                    response.put("message", "不支持的报表类型: " + reportType);
                    return ResponseEntity.badRequest().body(response);
            }

            response.put("success", true);
            response.put("data", result);
            response.put("message", "自定义报表获取成功");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("获取自定义报表失败: ", e);
            response.put("success", false);
            response.put("message", "获取自定义报表失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 生成月度汇总
     */
    private Map<String, Object> generateMonthlySummary(
            User user, LocalDate startDate, LocalDate endDate) {

        Map<String, Object> summary = new HashMap<>();
        List<Map<String, Object>> monthlyData = new ArrayList<>();

        LocalDate current = startDate.withDayOfMonth(1);
        while (!current.isAfter(endDate)) {
            int year = current.getYear();
            int month = current.getMonthValue();

            Map<String, Object> monthData = reportService.getMonthlyOverview(user, year, month);
            monthData.put("year", year);
            monthData.put("month", month);
            monthData.put("monthLabel", String.format("%d-%02d", year, month));

            monthlyData.add(monthData);
            current = current.plusMonths(1);
        }

        summary.put("period", startDate.toString() + " 至 " + endDate.toString());
        summary.put("monthlyData", monthlyData);

        return summary;
    }
}