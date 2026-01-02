<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <c:set var="pageTitle" value="交易管理" scope="request"/>
    <%@ include file="../layout/header.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/transactions.css">
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
                    <h1 class="h3 mb-0">交易管理</h1>
                    <p class="text-muted mb-0">记录和管理您的收入和支出</p>
                </div>
                <div>
                    <a href="/data-query" class="btn btn-outline-primary">
                        <i class="fas fa-search me-1"></i> 数据查询
                    </a>
                </div>
            </div>

            <!-- 1. 余额展示板块 -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card balance-card income-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="balance-icon me-3">
                                    <i class="fas fa-arrow-down text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总收入</h6>
                                    <h3 class="mb-0 text-white">
                                        <fmt:formatNumber value="${totalIncome}" type="currency" pattern="¥ #,##0.00"/>
                                    </h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card balance-card expense-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="balance-icon me-3">
                                    <i class="fas fa-arrow-up text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">总支出</h6>
                                    <h3 class="mb-0 text-white">
                                        <fmt:formatNumber value="${totalExpense}" type="currency" pattern="¥ #,##0.00"/>
                                    </h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card balance-card balance-net-card">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="balance-icon me-3">
                                    <i class="fas fa-balance-scale text-white"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1">净余额</h6>
                                    <h3 class="mb-0 text-white">
                                        <fmt:formatNumber value="${netBalance}" type="currency" pattern="¥ #,##0.00"/>
                                    </h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- 2. 添加交易板块 -->
                <div class="col-lg-5 mb-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-plus-circle me-2"></i>添加交易</h5>
                        </div>
                        <div class="card-body">
                            <form id="addTransactionForm" action="/api/transactions" method="POST"
                                  onsubmit="return validateForm()">
                                <!-- CSRF Token（如果需要） -->
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                                <!-- 交易类型 -->
                                <div class="mb-3">
                                    <label class="form-label">交易类型 *</label>
                                    <div class="btn-group w-100" role="group">
                                        <input type="radio" class="btn-check" name="type" id="typeIncome"
                                               value="INCOME" checked>
                                        <label class="btn btn-outline-success" for="typeIncome">
                                            <i class="fas fa-arrow-down me-1"></i> 收入
                                        </label>
                                        <input type="radio" class="btn-check" name="type" id="typeExpense"
                                               value="EXPENSE">
                                        <label class="btn btn-outline-danger" for="typeExpense">
                                            <i class="fas fa-arrow-up me-1"></i> 支出
                                        </label>
                                    </div>
                                </div>

                                <!-- 金额 -->
                                <div class="mb-3">
                                    <label for="amount" class="form-label">金额 *</label>
                                    <div class="input-group">
                                        <span class="input-group-text">¥</span>
                                        <input type="number" class="form-control" id="amount" name="amount"
                                               placeholder="0.00" step="0.01" min="0.01" required>
                                    </div>
                                </div>

                                <!-- 分类 -->
                                <div class="mb-3">
                                    <label for="category" class="form-label">分类 *</label>
                                    <select class="form-select" id="category" name="category" required>
                                        <option value="">请选择分类</option>
                                        <optgroup label="收入">
                                            <option value="工资">工资</option>
                                            <option value="奖金">奖金</option>
                                            <option value="投资">投资</option>
                                            <option value="其他收入">其他收入</option>
                                        </optgroup>
                                        <optgroup label="支出">
                                            <option value="餐饮">餐饮</option>
                                            <option value="交通">交通</option>
                                            <option value="购物">购物</option>
                                            <option value="娱乐">娱乐</option>
                                            <option value="房租">房租</option>
                                            <option value="水电费">水电费</option>
                                            <option value="其他支出">其他支出</option>
                                        </optgroup>
                                    </select>
                                </div>

                                <!-- 日期 -->
                                <div class="mb-3">
                                    <label for="date" class="form-label">日期 *</label>
                                    <input type="date" class="form-control" id="date" name="date"
                                           value="${currentDate}" required>
                                </div>

                                <!-- 描述 -->
                                <div class="mb-3">
                                    <label for="description" class="form-label">描述</label>
                                    <textarea class="form-control" id="description" name="description"
                                              rows="2" placeholder="交易备注（可选）"></textarea>
                                </div>

                                <!-- 提交按钮 -->
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary btn-lg">
                                        <i class="fas fa-check me-2"></i>添加交易
                                    </button>
                                </div>
                            </form>

                            <!-- 表单提交后的消息显示区域 -->
                            <div id="formMessage" class="mt-3" style="display: none;"></div>
                        </div>
                    </div>
                </div>

                <!-- 3. 交易操作板块 -->
                <div class="col-lg-7">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-list me-2"></i>最近交易</h5>
                            <div>
                                <a href="/transactions?refresh=true" class="btn btn-sm btn-outline-secondary">
                                    <i class="fas fa-sync-alt"></i>
                                </a>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${not empty recentTransactions and not recentTransactions.isEmpty()}">
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead>
                                            <tr>
                                                <th>日期</th>
                                                <th>分类</th>
                                                <th>描述</th>
                                                <th>金额</th>
                                                <th>操作</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="transaction" items="${recentTransactions}">
                                                <tr>
                                                    <td>${transaction.date}</td>
                                                    <td>
                                                            <span class="transaction-badge
                                                                  <c:choose>
                                                                      <c:when test="${transaction.type == 'INCOME'}">badge-income</c:when>
                                                                      <c:otherwise>badge-expense</c:otherwise>
                                                                  </c:choose>">
                                                                    ${transaction.category}
                                                            </span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-medium">
                                                                ${transaction.description}
                                                        </div>
                                                    </td>
                                                    <td class="
                                                            <c:choose>
                                                                <c:when test="${transaction.type == 'INCOME'}">amount-income</c:when>
                                                                <c:otherwise>amount-expense</c:otherwise>
                                                            </c:choose>
                                                            fw-bold">
                                                        <c:choose>
                                                            <c:when test="${transaction.type == 'INCOME'}">+</c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                        <fmt:formatNumber value="${transaction.amount}"
                                                                          type="currency" pattern="¥ #,##0.00"/>
                                                    </td>
                                                    <td>
                                                        <div class="d-flex gap-2">
                                                            <button class="btn btn-sm btn-outline-primary btn-action"
                                                                    onclick="editTransaction(${transaction.id})"
                                                                    title="编辑">
                                                                <i class="fas fa-edit fa-sm"></i>
                                                            </button>
                                                            <button class="btn btn-sm btn-outline-danger btn-action"
                                                                    onclick="deleteTransaction(${transaction.id})"
                                                                    title="删除">
                                                                <i class="fas fa-trash fa-sm"></i>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- 查看更多 -->
                                    <div class="text-center py-3 border-top">
                                        <a href="/data-query" class="btn btn-outline-primary btn-sm">
                                            <i class="fas fa-search me-1"></i> 查看更多交易记录
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- 空状态 -->
                                    <div class="text-center py-5">
                                        <i class="fas fa-receipt fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">暂无交易记录</p>
                                        <p class="text-muted small">添加您的第一笔交易来开始记录</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 编辑交易模态框 - 修改form标签 -->
<div class="modal fade" id="editTransactionModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">编辑交易</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <!-- 修改为普通的form，不使用method参数 -->
            <form id="editTransactionForm">
                <div class="modal-body">
                    <!-- 隐藏字段 -->
                    <input type="hidden" id="editTransactionId">

                    <!-- 交易类型 -->
                    <div class="mb-3">
                        <label class="form-label">交易类型</label>
                        <div class="btn-group w-100" role="group">
                            <input type="radio" class="btn-check" name="editType" id="editTypeIncome" value="INCOME">
                            <label class="btn btn-outline-success" for="editTypeIncome">
                                <i class="fas fa-arrow-down me-1"></i> 收入
                            </label>
                            <input type="radio" class="btn-check" name="editType" id="editTypeExpense" value="EXPENSE">
                            <label class="btn btn-outline-danger" for="editTypeExpense">
                                <i class="fas fa-arrow-up me-1"></i> 支出
                            </label>
                        </div>
                    </div>

                    <!-- 其他字段保持不变 -->
                    <div class="mb-3">
                        <label for="editAmount" class="form-label">金额</label>
                        <div class="input-group">
                            <span class="input-group-text">¥</span>
                            <input type="number" class="form-control" id="editAmount" name="editAmount"
                                   step="0.01" min="0.01" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="editCategory" class="form-label">分类</label>
                        <select class="form-select" id="editCategory" name="editCategory" required>
                            <!-- 选项将通过JS动态填充 -->
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="editDate" class="form-label">日期</label>
                        <input type="date" class="form-control" id="editDate" name="editDate" required>
                    </div>

                    <div class="mb-3">
                        <label for="editDescription" class="form-label">描述</label>
                        <textarea class="form-control" id="editDescription" name="editDescription" rows="2"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="button" class="btn btn-primary" onclick="updateTransaction()">保存修改</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 删除确认模态框 - 简化版本 -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">确认删除</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>确定要删除这笔交易吗？此操作不可撤销。</p>
                <div id="deleteTransactionInfo"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" onclick="confirmDelete()">确认删除</button>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>

<!-- CSRF令牌隐藏域（如果需要） -->
<c:if test="${not empty _csrf.token}">
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
</c:if>

<!-- 引入外部JS文件 -->
<script src="/js/transactions.js"></script>

<!-- 在页面中传递必要的变量 -->
<script>
    // 将必要的JSP变量传递给JavaScript
    const contextPath = '${pageContext.request.contextPath}';
    const csrfTokenElement = document.querySelector('meta[name="_csrf"]');

    // 如果需要，可以在这里设置全局变量
    if (typeof apiBase !== 'undefined') {
        // 如果contextPath不是空的，更新apiBase
        if (contextPath && contextPath !== '') {
            apiBase = contextPath + '/api/transactions';
        }
    }

    // 调试信息
    console.log('页面初始化完成');
    console.log('Context Path:', contextPath);
    console.log('CSRF Token:', csrfTokenElement ? csrfTokenElement.content : '未设置');
</script>
</body>
</html>