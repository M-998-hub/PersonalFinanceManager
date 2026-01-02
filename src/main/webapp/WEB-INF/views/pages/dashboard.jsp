<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <c:set var="pageTitle" value="财务概况" scope="request"/>
    <%@ include file="../layout/header.jsp" %>
</head>
<body>
<div class="container-fluid">
    <%@ include file="../layout/navbar.jsp" %>

    <div class="row">
        <!-- 侧边栏 -->
        <div class="col-md-3 col-lg-2">
            <%@ include file="../layout/sidebar.jsp" %>
        </div>

        <!-- 主内容 -->
        <div class="col-md-9 col-lg-10">
            <!-- 统计卡片 -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card stat-card">
                        <div class="card-body">
                            <h6 class="text-muted">本月收入</h6>
                            <h3 class="text-success">
                                <fmt:formatNumber value="${monthlyIncome}" type="currency" pattern="¥ #,##0.00"/>
                            </h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card">
                        <div class="card-body">
                            <h6 class="text-muted">本月支出</h6>
                            <h3 class="text-danger">
                                <fmt:formatNumber value="${monthlyExpense}" type="currency" pattern="¥ #,##0.00"/>
                            </h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card">
                        <div class="card-body">
                            <h6 class="text-muted">当前余额</h6>
                            <h3 class="text-primary">
                                <fmt:formatNumber value="${currentBalance}" type="currency" pattern="¥ #,##0.00"/>
                            </h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 最近交易 -->
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between">
                    <h5 class="mb-0">最近交易</h5>
                    <a href="/transactions" class="btn btn-sm btn-primary">查看全部</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                            <tr>
                                <th>日期</th>
                                <th>类别</th>
                                <th>描述</th>
                                <th>类型</th>
                                <th class="text-end">金额</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:choose>
                                <c:when test="${not empty recentTransactions and not recentTransactions.isEmpty()}">
                                    <c:forEach var="transaction" items="${recentTransactions}">
                                        <tr>
                                            <td>${transaction.date}</td>
                                            <td>${transaction.category}</td>
                                            <td>${transaction.description}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${transaction.type == 'INCOME'}">
                                                        <span class="badge bg-success">收入</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger">支出</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-end">
                                                <c:choose>
                                                    <c:when test="${transaction.type == 'INCOME'}">
                                                                <span class="text-success">
                                                                    +<fmt:formatNumber value="${transaction.amount}" type="currency" pattern="¥ #,##0.00"/>
                                                                </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                                <span class="text-danger">
                                                                    -<fmt:formatNumber value="${transaction.amount}" type="currency" pattern="¥ #,##0.00"/>
                                                                </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="text-center py-4 text-muted">
                                            <i class="fas fa-receipt fa-2x mb-3"></i>
                                            <p>暂无交易记录</p>
                                            <a href="/transactions/new" class="btn btn-outline-primary btn-sm">添加第一笔交易</a>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- 快速添加卡片 -->
            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">快速记账</h5>
                            <form id="quickAddForm">
                                <div class="mb-3">
                                    <select class="form-select" id="quickType">
                                        <option value="INCOME">收入</option>
                                        <option value="EXPENSE">支出</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <input type="number" step="0.01" class="form-control"
                                           placeholder="金额" id="quickAmount" required>
                                </div>
                                <div class="mb-3">
                                    <input type="text" class="form-control"
                                           placeholder="描述（可选）" id="quickDescription">
                                </div>
                                <button type="button" class="btn btn-primary w-100"
                                        onclick="submitQuickTransaction()">
                                    添加交易
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../layout/footer.jsp" %>

<script>
    // 快速添加交易
    async function submitQuickTransaction() {
        const type = document.getElementById('quickType').value;
        const amount = document.getElementById('quickAmount').value;
        const description = document.getElementById('quickDescription').value;

        if (!amount || parseFloat(amount) <= 0) {
            showAlert('请输入有效的金额', 'warning');
            return;
        }

        const transactionDTO = {
            type: type,
            amount: parseFloat(amount),
            description: description || '',
            category: '其他',
            date: new Date().toISOString().split('T')[0]
        };

        try {
            const response = await fetch('/api/transactions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(transactionDTO)
            });

            const result = await response.json();

            if (result.success) {
                showAlert('交易添加成功！', 'success');
                // 清空表单
                document.getElementById('quickAmount').value = '';
                document.getElementById('quickDescription').value = '';
                // 刷新页面显示新数据
                setTimeout(() => location.reload(), 1000);
            } else {
                showAlert(result.message || '添加失败', 'danger');
            }
        } catch (error) {
            showAlert('网络错误，请重试', 'danger');
        }
    }
</script>
</body>
</html>