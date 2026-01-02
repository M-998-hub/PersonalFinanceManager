<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <c:set var="pageTitle" value="预算管理" scope="request"/>
    <%@ include file="../layout/header.jsp" %>
    <link rel="stylesheet" href="/css/budgets.css">
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
            <!-- 页面标题和操作按钮 -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">预算管理</h1>
                    <p class="text-muted mb-0">设置和管理您的月度预算</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addBudgetModal">
                        <i class="fas fa-plus me-2"></i>添加预算
                    </button>
                </div>
            </div>

            <!-- 预算预警卡片 -->
            <c:if test="${not empty budgetAlerts}">
                <div class="row mb-4">
                    <c:forEach var="alert" items="${budgetAlerts}">
                        <c:if test="${alert.alertLevel != 'NORMAL'}">
                            <div class="col-12">
                                <div class="alert
                                    <c:choose>
                                        <c:when test="${alert.alertLevel == 'OVER_BUDGET'}">alert-danger</c:when>
                                        <c:when test="${alert.alertLevel == 'NEAR_LIMIT'}">alert-warning</c:when>
                                        <c:otherwise>alert-info</c:otherwise>
                                    </c:choose>
                                    alert-dismissible fade show">
                                    <div class="d-flex align-items-center">
                                        <i class="fas
                                            <c:choose>
                                                <c:when test="${alert.alertLevel == 'OVER_BUDGET'}">fa-exclamation-triangle</c:when>
                                                <c:when test="${alert.alertLevel == 'NEAR_LIMIT'}">fa-exclamation-circle</c:when>
                                                <c:otherwise>fa-info-circle</c:otherwise>
                                            </c:choose>
                                            me-3 fs-4"></i>
                                        <div class="flex-grow-1">
                                            <h5 class="alert-heading mb-1">
                                                预算预警：${alert.category}
                                            </h5>
                                            <div class="mb-0">
                                                预算限额：<fmt:formatNumber value="${alert.budgetLimit}" type="currency"/>
                                                ・ 已花费：<fmt:formatNumber value="${alert.actualSpending}" type="currency"/>
                                                ・ 使用率：<fmt:formatNumber value="${alert.usagePercentage}" pattern="0.00"/>%
                                                <c:if test="${alert.overAmount > 0}">
                                                    ・ 超支：<span class="text-danger"><fmt:formatNumber value="${alert.overAmount}" type="currency"/></span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>

            <!-- 预算概览卡片 -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card stat-card total-budget-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-wallet text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总预算限额</h6>
                                    <h3 class="mb-0 text-white" id="totalBudgetLimit">¥0.00</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card total-spent-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-money-bill-wave text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总已花费</h6>
                                    <h3 class="mb-0 text-white" id="totalSpent">¥0.00</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card overall-usage-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon me-3">
                                    <i class="fas fa-chart-line text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总体使用率</h6>
                                    <h3 class="mb-0 text-white" id="overallUsage">0%</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 预算列表 -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="fas fa-list me-2"></i>预算列表</h5>
                    <div class="d-flex align-items-center">
                        <span class="me-3 text-muted small" id="budgetSummary">共 0 个预算</span>
                        <select class="form-select form-select-sm w-auto" id="viewType">
                            <option value="all">所有预算</option>
                            <option value="active">仅活动预算</option>
                            <option value="alert">仅预警预算</option>
                        </select>
                    </div>
                </div>
                <div class="card-body p-0">
                    <!-- 加载状态 -->
                    <div id="loadingBudgets" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">加载中...</span>
                        </div>
                        <p class="mt-2 text-muted">正在加载预算数据...</p>
                    </div>

                    <!-- 空状态 -->
                    <div id="emptyBudgets" class="text-center py-5" style="display: none;">
                        <i class="fas fa-wallet fa-3x text-muted mb-3"></i>
                        <p class="text-muted">暂无预算设置</p>
                        <p class="text-muted small">点击"添加预算"按钮开始设置您的第一个预算</p>
                        <button type="button" class="btn btn-primary mt-2" data-bs-toggle="modal" data-bs-target="#addBudgetModal">
                            <i class="fas fa-plus me-2"></i>添加预算
                        </button>
                    </div>

                    <!-- 预算表格 -->
                    <div id="budgetsTable" style="display: none;">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                <tr>
                                    <th>分类</th>
                                    <th>预算限额</th>
                                    <th>已花费</th>
                                    <th>剩余</th>
                                    <th>使用率</th>
                                    <th>状态</th>
                                    <th class="text-end">操作</th>
                                </tr>
                                </thead>
                                <tbody id="budgetsBody">
                                <!-- 预算数据将通过JavaScript动态加载 -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 月度预算趋势（可选） -->
            <div class="card mt-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-chart-bar me-2"></i>月度预算趋势</h5>
                </div>
                <div class="card-body">
                    <div class="text-center py-5">
                        <i class="fas fa-chart-area fa-3x text-muted mb-3"></i>
                        <p class="text-muted">预算趋势图表</p>
                        <p class="text-muted small">随着数据积累，这里将显示您的预算使用趋势</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 添加预算模态框 -->
<div class="modal fade" id="addBudgetModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">添加预算</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="addBudgetForm">
                <div class="modal-body">
                    <!-- 分类 -->
                    <div class="mb-3">
                        <label for="budgetCategory" class="form-label">分类 *</label>
                        <select class="form-select" id="budgetCategory" required>
                            <option value="">请选择分类</option>
                            <c:forEach var="category" items="${commonCategories}">
                                <option value="${category}">${category}</option>
                            </c:forEach>
                            <option value="custom">自定义分类...</option>
                        </select>
                        <input type="text" class="form-control mt-2" id="customCategory"
                               placeholder="输入自定义分类" style="display: none;">
                    </div>

                    <!-- 月度限额 -->
                    <div class="mb-3">
                        <label for="monthlyLimit" class="form-label">月度预算限额 *</label>
                        <div class="input-group">
                            <span class="input-group-text">¥</span>
                            <input type="number" class="form-control" id="monthlyLimit"
                                   step="0.01" min="0.01" placeholder="0.00" required>
                        </div>
                        <div class="form-text">设置该分类每月的最大花费金额</div>
                    </div>

                    <!-- 所属月份 -->
                    <div class="mb-3">
                        <label for="budgetMonth" class="form-label">预算月份</label>
                        <input type="month" class="form-control" id="budgetMonth"
                               value="${currentMonth}">
                        <div class="form-text">默认为当前月份</div>
                    </div>

                    <!-- 备注（可选） -->
                    <div class="mb-3">
                        <label for="budgetNotes" class="form-label">备注</label>
                        <textarea class="form-control" id="budgetNotes" rows="2"
                                  placeholder="可选的预算说明..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="submit" class="btn btn-primary">保存预算</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 编辑预算模态框 -->
<div class="modal fade" id="editBudgetModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">编辑预算</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="editBudgetForm">
                <input type="hidden" id="editBudgetId">
                <div class="modal-body">
                    <!-- 编辑表单内容将通过JavaScript动态填充 -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="submit" class="btn btn-primary">保存修改</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 删除确认模态框 -->
<div class="modal fade" id="deleteBudgetModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">确认删除</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>确定要删除这个预算吗？此操作不可撤销。</p>
                <div id="deleteBudgetInfo"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" onclick="confirmDeleteBudget()">确认删除</button>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>

<script src="/js/budgets.js"></script>
<script>
    // 页面初始化
    document.addEventListener('DOMContentLoaded', function() {
        console.log('预算管理页面加载完成');

        // 加载预算数据
        loadBudgets();

        // 设置筛选类型改变事件
        document.getElementById('viewType')?.addEventListener('change', function() {
            filterBudgets(this.value);
        });

        // 设置分类选择改变事件
        document.getElementById('budgetCategory')?.addEventListener('change', function() {
            const customInput = document.getElementById('customCategory');
            customInput.style.display = this.value === 'custom' ? 'block' : 'none';
            if (this.value !== 'custom') {
                customInput.value = '';
            }
        });

        // 检查是否有预警分类需要高亮显示
        const alertCategory = '${alertCategory}';
        if (alertCategory) {
            setTimeout(() => {
                highlightBudgetRow(alertCategory);
            }, 1000);
        }
    });

    // 高亮显示预警行
    function highlightBudgetRow(category) {
        const rows = document.querySelectorAll('#budgetsBody tr');
        rows.forEach(row => {
            if (row.querySelector('td:first-child').textContent.includes(category)) {
                row.classList.add('table-warning');
                setTimeout(() => {
                    row.classList.remove('table-warning');
                }, 3000);
            }
        });
    }
</script>
</body>
</html>