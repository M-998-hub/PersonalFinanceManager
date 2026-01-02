package demo.controller;

import demo.dto.TransactionDTO;
import demo.entity.User;
import demo.service.DataQueryService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/data-query")
@RequiredArgsConstructor
public class DataQueryController {

    private final DataQueryService dataQueryService;

    /**
     * 查询交易数据
     */
    @GetMapping("/transactions")
    public ResponseEntity<Map<String, Object>> queryTransactions(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minAmount,
            @RequestParam(required = false) BigDecimal maxAmount,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        // 检查用户登录
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "用户未登录");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 查询数据
            Page<TransactionDTO> transactions = dataQueryService.queryTransactions(
                    currentUser,
                    startDate, endDate,
                    type, category,
                    minAmount, maxAmount,
                    keyword,
                    page, size
            );

            // 获取统计数据
            Map<String, Object> stats = dataQueryService.getQueryStats(
                    currentUser,
                    startDate, endDate,
                    type, category,
                    minAmount, maxAmount,
                    keyword
            );

            response.put("success", true);
            response.put("data", transactions.getContent());
            response.put("totalElements", transactions.getTotalElements());
            response.put("totalPages", transactions.getTotalPages());
            response.put("currentPage", page);
            response.put("pageSize", size);
            response.put("stats", stats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "查询失败: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 导出查询结果为CSV
     */
    @GetMapping("/export/csv")
    public ResponseEntity<byte[]> exportToCsv(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minAmount,
            @RequestParam(required = false) BigDecimal maxAmount,
            @RequestParam(required = false) String keyword,
            HttpSession session) {

        // 检查用户登录
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        try {
            String csvContent = dataQueryService.exportToCsv(
                    currentUser,
                    startDate, endDate,
                    type, category,
                    minAmount, maxAmount,
                    keyword
            );

            byte[] csvBytes = csvContent.getBytes("UTF-8");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment",
                    "transactions_" + LocalDate.now() + ".csv");
            headers.setContentLength(csvBytes.length);

            return new ResponseEntity<>(csvBytes, headers, HttpStatus.OK);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * 获取可用分类列表
     */
    @GetMapping("/categories")
    public ResponseEntity<List<String>> getCategories(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<String> categories = dataQueryService.getUserCategories(currentUser);
        return ResponseEntity.ok(categories);
    }
}