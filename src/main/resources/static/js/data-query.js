// /resources/static/js/data-query.js

// 页面初始化
document.addEventListener('DOMContentLoaded', function() {
    console.log('数据查询页面加载完成');

    // 如果Controller中没有设置日期值，在这里设置默认值
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');

    if (startDateInput && !startDateInput.value) {
        // 设置为本月第一天
        const today = new Date();
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        startDateInput.value = formatDateForInput(firstDay);
    }

    if (endDateInput && !endDateInput.value) {
        // 设置为今天
        const today = new Date();
        endDateInput.value = formatDateForInput(today);
    }

    // 加载分类列表
    loadCategories();

    // 执行查询
    executeQuery();

    // 设置分页大小改变事件
    document.getElementById('pageSize').addEventListener('change', function() {
        executeQuery(0);
    });
});

// 格式化日期为YYYY-MM-DD格式（用于input[type=date]）
function formatDateForInput(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// 加载分类列表
async function loadCategories() {
    try {
        console.log('开始加载分类列表...');
        const response = await fetch('/api/data-query/categories');
        console.log('分类API响应状态:', response.status);

        if (response.ok) {
            const categories = await response.json();
            console.log('分类列表:', categories);

            const categorySelect = document.getElementById('category');

            // 添加已有选项
            const currentCategory = document.getElementById('category').value;
            console.log('当前选中的分类:', currentCategory);

            categories.forEach(category => {
                const option = document.createElement('option');
                option.value = category;
                option.textContent = category;
                if (category === currentCategory) {
                    option.selected = true;
                }
                categorySelect.appendChild(option);
            });
        } else {
            console.error('分类API响应失败:', response.status);
        }
    } catch (error) {
        console.error('加载分类列表失败:', error);
    }
}

// 重置表单
function resetForm() {
    console.log('重置表单');
    document.getElementById('queryForm').reset();

    // 设置默认日期
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);

    document.getElementById('startDate').value = formatDateForInput(firstDay);
    document.getElementById('endDate').value = formatDateForInput(today);

    // 触发查询
    executeQuery(0);
}

// 执行查询
async function executeQuery(page = 0) {
    console.log('执行查询，页码:', page);

    const loadingEl = document.getElementById('loadingResults');
    const emptyEl = document.getElementById('emptyResults');
    const tableEl = document.getElementById('resultsTable');

    // 显示加载状态
    if (loadingEl) loadingEl.style.display = 'block';
    if (emptyEl) emptyEl.style.display = 'none';
    if (tableEl) tableEl.style.display = 'none';

    try {
        // 构建查询参数
        const params = new URLSearchParams();
        params.append('page', page);
        params.append('size', document.getElementById('pageSize').value);

        const form = document.getElementById('queryForm');
        const formData = new FormData(form);
        formData.forEach((value, key) => {
            if (value) params.append(key, value);
        });

        console.log('查询参数:', params.toString());

        // 发送查询请求
        const apiUrl = `/api/data-query/transactions?${params}`;
        console.log('API URL:', apiUrl);

        const response = await fetch(apiUrl);
        console.log('查询响应状态:', response.status);

        const data = await response.json();
        console.log('查询响应数据:', data);

        if (data.success) {
            // 更新统计信息
            updateStats(data.stats);

            // 更新结果表格
            updateResults(data);

            // 更新结果摘要
            document.getElementById('resultSummary').textContent =
                `共 ${data.totalElements} 条记录，第 ${page + 1} / ${data.totalPages} 页`;
        } else {
            throw new Error(data.message || '查询失败');
        }
    } catch (error) {
        console.error('查询失败:', error);
        showAlert('查询失败: ' + error.message, 'danger');
        if (emptyEl) emptyEl.style.display = 'block';
    } finally {
        if (loadingEl) loadingEl.style.display = 'none';
    }
}

// 更新统计信息
function updateStats(stats) {
    console.log('更新统计信息:', stats);

    const totalCountEl = document.getElementById('totalCount');
    const totalIncomeEl = document.getElementById('totalIncome');
    const totalExpenseEl = document.getElementById('totalExpense');
    const netBalanceEl = document.getElementById('netBalance');

    if (totalCountEl) totalCountEl.textContent = stats.totalCount || 0;
    if (totalIncomeEl) totalIncomeEl.textContent = formatCurrency(stats.totalIncome || 0);
    if (totalExpenseEl) totalExpenseEl.textContent = formatCurrency(stats.totalExpense || 0);
    if (netBalanceEl) netBalanceEl.textContent = formatCurrency(stats.netBalance || 0);
}

// 更新结果表格
function updateResults(data) {
    console.log('更新结果表格，数据量:', data.data ? data.data.length : 0);

    const tbody = document.getElementById('resultsBody');
    const emptyEl = document.getElementById('emptyResults');
    const tableEl = document.getElementById('resultsTable');

    if (!data.data || data.data.length === 0) {
        if (emptyEl) emptyEl.style.display = 'block';
        if (tableEl) tableEl.style.display = 'none';
        return;
    }

    if (emptyEl) emptyEl.style.display = 'none';
    if (tableEl) tableEl.style.display = 'block';

    // 渲染结果行
    let html = '';
    data.data.forEach(transaction => {
        const isIncome = transaction.type === 'INCOME';
        const typeClass = isIncome ? 'badge-income' : 'badge-expense';
        const amountClass = isIncome ? 'amount-income' : 'amount-expense';
        const typeText = isIncome ? '收入' : '支出';
        const amountPrefix = isIncome ? '+' : '-';

        html += `
            <tr>
                <td>${formatDisplayDate(transaction.date)}</td>
                <td>
                    <span class="transaction-badge ${typeClass}">
                        ${typeText}
                    </span>
                </td>
                <td>${transaction.category}</td>
                <td>${transaction.description || '无描述'}</td>
                <td class="text-end ${amountClass} fw-bold">
                    ${amountPrefix}${formatCurrency(transaction.amount)}
                </td>
            </tr>
        `;
    });

    if (tbody) tbody.innerHTML = html;

    // 渲染分页
    renderPagination(data.currentPage, data.totalPages);
}

// 渲染分页
function renderPagination(currentPage, totalPages) {
    console.log('渲染分页，当前页:', currentPage, '总页数:', totalPages);

    const pagination = document.getElementById('pagination');

    if (totalPages <= 1) {
        if (pagination) pagination.innerHTML = '';
        return;
    }

    let html = '<ul class="pagination mb-0">';

    // 上一页
    if (currentPage > 0) {
        html += `
            <li class="page-item">
                <a class="page-link" href="#" onclick="executeQuery(${currentPage - 1}); return false;">
                    <i class="fas fa-chevron-left"></i>
                </a>
            </li>
        `;
    } else {
        html += '<li class="page-item disabled"><span class="page-link"><i class="fas fa-chevron-left"></i></span></li>';
    }

    // 页码
    const startPage = Math.max(0, currentPage - 2);
    const endPage = Math.min(totalPages - 1, currentPage + 2);

    for (let i = startPage; i <= endPage; i++) {
        if (i === currentPage) {
            html += `<li class="page-item active"><span class="page-link">${i + 1}</span></li>`;
        } else {
            html += `
                <li class="page-item">
                    <a class="page-link" href="#" onclick="executeQuery(${i}); return false;">
                        ${i + 1}
                    </a>
                </li>
            `;
        }
    }

    // 下一页
    if (currentPage < totalPages - 1) {
        html += `
            <li class="page-item">
                <a class="page-link" href="#" onclick="executeQuery(${currentPage + 1}); return false;">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </li>
        `;
    } else {
        html += '<li class="page-item disabled"><span class="page-link"><i class="fas fa-chevron-right"></i></span></li>';
    }

    html += '</ul>';
    if (pagination) pagination.innerHTML = html;
}

// 导出CSV
async function exportToCsv() {
    try {
        console.log('开始导出CSV');

        // 构建查询参数
        const params = new URLSearchParams();
        const form = document.getElementById('queryForm');
        const formData = new FormData(form);
        formData.forEach((value, key) => {
            if (value) params.append(key, value);
        });

        console.log('导出参数:', params.toString());

        // 发送导出请求
        const apiUrl = `/api/data-query/export/csv?${params}`;
        console.log('导出API URL:', apiUrl);

        const response = await fetch(apiUrl);
        console.log('导出响应状态:', response.status);

        if (response.ok) {
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;

            // 生成文件名
            const today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0');
            const day = String(today.getDate()).padStart(2, '0');
            a.download = `transactions_${year}-${month}-${day}.csv`;

            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);

            showAlert('导出成功！', 'success');
        } else {
            throw new Error('导出失败，状态码: ' + response.status);
        }
    } catch (error) {
        console.error('导出失败:', error);
        showAlert('导出失败: ' + error.message, 'danger');
    }
}

// 工具函数
function formatCurrency(amount) {
    const num = parseFloat(amount);
    if (isNaN(num)) return '¥0.00';
    return '¥' + num.toFixed(2);
}

function formatDisplayDate(dateString) {
    try {
        const date = new Date(dateString);
        if (isNaN(date.getTime())) {
            return dateString;
        }
        return date.toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        });
    } catch (error) {
        return dateString;
    }
}

function showAlert(message, type) {
    console.log('显示提示:', message, type);

    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.cssText = `
        top: 20px;
        right: 20px;
        z-index: 9999;
        min-width: 300px;
    `;

    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(alertDiv);

    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.remove();
        }
    }, 5000);
}