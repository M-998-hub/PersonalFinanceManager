<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <c:set var="pageTitle" value="数据查询" scope="request"/>
    <%@ include file="../layout/header.jsp" %>
    <link rel="stylesheet" href="/css/data-query.css">
    <style>
        .stat-card {
            border: none;
            border-radius: 10px;
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
        }
        .transaction-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        .badge-income {
            background-color: rgba(16, 185, 129, 0.1);
            color: #059669;
        }
        .badge-expense {
            background-color: rgba(239, 68, 68, 0.1);
            color: #dc2626;
        }
        .amount-income {
            color: #059669;
            font-weight: 600;
        }
        .amount-expense {
            color: #dc2626;
            font-weight: 600;
        }
    </style>
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
            <!-- 页面标题 -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">数据查询</h1>
                    <p class="text-muted mb-0">多条件筛选和分析您的交易数据</p>
                </div>
                <div>
                    <a href="/transactions" class="btn btn-outline-primary me-2">
                        <i class="fas fa-exchange-alt me-1"></i> 交易管理
                    </a>
                </div>
            </div>

            <!-- 1. 查询条件板块 -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-filter me-2"></i>筛选条件</h5>
                </div>
                <div class="card-body">
                    <form id="queryForm" method="GET" action="/data-query">
                        <div class="row">
                            <!-- 日期范围 -->
                            <div class="col-md-6 mb-3">
                                <label for="startDate" class="form-label">开始日期</label>
                                <input type="date" class="form-control" id="startDate" name="startDate"
                                       value="${queryParams.startDate != null ? queryParams.startDate : firstDayOfMonth}">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="endDate" class="form-label">结束日期</label>
                                <input type="date" class="form-control" id="endDate" name="endDate"
                                       value="${queryParams.endDate != null ? queryParams.endDate : today}">
                            </div>

                            <!-- 交易类型和分类 -->
                            <div class="col-md-6 mb-3">
                                <label for="type" class="form-label">交易类型</label>
                                <select class="form-select" id="type" name="type">
                                    <option value="">所有类型</option>
                                    <option value="INCOME" ${queryParams.type == 'INCOME' ? 'selected' : ''}>收入</option>
                                    <option value="EXPENSE" ${queryParams.type == 'EXPENSE' ? 'selected' : ''}>支出</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="category" class="form-label">分类</label>
                                <select class="form-select" id="category" name="category">
                                    <option value="">所有分类</option>
                                    <!-- 分类将通过JavaScript动态加载 -->
                                </select>
                            </div>

                            <!-- 金额范围 -->
                            <div class="col-md-6 mb-3">
                                <label for="minAmount" class="form-label">最小金额</label>
                                <div class="input-group">
                                    <span class="input-group-text">¥</span>
                                    <input type="number" class="form-control" id="minAmount" name="minAmount"
                                           step="0.01" placeholder="0.00"
                                           value="${queryParams.minAmount}">
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="maxAmount" class="form-label">最大金额</label>
                                <div class="input-group">
                                    <span class="input-group-text">¥</span>
                                    <input type="number" class="form-control" id="maxAmount" name="maxAmount"
                                           step="0.01" placeholder="不限"
                                           value="${queryParams.maxAmount}">
                                </div>
                            </div>

                            <!-- 关键词搜索 -->
                            <div class="col-12 mb-3">
                                <label for="keyword" class="form-label">关键词搜索</label>
                                <input type="text" class="form-control" id="keyword" name="keyword"
                                       placeholder="搜索描述或分类..."
                                       value="${queryParams.keyword}">
                            </div>

                            <!-- 按钮组 -->
                            <div class="col-12">
                                <div class="d-flex gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-search me-2"></i>查询
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary" onclick="resetForm()">
                                        <i class="fas fa-redo me-2"></i>重置
                                    </button>
                                    <button type="button" class="btn btn-success" onclick="exportToCsv()">
                                        <i class="fas fa-download me-2"></i>导出CSV
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- 2. 统计摘要板块 -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card stat-card">
                        <div class="card-body text-center">
                            <h6 class="text-muted">交易总数</h6>
                            <h3 id="totalCount" class="mb-0">0</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card">
                        <div class="card-body text-center">
                            <h6 class="text-muted">总收入</h6>
                            <h3 id="totalIncome" class="text-success mb-0">¥0.00</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card">
                        <div class="card-body text-center">
                            <h6 class="text-muted">总支出</h6>
                            <h3 id="totalExpense" class="text-danger mb-0">¥0.00</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card">
                        <div class="card-body text-center">
                            <h6 class="text-muted">净余额</h6>
                            <h3 id="netBalance" class="text-primary mb-0">¥0.00</h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 3. 查询结果板块 -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="fas fa-list me-2"></i>查询结果</h5>
                    <div class="d-flex align-items-center">
                        <span class="me-3 text-muted small" id="resultSummary">共 0 条记录</span>
                        <select class="form-select form-select-sm w-auto" id="pageSize">
                            <option value="10">10条/页</option>
                            <option value="20" selected>20条/页</option>
                            <option value="50">50条/页</option>
                            <option value="100">100条/页</option>
                        </select>
                    </div>
                </div>
                <div class="card-body p-0">
                    <!-- 加载状态 -->
                    <div id="loadingResults" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">加载中...</span>
                        </div>
                        <p class="mt-2 text-muted">正在查询数据...</p>
                    </div>

                    <!-- 空状态 -->
                    <div id="emptyResults" class="text-center py-5" style="display: none;">
                        <i class="fas fa-search fa-3x text-muted mb-3"></i>
                        <p class="text-muted">暂无查询结果</p>
                        <p class="text-muted small">请调整筛选条件后重试</p>
                    </div>

                    <!-- 结果表格 -->
                    <div id="resultsTable" style="display: none;">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                <tr>
                                    <th>日期</th>
                                    <th>类型</th>
                                    <th>分类</th>
                                    <th>描述</th>
                                    <th class="text-end">金额</th>
                                </tr>
                                </thead>
                                <tbody id="resultsBody">
                                <!-- 结果将通过JavaScript动态加载 -->
                                </tbody>
                            </table>
                        </div>

                        <!-- 分页 -->
                        <div class="d-flex justify-content-center py-3 border-top">
                            <nav id="pagination">
                                <!-- 分页将通过JavaScript动态生成 -->
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>

<script>
    // 初始化页面参数
    window.pageConfig = {
        currentPage: ${queryParams.page},
        today: '${today}',
        firstDayOfMonth: '${firstDayOfMonth}'
    };
</script>
<script src="/js/data-query.js"></script>
</body>
</html>