/**
 * 预算管理前端JavaScript
 */

// 全局变量
let allBudgets = [];
let currentBudgetId = null;
let deleteBudgetId = null;

/**
 * 加载预算数据
 */
async function loadBudgets() {
    try {
        showLoading();

        const response = await fetch('/api/budgets/current', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error('加载预算数据失败');
        }

        const result = await response.json();

        if (result.success) {
            allBudgets = result.data || [];
            renderBudgets(allBudgets);
            updateBudgetSummary();
            hideLoading();
        } else {
            throw new Error(result.message || '加载失败');
        }
    } catch (error) {
        console.error('加载预算时出错:', error);
        hideLoading();
        showEmptyState();
        showError('加载预算数据失败: ' + error.message);
    }
}

/**
 * 渲染预算列表
 */
function renderBudgets(budgets) {
    const tbody = document.getElementById('budgetsBody');
    const emptyState = document.getElementById('emptyBudgets');
    const budgetsTable = document.getElementById('budgetsTable');

    if (!budgets || budgets.length === 0) {
        tbody.innerHTML = '';
        budgetsTable.style.display = 'none';
        emptyState.style.display = 'block';
        return;
    }

    emptyState.style.display = 'none';
    budgetsTable.style.display = 'block';

    tbody.innerHTML = budgets.map(budget => createBudgetRow(budget)).join('');
}

/**
 * 创建预算表格行
 */
function createBudgetRow(budget) {
    const usagePercentage = parseFloat(budget.usagePercentage || 0);
    const remaining = (budget.monthlyLimit || 0) - (budget.currentSpent || 0);

    // 确定状态和颜色
    let status = 'normal';
    let statusClass = 'status-normal';
    let usageClass = 'usage-normal';
    let rowClass = '';

    if (usagePercentage >= 100) {
        status = 'over_budget';
        statusClass = 'status-danger';
        usageClass = 'usage-danger';
        rowClass = 'budget-row-danger';
    } else if (usagePercentage >= 80) {
        status = 'near_limit';
        statusClass = 'status-warning';
        usageClass = 'usage-warning';
        rowClass = 'budget-row-alert';
    }

    // 格式化金额
    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('zh-CN', {
            style: 'currency',
            currency: 'CNY',
            minimumFractionDigits: 2
        }).format(amount || 0);
    };

    return `
        <tr class="${rowClass}" data-budget-id="${budget.id}" data-category="${budget.category}">
            <td>
                <strong>${budget.category || '未分类'}</strong>
                ${budget.month ? `<br><small class="text-muted">${formatMonth(budget.month)}</small>` : ''}
            </td>
            <td class="budget-amount">${formatCurrency(budget.monthlyLimit)}</td>
            <td class="budget-amount">${formatCurrency(budget.currentSpent)}</td>
            <td class="budget-amount ${remaining < 0 ? 'over-budget-amount' : 'remaining-amount'}">
                ${formatCurrency(remaining)}
            </td>
            <td>
                <div class="d-flex align-items-center">
                    <span class="${usageClass} me-2">${usagePercentage.toFixed(1)}%</span>
                    <div class="budget-progress flex-grow-1">
                        <div class="budget-progress-bar bg-${getProgressColor(usagePercentage)}" 
                             style="width: ${Math.min(usagePercentage, 100)}%"></div>
                    </div>
                </div>
            </td>
            <td>
                <span class="budget-status ${statusClass}">
                    ${getStatusText(status)}
                </span>
            </td>
            <td class="text-end">
                <button class="btn btn-budget-action btn-budget-edit" 
                        onclick="openEditBudgetModal(${budget.id})"
                        title="编辑预算">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-budget-action btn-budget-delete" 
                        onclick="openDeleteBudgetModal(${budget.id}, '${budget.category}')"
                        title="删除预算">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        </tr>
    `;
}

/**
 * 根据使用率获取进度条颜色
 */
function getProgressColor(percentage) {
    if (percentage >= 100) return 'danger';
    if (percentage >= 80) return 'warning';
    return 'success';
}

/**
 * 获取状态文本
 */
function getStatusText(status) {
    switch (status) {
        case 'over_budget': return '超支';
        case 'near_limit': return '接近限额';
        default: return '正常';
    }
}

/**
 * 更新预算概览
 */
function updateBudgetSummary() {
    if (!allBudgets || allBudgets.length === 0) {
        document.getElementById('totalBudgetLimit').textContent = '¥0.00';
        document.getElementById('totalSpent').textContent = '¥0.00';
        document.getElementById('overallUsage').textContent = '0%';
        document.getElementById('budgetSummary').textContent = '共 0 个预算';
        return;
    }

    const totalLimit = allBudgets.reduce((sum, budget) =>
        sum + (parseFloat(budget.monthlyLimit) || 0), 0);
    const totalSpent = allBudgets.reduce((sum, budget) =>
        sum + (parseFloat(budget.currentSpent) || 0), 0);
    const overallUsage = totalLimit > 0 ? (totalSpent / totalLimit * 100) : 0;

    document.getElementById('totalBudgetLimit').textContent =
        formatCurrency(totalLimit);
    document.getElementById('totalSpent').textContent =
        formatCurrency(totalSpent);
    document.getElementById('overallUsage').textContent =
        overallUsage.toFixed(1) + '%';
    document.getElementById('budgetSummary').textContent =
        `共 ${allBudgets.length} 个预算`;
}

/**
 * 筛选预算
 */
function filterBudgets(filterType) {
    let filteredBudgets = [];

    switch (filterType) {
        case 'active':
            filteredBudgets = allBudgets.filter(budget =>
                new Date(budget.month) >= new Date(new Date().getFullYear(), new Date().getMonth(), 1)
            );
            break;
        case 'alert':
            filteredBudgets = allBudgets.filter(budget =>
                parseFloat(budget.usagePercentage || 0) >= 80
            );
            break;
        default:
            filteredBudgets = allBudgets;
    }

    renderBudgets(filteredBudgets);
}

/**
 * 格式化月份
 */
function formatMonth(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.getFullYear() + '年' + (date.getMonth() + 1) + '月';
}

/**
 * 格式化金额
 */
function formatCurrency(amount) {
    return new Intl.NumberFormat('zh-CN', {
        style: 'currency',
        currency: 'CNY',
        minimumFractionDigits: 2
    }).format(amount || 0);
}

/**
 * 显示加载状态
 */
function showLoading() {
    const loading = document.getElementById('loadingBudgets');
    const empty = document.getElementById('emptyBudgets');
    const table = document.getElementById('budgetsTable');

    if (loading) loading.style.display = 'block';
    if (empty) empty.style.display = 'none';
    if (table) table.style.display = 'none';
}

/**
 * 隐藏加载状态
 */
function hideLoading() {
    const loading = document.getElementById('loadingBudgets');
    if (loading) loading.style.display = 'none';
}

/**
 * 显示空状态
 */
function showEmptyState() {
    const empty = document.getElementById('emptyBudgets');
    const table = document.getElementById('budgetsTable');

    if (empty) empty.style.display = 'block';
    if (table) table.style.display = 'none';
}

/**
 * 显示成功消息
 */
function showSuccess(message) {
    showToast(message, 'success');
}

/**
 * 显示错误消息
 */
function showError(message) {
    showToast(message, 'danger');
}

/**
 * 显示Toast消息
 */
function showToast(message, type = 'info') {
    // 移除现有的toast
    const existingToasts = document.querySelectorAll('.budget-alert-toast');
    existingToasts.forEach(toast => toast.remove());

    // 创建新的toast
    const toast = document.createElement('div');
    toast.className = `budget-alert-toast alert alert-${type} alert-dismissible fade show`;
    toast.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'} me-2"></i>
            <div class="flex-grow-1">${message}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;

    document.body.appendChild(toast);

    // 5秒后自动移除
    setTimeout(() => {
        if (toast.parentNode) {
            toast.remove();
        }
    }, 5000);
}

/**
 * 添加预算表单提交
 */
document.getElementById('addBudgetForm')?.addEventListener('submit', async function(e) {
    e.preventDefault();

    try {
        // 获取表单数据
        let category = document.getElementById('budgetCategory').value;
        if (category === 'custom') {
            category = document.getElementById('customCategory').value.trim();
        }

        const monthlyLimit = document.getElementById('monthlyLimit').value;
        const month = document.getElementById('budgetMonth').value;
        const notes = document.getElementById('budgetNotes').value;

        // 验证数据
        if (!category) {
            showError('请选择或输入分类');
            return;
        }

        if (!monthlyLimit || parseFloat(monthlyLimit) <= 0) {
            showError('月度预算限额必须大于0');
            return;
        }

        const budgetData = {
            category: category,
            monthlyLimit: parseFloat(monthlyLimit),
            month: month ? new Date(month + '-01').toISOString() : null,
            notes: notes || null
        };

        // 发送请求
        const response = await fetch('/api/budgets', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(budgetData)
        });

        const result = await response.json();

        if (result.success) {
            showSuccess('预算添加成功');

            // 关闭模态框
            const modal = bootstrap.Modal.getInstance(document.getElementById('addBudgetModal'));
            modal.hide();

            // 重置表单
            this.reset();
            document.getElementById('customCategory').style.display = 'none';

            // 重新加载预算数据
            setTimeout(() => {
                loadBudgets();
            }, 500);

        } else {
            throw new Error(result.message || '添加失败');
        }
    } catch (error) {
        console.error('添加预算时出错:', error);
        showError('添加预算失败: ' + error.message);
    }
});

/**
 * 打开编辑预算模态框
 */
async function openEditBudgetModal(budgetId) {
    try {
        currentBudgetId = budgetId;

        // 获取预算详情
        const response = await fetch(`/api/budgets/${budgetId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error('获取预算详情失败');
        }

        const result = await response.json();

        if (result.success) {
            const budget = result.data;

            // 填充表单
            const modalBody = document.querySelector('#editBudgetModal .modal-body');
            modalBody.innerHTML = createEditForm(budget);

            // 显示模态框
            const modal = new bootstrap.Modal(document.getElementById('editBudgetModal'));
            modal.show();

            // 设置表单提交事件
            document.getElementById('editBudgetForm').onsubmit = handleEditBudgetSubmit;
        } else {
            throw new Error(result.message || '获取详情失败');
        }
    } catch (error) {
        console.error('打开编辑模态框时出错:', error);
        showError('无法编辑预算: ' + error.message);
    }
}

/**
 * 创建编辑表单
 */
function createEditForm(budget) {
    const monthValue = budget.month ? new Date(budget.month).toISOString().split('T')[0].slice(0, 7) : '';

    return `
        <div class="mb-3">
            <label class="form-label">分类</label>
            <input type="text" class="form-control" value="${budget.category || ''}" readonly>
            <div class="form-text">分类不能修改，如需更改请删除后重新创建</div>
        </div>
        <div class="mb-3">
            <label for="editMonthlyLimit" class="form-label">月度预算限额 *</label>
            <div class="input-group">
                <span class="input-group-text">¥</span>
                <input type="number" class="form-control" id="editMonthlyLimit" 
                       value="${budget.monthlyLimit || 0}" step="0.01" min="0.01" required>
            </div>
        </div>
        <div class="mb-3">
            <label for="editMonth" class="form-label">预算月份</label>
            <input type="month" class="form-control" id="editMonth" value="${monthValue}">
        </div>
        <div class="mb-3">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" id="editResetSpent">
                <label class="form-check-label" for="editResetSpent">
                    重置已花费金额（从0开始重新计算）
                </label>
            </div>
        </div>
    `;
}

/**
 * 处理编辑预算提交
 */
async function handleEditBudgetSubmit(e) {
    e.preventDefault();

    try {
        const monthlyLimit = document.getElementById('editMonthlyLimit').value;
        const month = document.getElementById('editMonth').value;
        const resetSpent = document.getElementById('editResetSpent').checked;

        const updateData = {
            monthlyLimit: parseFloat(monthlyLimit),
            month: month ? new Date(month + '-01').toISOString() : null
        };

        if (resetSpent) {
            updateData.currentSpent = 0;
            updateData.usagePercentage = 0;
        }

        const response = await fetch(`/api/budgets/${currentBudgetId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(updateData)
        });

        const result = await response.json();

        if (result.success) {
            showSuccess('预算更新成功');

            // 关闭模态框
            const modal = bootstrap.Modal.getInstance(document.getElementById('editBudgetModal'));
            modal.hide();

            // 重新加载预算数据
            setTimeout(() => {
                loadBudgets();
            }, 500);

        } else {
            throw new Error(result.message || '更新失败');
        }
    } catch (error) {
        console.error('更新预算时出错:', error);
        showError('更新预算失败: ' + error.message);
    }
}

/**
 * 打开删除预算确认框
 */
function openDeleteBudgetModal(budgetId, category) {
    deleteBudgetId = budgetId;

    const deleteInfo = document.getElementById('deleteBudgetInfo');
    if (deleteInfo) {
        deleteInfo.innerHTML = `
            <div class="alert alert-warning">
                <strong>分类：</strong>${category}<br>
                <small class="text-muted">删除后，该预算的所有记录将无法恢复</small>
            </div>
        `;
    }

    const modal = new bootstrap.Modal(document.getElementById('deleteBudgetModal'));
    modal.show();
}

/**
 * 确认删除预算
 */
async function confirmDeleteBudget() {
    if (!deleteBudgetId) return;

    try {
        const response = await fetch(`/api/budgets/${deleteBudgetId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        const result = await response.json();

        if (result.success) {
            showSuccess('预算删除成功');

            // 关闭模态框
            const modal = bootstrap.Modal.getInstance(document.getElementById('deleteBudgetModal'));
            modal.hide();

            // 重新加载预算数据
            setTimeout(() => {
                loadBudgets();
            }, 500);

        } else {
            throw new Error(result.message || '删除失败');
        }
    } catch (error) {
        console.error('删除预算时出错:', error);
        showError('删除预算失败: ' + error.message);
    } finally {
        deleteBudgetId = null;
    }
}

/**
 * 初始化页面
 */
document.addEventListener('DOMContentLoaded', function() {
    // 加载预算数据
    loadBudgets();

    // 设置筛选器事件
    const viewType = document.getElementById('viewType');
    if (viewType) {
        viewType.addEventListener('change', function() {
            filterBudgets(this.value);
        });
    }

    // 设置分类选择事件
    const categorySelect = document.getElementById('budgetCategory');
    if (categorySelect) {
        categorySelect.addEventListener('change', function() {
            const customInput = document.getElementById('customCategory');
            if (customInput) {
                customInput.style.display = this.value === 'custom' ? 'block' : 'none';
                if (this.value !== 'custom') {
                    customInput.value = '';
                }
            }
        });
    }

    // 检查URL参数（用于从交易页面跳转）
    const urlParams = new URLSearchParams(window.location.search);
    const alertCategory = urlParams.get('alertCategory');
    if (alertCategory) {
        highlightBudgetCategory(alertCategory);
    }
});

/**
 * 高亮显示指定分类的预算
 */
function highlightBudgetCategory(category) {
    const rows = document.querySelectorAll('#budgetsBody tr');
    rows.forEach(row => {
        const rowCategory = row.getAttribute('data-category');
        if (rowCategory === category) {
            row.classList.add('table-warning');
            row.scrollIntoView({ behavior: 'smooth', block: 'center' });

            setTimeout(() => {
                row.classList.remove('table-warning');
            }, 5000);
        }
    });
}

/**
 * 实时预算检查（可选功能）
 */
async function checkBudgetAlerts() {
    try {
        const response = await fetch('/api/budgets/alerts', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const result = await response.json();
            if (result.success && result.data && result.data.length > 0) {
                result.data.forEach(alert => {
                    if (alert.alertLevel === 'OVER_BUDGET') {
                        showBudgetAlert(alert);
                    }
                });
            }
        }
    } catch (error) {
        console.error('检查预算预警时出错:', error);
    }
}

/**
 * 显示预算预警
 */
function showBudgetAlert(alert) {
    const alertMessage = `
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <div class="d-flex align-items-center">
                <i class="fas fa-exclamation-triangle fa-2x me-3"></i>
                <div>
                    <h5 class="alert-heading mb-1">预算超支警告！</h5>
                    <div class="mb-2">
                        <strong>${alert.category}</strong> 分类已超出预算限额。
                    </div>
                    <div class="small">
                        限额：${formatCurrency(alert.budgetLimit)} | 
                        已花费：${formatCurrency(alert.actualSpending)} | 
                        超出：${formatCurrency(alert.overAmount)}
                    </div>
                </div>
            </div>
        </div>
    `;

    // 显示在页面顶部
    const alertContainer = document.getElementById('budgetAlertContainer');
    if (!alertContainer) {
        const container = document.createElement('div');
        container.id = 'budgetAlertContainer';
        container.style.position = 'fixed';
        container.style.top = '80px';
        container.style.right = '20px';
        container.style.zIndex = '1050';
        container.style.width = '400px';
        container.style.maxWidth = '90%';
        document.body.appendChild(container);
    }

    const alertDiv = document.createElement('div');
    alertDiv.className = 'budget-alert-notification';
    alertDiv.innerHTML = alertMessage;

    document.getElementById('budgetAlertContainer').appendChild(alertDiv);

    // 10秒后自动移除
    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.remove();
        }
    }, 10000);
}

// 每60秒检查一次预算预警（可选）
// setInterval(checkBudgetAlerts, 60000);

// 页面可见时检查预算预警
document.addEventListener('visibilitychange', function() {
    if (!document.hidden) {
        checkBudgetAlerts();
    }
});