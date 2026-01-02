<%-- transaction_list.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>交易管理 - 个人经济管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-datepicker@1.9.0/dist/css/bootstrap-datepicker.min.css" rel="stylesheet">
    <style>
        .transaction-table tbody tr { cursor: pointer; }
        .transaction-table tbody tr:hover { background-color: rgba(0, 0, 0, 0.03); }
        .amount-income { color: #28a745; font-weight: 600; }
        .amount-expense { color: #dc3545; font-weight: 600; }
        .badge-income { background-color: #28a745; }
        .badge-expense { background-color: #dc3545; }
        .filter-card { background-color: #f8f9fa; border-left: 4px solid #0d6efd; }
    </style>
</head>
<body>
<!-- 复用 dashboard 的导航栏和侧边栏结构 -->
<jsp:include page="layout/navbar.jsp" />
<jsp:include page="layout/sidebar.jsp" />

<main class="main-content container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0"><i class="bi bi-arrow-left-right me-2"></i>交易管理</h4>
        <button class="btn btn-primary" onclick="window.location.href='/transactions/new'">
            <i class="bi bi-plus-circle me-1"></i> 新增交易
        </button>
    </div>

    <!-- 筛选卡片 -->
    <div class="card filter-card mb-4">
        <div class="card-body">
            <form id="filterForm" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">交易类型</label>
                    <select class="form-select" name="type">
                        <option value="">全部</option>
                        <option value="INCOME">收入</option>
                        <option value="EXPENSE">支出</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">分类</label>
                    <select class="form-select" name="category">
                        <option value="">全部</option>
                        <option value="餐饮">餐饮</option>
                        <option value="交通">交通</option>
                        <option value="工资">工资</option>
                        <!-- 更多分类从后端动态加载 -->
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">开始日期</label>
                    <input type="text" class="form-control datepicker" name="startDate">
                </div>
                <div class="col-md-3">
                    <label class="form-label">结束日期</label>
                    <input type="text" class="form-control datepicker" name="endDate">
                </div>
                <div class="col-12 text-end">
                    <button type="button" class="btn btn-outline-secondary me-2" onclick="resetFilters()">重置</button>
                    <button type="submit" class="btn btn-primary">筛选</button>
                </div>
            </form>
        </div>
    </div>

    <!-- 交易表格 -->
    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover transaction-table">
                    <thead>
                    <tr>
                        <th>日期</th>
                        <th>分类</th>
                        <th>类型</th>
                        <th>金额</th>
                        <th>备注</th>
                        <th class="text-end">操作</th>
                    </tr>
                    </thead>
                    <tbody id="transactionsTableBody">
                    <!-- 数据通过JavaScript动态加载 -->
                    <tr>
                        <td colspan="6" class="text-center py-5">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">加载中...</span>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <!-- 分页 -->
            <nav>
                <ul class="pagination justify-content-center" id="pagination">
                    <!-- 分页通过JavaScript动态生成 -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- 汇总信息 -->
    <div class="row mt-4">
        <div class="col-md-4">
            <div class="card bg-light">
                <div class="card-body text-center">
                    <h6 class="text-muted">总收入</h6>
                    <h4 id="totalIncome" class="text-success">¥ 0.00</h4>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-light">
                <div class="card-body text-center">
                    <h6 class="text-muted">总支出</h6>
                    <h4 id="totalExpense" class="text-danger">¥ 0.00</h4>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-light">
                <div class="card-body text-center">
                    <h6 class="text-muted">净余额</h6>
                    <h4 id="netBalance" class="text-primary">¥ 0.00</h4>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- 删除确认模态框 -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">确认删除</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>确定要删除这条交易记录吗？此操作不可撤销。</p>
                <input type="hidden" id="transactionToDelete">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" onclick="confirmDelete()">删除</button>
            </div>
        </div>
    </div>
    </deleteModal>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap-datepicker@1.9.0/dist/js/bootstrap-datepicker.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap-datepicker@1.9.0/dist/locales/bootstrap-datepicker.zh-CN.min.js"></script>
    <script>
        // 全局变量
        let currentPage = 1;
        let totalPages = 1;
        let filters = {};

        // 页面加载
        document.addEventListener('DOMContentLoaded', function() {
            initDatePickers();
            loadTransactions();
            setupEventListeners();
        });

        // 初始化日期选择器
        function initDatePickers() {
            $('.datepicker').datepicker({
                format: 'yyyy-mm-dd',
                language: 'zh-CN',
                autoclose: true
            });
        }

        // 加载交易数据
        async function loadTransactions(page = 1) {
            try {
                currentPage = page;

                // 构建查询参数
                const params = new URLSearchParams(filters);
                params.append('page', page);
                params.append('size', 10);

                const res = await fetch(`/api/transactions?${params}`);
                if (!res.ok) throw new Error('加载失败');

                const data = await res.json();
                renderTransactions(data.content || []);
                renderPagination(data.totalPages || 1);
                updateSummary(data.summary || {});

            } catch (error) {
                console.error('加载交易失败:', error);
                document.getElementById('transactionsTableBody').innerHTML = `
                    <tr>
                        <td colspan="6" class="text-center py-5 text-danger">
                            <i class="bi bi-exclamation-triangle me-2"></i>加载失败，请刷新重试
                        </td>
                    </tr>`;
            }
        }

        // 渲染交易表格
        function renderTransactions(transactions) {
            const tbody = document.getElementById('transactionsTableBody');

            if (transactions.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" class="text-center py-5 text-muted">
                            <i class="bi bi-receipt me-2"></i>暂无交易记录
                        </td>
                    </tr>`;
                return;
            }

            let html = '';
            transactions.forEach(t => {
                const isIncome = t.type === 'INCOME';
                const amountClass = isIncome ? 'amount-income' : 'amount-expense';
                const badgeClass = isIncome ? 'badge-income' : 'badge-expense';
                const amountSign = isIncome ? '+' : '-';

                html += `
                <tr onclick="viewTransaction(${t.id})" style="cursor: pointer;">
                    <td>${formatDate(t.date)}</td>
                    <td>${t.category || '未分类'}</td>
                    <td>
                        <span class="badge ${badgeClass}">${t.type}</span>
                    </td>
                    <td class="${amountClass}">
                        ${amountSign}¥${formatCurrency(t.amount)}
                    </td>
                    <td>${t.description || '-'}</td>
                    <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary me-1" onclick="editTransaction(event, ${t.id})">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="deleteTransaction(event, ${t.id})">
                            <i class="bi bi-trash"></i>
                        </button>
                    </td>
                </tr>`;
            });

            tbody.innerHTML = html;
        }

        // 渲染分页
        function renderPagination(total) {
            totalPages = total;
            const pagination = document.getElementById('pagination');

            if (totalPages <= 1) {
                pagination.innerHTML = '';
                return;
            }

            let html = '';

            // 上一页
            html += `
            <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                <a class="page-link" onclick="loadTransactions(${currentPage - 1})">上一页</a>
            </li>`;

            // 页码
            for (let i = 1; i <= totalPages; i++) {
                if (i === currentPage) {
                    html += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
                } else {
                    html += `<li class="page-item"><a class="page-link" onclick="loadTransactions(${i})">${i}</a></li>`;
                }
            }

            // 下一页
            html += `
            <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                <a class="page-link" onclick="loadTransactions(${currentPage + 1})">下一页</a>
            </li>`;

            pagination.innerHTML = html;
        }

        // 更新汇总信息
        function updateSummary(summary) {
            document.getElementById('totalIncome').textContent = `¥ ${formatCurrency(summary.totalIncome || 0)}`;
            document.getElementById('totalExpense').textContent = `¥ ${formatCurrency(summary.totalExpense || 0)}`;
            document.getElementById('netBalance').textContent = `¥ ${formatCurrency(summary.netBalance || 0)}`;
        }

        // 查看交易详情
        function viewTransaction(id) {
            window.location.href = `/transactions/${id}`;
        }

        // 编辑交易
        function editTransaction(event, id) {
            event.stopPropagation();
            window.location.href = `/transactions/${id}/edit`;
        }

        // 删除交易
        function deleteTransaction(event, id) {
            event.stopPropagation();
            document.getElementById('transactionToDelete').value = id;
            const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
            modal.show();
        }

        // 确认删除
        async function confirmDelete() {
            const id = document.getElementById('transactionToDelete').value;

            try {
                const res = await fetch(`/api/transactions/${id}`, {
                    method: 'DELETE'
                });

                if (res.ok) {
                    const modal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
                    modal.hide();
                    showToast('删除成功', 'success');
                    loadTransactions(currentPage);
                } else {
                    showToast('删除失败', 'danger');
                }
            } catch (error) {
                showToast('网络错误', 'danger');
            }
        }

        // 筛选表单提交
        function setupEventListeners() {
            document.getElementById('filterForm').addEventListener('submit', function(e) {
                e.preventDefault();
                const formData = new FormData(this);
                filters = {};
                formData.forEach((value, key) => {
                    if (value) filters[key] = value;
                });
                loadTransactions(1);
            });
        }

        // 重置筛选
        function resetFilters() {
            document.getElementById('filterForm').reset();
            filters = {};
            loadTransactions(1);
        }

        // 工具函数
        function formatCurrency(amount) {
            return parseFloat(amount).toFixed(2);
        }

        function formatDate(dateStr) {
            return dateStr.split('-').slice(1).join('-'); // 显示月-日
        }

        function showToast(message, type) {
            alert(message); // 实际项目中使用toast组件
        }
    </script>
</body>
</html>