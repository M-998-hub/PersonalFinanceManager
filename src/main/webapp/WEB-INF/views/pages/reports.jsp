<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <c:set var="pageTitle" value="报表统计" scope="request"/>
    <%@ include file="../layout/header.jsp" %>
    <link rel="stylesheet" href="/css/reports.css">
    <!-- 引入图表库 -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns/dist/chartjs-adapter-date-fns.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid">
    <%@ include file="../layout/navbar.jsp" %>

    <div class="row">
        <!-- 侧边栏 -->
        <div class="col-md-3 col-lg-2">
            <%@ include file="../layout/sidebar.jsp" %>
        </div>

        <!-- 主内容区 -->
        <div class="col-md-9 col-lg-10">
            <!-- 快速统计卡片 -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card stat-card income-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-money-bill-wave text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总收入</h6>
                                    <h3 class="mb-0 text-white" id="totalIncome">¥0.00</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card expense-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-shopping-cart text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总支出</h6>
                                    <h3 class="mb-0 text-white" id="totalExpense">¥0.00</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card balance-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-piggy-bank text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总余额</h6>
                                    <h3 class="mb-0 text-white" id="totalBalance">¥0.00</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card monthly-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-calendar-alt text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">本月结余</h6>
                                    <h3 class="mb-0 text-white" id="monthlyNet">¥0.00</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 报表类型选择 -->
            <div class="card mb-4">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-outline-primary active"
                                        data-report-type="monthly" onclick="switchReport('monthly')">
                                    <i class="fas fa-calendar-alt me-2"></i>月度收支统计
                                </button>
                                <button type="button" class="btn btn-outline-primary"
                                        data-report-type="trend" onclick="switchReport('trend')">
                                    <i class="fas fa-chart-line me-2"></i>年度趋势统计
                                </button>
                                <button type="button" class="btn btn-outline-primary"
                                        data-report-type="categories" onclick="switchReport('categories')">
                                    <i class="fas fa-chart-pie me-2"></i>类别占比分析
                                </button>
                                <button type="button" class="btn btn-outline-primary"
                                        data-report-type="export" onclick="switchReport('export')">
                                    <i class="fas fa-file-export me-2"></i>报表导出
                                </button>
                            </div>
                        </div>
                        <div class="col-md-4 text-end">
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-calendar"></i>
                                </span>
                                <select class="form-select" id="reportPeriod">
                                    <option value="current">本月</option>
                                    <option value="last">上月</option>
                                    <option value="quarter">本季度</option>
                                    <option value="year">本年</option>
                                    <option value="custom">自定义</option>
                                </select>
                                <button class="btn btn-primary" onclick="applyDateFilter()">
                                    <i class="fas fa-filter"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 自定义日期范围选择器（默认隐藏） -->
            <div class="card mb-4" id="customDateRange" style="display: none;">
                <div class="card-body">
                    <div class="row align-items-center">
                        <div class="col-md-3">
                            <label class="form-label">开始日期</label>
                            <input type="date" class="form-control" id="startDate"
                                   value="${lastMonthFormatted}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">结束日期</label>
                            <input type="date" class="form-control" id="endDate"
                                   value="${currentDateFormatted}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">报表类型</label>
                            <select class="form-select" id="customReportType">
                                <option value="monthly">月度统计</option>
                                <option value="trend">趋势分析</option>
                                <option value="categories">类别分析</option>
                                <option value="summary">汇总报告</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">&nbsp;</label>
                            <button class="btn btn-primary w-100" onclick="generateCustomReport()">
                                <i class="fas fa-play me-2"></i>生成
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 月度收支统计报表 -->
            <div class="report-section" id="monthlyReport">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <i class="fas fa-calendar-alt me-2"></i>
                            月度收支统计
                            <span class="ms-2 text-muted" id="monthlyReportTitle">${currentYear}年${currentMonth}月</span>
                        </h5>
                        <div>
                            <button class="btn btn-sm btn-outline-secondary me-2" onclick="prevMonth()">
                                <i class="fas fa-chevron-left"></i> 上个月
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="nextMonth()">
                                下个月 <i class="fas fa-chevron-right"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <!-- 月度概览 -->
                        <div class="row mb-4">
                            <div class="col-md-3 text-center">
                                <div class="monthly-stat">
                                    <div class="stat-value" id="monthlyIncome">¥0.00</div>
                                    <div class="stat-label">月度收入</div>
                                </div>
                            </div>
                            <div class="col-md-3 text-center">
                                <div class="monthly-stat">
                                    <div class="stat-value" id="monthlyExpense">¥0.00</div>
                                    <div class="stat-label">月度支出</div>
                                </div>
                            </div>
                            <div class="col-md-3 text-center">
                                <div class="monthly-stat">
                                    <div class="stat-value" id="monthlyBalance">¥0.00</div>
                                    <div class="stat-label">月度结余</div>
                                </div>
                            </div>
                            <div class="col-md-3 text-center">
                                <div class="monthly-stat">
                                    <div class="stat-value" id="transactionCount">0</div>
                                    <div class="stat-label">交易笔数</div>
                                </div>
                            </div>
                        </div>

                        <!-- 月度趋势图 -->
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <div class="chart-container">
                                    <canvas id="monthlyTrendChart"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- 分类排名 -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0"><i class="fas fa-arrow-up text-success me-2"></i>收入分类排名</h6>
                                    </div>
                                    <div class="card-body">
                                        <div id="incomeCategories">
                                            <div class="text-center py-4">
                                                <div class="spinner-border spinner-border-sm" role="status"></div>
                                                <p class="mt-2 text-muted">加载中...</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0"><i class="fas fa-arrow-down text-danger me-2"></i>支出分类排名</h6>
                                    </div>
                                    <div class="card-body">
                                        <div id="expenseCategories">
                                            <div class="text-center py-4">
                                                <div class="spinner-border spinner-border-sm" role="status"></div>
                                                <p class="mt-2 text-muted">加载中...</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 年度趋势统计报表 -->
            <div class="report-section" id="trendReport" style="display: none;">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-line me-2"></i>
                            年度趋势统计
                        </h5>
                        <div>
                            <select class="form-select form-select-sm" id="trendYear" onchange="loadTrendReport()">
                                <option value="${currentYear}">${currentYear}年</option>
                                <option value="${currentYear - 1}">${currentYear - 1}年</option>
                                <option value="${currentYear - 2}">${currentYear - 2}年</option>
                            </select>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <div class="chart-container">
                                    <canvas id="yearlyTrendChart"></canvas>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0">年度统计</h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="mb-3">
                                            <label class="form-label">总收入</label>
                                            <h4 class="text-success" id="yearlyTotalIncome">¥0.00</h4>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">总支出</label>
                                            <h4 class="text-danger" id="yearlyTotalExpense">¥0.00</h4>
                                        </div>
                                        <div>
                                            <label class="form-label">年度结余</label>
                                            <h4 class="text-primary" id="yearlyBalance">¥0.00</h4>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 月度详情表格 -->
                        <div class="row">
                            <div class="col-md-12">
                                <div class="table-responsive">
                                    <table class="table table-bordered" id="trendTable">
                                        <thead>
                                        <tr>
                                            <th>月份</th>
                                            <th>收入</th>
                                            <th>支出</th>
                                            <th>结余</th>
                                            <th>收入趋势</th>
                                            <th>支出趋势</th>
                                        </tr>
                                        </thead>
                                        <tbody id="trendTableBody">
                                        <!-- 通过JS填充 -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 类别占比分析报表 -->
            <div class="report-section" id="categoryReport" style="display: none;">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-pie me-2"></i>
                            类别占比分析
                        </h5>
                        <div>
                            <select class="form-select form-select-sm" id="categoryPeriod" onchange="loadCategoryAnalysis()">
                                <option value="month">本月</option>
                                <option value="quarter">本季度</option>
                                <option value="year">本年</option>
                            </select>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="chart-container">
                                    <canvas id="categoryPieChart"></canvas>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="chart-container">
                                    <canvas id="categoryBarChart"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- 分类详情 -->
                        <div class="row mt-4">
                            <div class="col-md-12">
                                <div class="table-responsive">
                                    <table class="table table-bordered" id="categoryTable">
                                        <thead>
                                        <tr>
                                            <th>分类</th>
                                            <th>类型</th>
                                            <th>金额</th>
                                            <th>占比</th>
                                            <th>平均每月</th>
                                        </tr>
                                        </thead>
                                        <tbody id="categoryTableBody">
                                        <!-- 通过JS填充 -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 报表导出 -->
            <div class="report-section" id="exportReport" style="display: none;">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="fas fa-file-export me-2"></i>
                            报表导出
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="mb-4">
                                    <h6>导出选项</h6>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" id="exportMonthly" checked>
                                        <label class="form-check-label" for="exportMonthly">
                                            月度收支报告
                                        </label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" id="exportTrend">
                                        <label class="form-check-label" for="exportTrend">
                                            年度趋势报告
                                        </label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" id="exportCategories">
                                        <label class="form-check-label" for="exportCategories">
                                            类别分析报告
                                        </label>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <h6>日期范围</h6>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <label class="form-label">开始日期</label>
                                            <!-- 使用字符串日期 -->
                                            <input type="date" class="form-control" id="exportStartDate"
                                                   value="${exportStartDate}">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">结束日期</label>
                                            <input type="date" class="form-control" id="exportEndDate"
                                                   value="${exportEndDate}">
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <h6>导出格式</h6>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="exportFormat" id="formatExcel" value="excel" checked>
                                        <label class="form-check-label" for="formatExcel">Excel (.xlsx)</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="exportFormat" id="formatPDF" value="pdf">
                                        <label class="form-check-label" for="formatPDF">PDF (.pdf)</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="exportFormat" id="formatCSV" value="csv">
                                        <label class="form-check-label" for="formatCSV">CSV (.csv)</label>
                                    </div>
                                </div>

                                <button class="btn btn-primary" onclick="exportReports()">
                                    <i class="fas fa-download me-2"></i>导出报表
                                </button>
                            </div>

                            <div class="col-md-4">
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0">导出历史</h6>
                                    </div>
                                    <div class="card-body">
                                        <div id="exportHistory">
                                            <div class="text-center py-3">
                                                <p class="text-muted">暂无导出记录</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>

<script src="/js/reports.js"></script>
<script>
    // 页面初始化
    document.addEventListener('DOMContentLoaded', function() {
        console.log('报表统计页面加载完成');

        // 加载快速统计
        loadQuickStats();

        // 根据URL参数显示对应报表
        const urlParams = new URLSearchParams(window.location.search);
        const reportType = urlParams.get('reportType') || '${defaultReportType}';
        switchReport(reportType);

        // 设置日期筛选器事件
        document.getElementById('reportPeriod')?.addEventListener('change', function() {
            if (this.value === 'custom') {
                document.getElementById('customDateRange').style.display = 'block';
            } else {
                document.getElementById('customDateRange').style.display = 'none';
                applyDateFilter();
            }
        });
    });
</script>
</body>
</html>