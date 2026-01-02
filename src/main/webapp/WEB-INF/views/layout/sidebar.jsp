<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="card mb-3">
    <div class="card-body">
        <h6 class="card-title mb-3">功能菜单</h6>
        <div class="list-group list-group-flush">
            <a href="/dashboard-page"
               class="list-group-item list-group-item-action ${requestScope.activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt me-2"></i>仪表板
            </a>
            <a href="/transactions"
               class="list-group-item list-group-item-action ${requestScope.activePage == 'transactions' ? 'active' : ''}">
                <i class="fas fa-exchange-alt me-2"></i>交易管理
            </a>
            <a href="/data-query"
               class="list-group-item list-group-item-action ${requestScope.activePage == 'data-query' ? 'active' : ''}">
                <i class="fas fa-search me-2"></i>数据查询
            </a>
            <a href="/budgets" class="list-group-item list-group-item-action">
                <i class="fas fa-wallet me-2"></i>预算管理
            </a>
            <a href="/reports" class="list-group-item list-group-item-action">
                <i class="fas fa-chart-bar me-2"></i>报表统计
            </a>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <h6 class="card-title mb-3">快速操作</h6>
        <div class="d-grid gap-2">
            <button class="btn btn-success btn-sm" onclick="quickAdd('income')">
                <i class="fas fa-plus-circle me-1"></i> 记收入
            </button>
            <button class="btn btn-danger btn-sm" onclick="quickAdd('expense')">
                <i class="fas fa-minus-circle me-1"></i> 记支出
            </button>
        </div>
    </div>
</div>

<script>
    function quickAdd(type) {
        alert('快速添加' + (type === 'income' ? '收入' : '支出') + '功能开发中...');
    }
    <!-- 在现有菜单项后添加 -->
    <li class="nav-item">
        <a class="nav-link ${activePage == 'transactions' ? 'active' : ''}" href="/transactions">
            <i class="fas fa-exchange-alt me-2"></i>
            交易管理
        </a>
    </li>
</script>