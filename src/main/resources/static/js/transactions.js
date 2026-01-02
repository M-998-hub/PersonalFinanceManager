// transactions.js - 交易管理JavaScript

// 全局变量（在文件顶部定义）
let apiBase = '/api/transactions';
let csrfToken = '';
let csrfHeaderName = '';
let requestHeaders = {
    'Content-Type': 'application/json'
};

// 初始化函数（需要在页面加载后调用）
function initTransactions() {
    console.log("=== 交易管理初始化 ===");

    // 初始化CSRF令牌（如果有）
    if (typeof csrfTokenElement !== 'undefined') {
        csrfToken = csrfTokenElement.dataset.token || '';
        csrfHeaderName = csrfTokenElement.dataset.headerName || '';

        if (csrfToken && csrfHeaderName) {
            requestHeaders[csrfHeaderName] = csrfToken;
        }
    }

    // 设置默认日期
    setDefaultDate();

    // 设置表单提交事件
    setupFormSubmit();

    // 检查URL参数
    checkUrlParams();
}

// 设置默认日期
function setDefaultDate() {
    const dateInput = document.getElementById('date');
    if (dateInput && !dateInput.value) {
        const today = new Date().toISOString().split('T')[0];
        dateInput.value = today;
    }
}

// 检查URL参数
function checkUrlParams() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('success')) {
        showAlert('操作成功！', 'success');
    }
}

// 表单验证
function validateTransactionForm(formId = 'addTransactionForm') {
    const form = document.getElementById(formId);
    if (!form) return false;

    const amount = form.querySelector('[name="amount"]')?.value;
    const category = form.querySelector('[name="category"]')?.value;
    const date = form.querySelector('[name="date"]')?.value;

    if (!amount || parseFloat(amount) <= 0) {
        showAlert('请输入有效的金额', 'warning');
        return false;
    }

    if (!category) {
        showAlert('请选择分类', 'warning');
        return false;
    }

    if (!date) {
        showAlert('请选择日期', 'warning');
        return false;
    }

    return true;
}

// 显示提示消息
function showAlert(message, type = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas ${getAlertIcon(type)} me-2"></i>
            <div class="flex-grow-1">${message}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;

    const formMessage = document.getElementById('formMessage');
    if (formMessage) {
        formMessage.innerHTML = '';
        formMessage.appendChild(alertDiv);
        formMessage.style.display = 'block';
    }

    // 5秒后自动消失
    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.parentNode.style.display = 'none';
        }
    }, 5000);
}

// 获取警告图标
function getAlertIcon(type) {
    switch (type) {
        case 'success': return 'fa-check-circle';
        case 'warning': return 'fa-exclamation-triangle';
        case 'danger': return 'fa-times-circle';
        default: return 'fa-info-circle';
    }
}

// 设置表单提交事件
function setupFormSubmit() {
    const form = document.getElementById('addTransactionForm');
    if (!form) return;

    form.addEventListener('submit', async function(e) {
        e.preventDefault();

        if (!validateTransactionForm('addTransactionForm')) {
            return;
        }

        const submitBtn = this.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;

        // 显示加载状态
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>添加中...';
        submitBtn.disabled = true;

        try {
            const formData = new FormData(this);
            const jsonData = {};

            formData.forEach((value, key) => {
                jsonData[key] = value;
            });

            // 转换金额为数字
            if (jsonData.amount) {
                jsonData.amount = parseFloat(jsonData.amount);
            }

            console.log('提交的交易数据:', jsonData);

            // 发送AJAX请求
            const response = await fetch(apiBase, {
                method: 'POST',
                headers: requestHeaders,
                credentials: 'include',
                body: JSON.stringify(jsonData)
            });

            const result = await response.json();

            // 恢复按钮状态
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;

            if (result.success) {
                showAlert('交易添加成功！', 'success');
                this.reset();

                // 重置日期为今天
                const dateInput = this.querySelector('[name="date"]');
                if (dateInput) {
                    dateInput.value = new Date().toISOString().split('T')[0];
                }

                // 刷新页面
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                showAlert('添加失败: ' + result.message, 'danger');
            }
        } catch (error) {
            console.error('添加交易错误:', error);
            showAlert('网络错误，请重试: ' + error.message, 'danger');

            // 恢复按钮状态
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
        }
    });
}

// 编辑交易
function editTransaction(id) {
    console.log('编辑交易ID:', id);

    // 显示加载状态
    const editBtn = event.target.closest('.btn-action');
    const originalHtml = editBtn.innerHTML;
    editBtn.innerHTML = '<i class="fas fa-spinner fa-spin fa-sm"></i>';
    editBtn.disabled = true;

    const requestUrl = `${apiBase}/${id}`;
    console.log('请求URL:', requestUrl);

    fetch(requestUrl, {
        method: 'GET',
        credentials: 'same-origin',
        headers: {
            'Accept': 'application/json'
        }
    })
        .then(response => {
            // 恢复按钮状态
            editBtn.innerHTML = originalHtml;
            editBtn.disabled = false;

            if (!response.ok) {
                throw new Error(`HTTP错误: ${response.status}`);
            }
            return response.json();
        })
        .then(transactionData => {
            console.log('成功获取数据:', transactionData);

            // 填充编辑表单
            fillEditForm(transactionData);

            // 显示编辑模态框
            const modal = new bootstrap.Modal(document.getElementById('editTransactionModal'));
            modal.show();
        })
        .catch(error => {
            console.error('请求失败:', error);
            showAlert('请求失败: ' + error.message, 'danger');

            // 恢复按钮状态
            editBtn.innerHTML = originalHtml;
            editBtn.disabled = false;
        });
}

// 填充编辑表单
function fillEditForm(transaction) {
    if (!transaction) return;

    // 设置交易ID
    document.getElementById('editTransactionId').value = transaction.id;

    // 设置金额
    document.getElementById('editAmount').value = transaction.amount;

    // 设置交易类型
    const typeRadio = transaction.type === 'INCOME'
        ? document.getElementById('editTypeIncome')
        : document.getElementById('editTypeExpense');
    if (typeRadio) typeRadio.checked = true;

    // 设置分类
    const categorySelect = document.getElementById('editCategory');
    if (categorySelect) {
        // 清空现有选项
        categorySelect.innerHTML = '<option value="">请选择分类</option>';

        // 根据类型获取分类列表
        const categories = transaction.type === 'INCOME'
            ? ['工资', '奖金', '投资', '其他收入']
            : ['餐饮', '交通', '购物', '娱乐', '房租', '水电费', '其他支出'];

        // 添加选项
        categories.forEach(category => {
            const option = document.createElement('option');
            option.value = category;
            option.textContent = category;
            if (category === transaction.category) {
                option.selected = true;
            }
            categorySelect.appendChild(option);
        });
    }

    // 设置日期
    const dateInput = document.getElementById('editDate');
    if (dateInput && transaction.date) {
        const date = new Date(transaction.date);
        const formattedDate = date.toISOString().split('T')[0];
        dateInput.value = formattedDate;
    }

    // 设置描述
    const descriptionInput = document.getElementById('editDescription');
    if (descriptionInput) {
        descriptionInput.value = transaction.description || '';
    }
}

// 更新交易
function updateTransaction() {
    const transactionId = document.getElementById('editTransactionId').value;
    if (!transactionId) {
        showAlert('交易ID不存在', 'warning');
        return;
    }

    // 验证表单
    if (!validateTransactionForm('editTransactionForm')) {
        return;
    }

    // 获取表单数据
    const typeRadio = document.querySelector('input[name="editType"]:checked');
    if (!typeRadio) {
        showAlert('请选择交易类型', 'warning');
        return;
    }

    const formData = {
        type: typeRadio.value,
        amount: parseFloat(document.getElementById('editAmount').value),
        category: document.getElementById('editCategory').value,
        date: document.getElementById('editDate').value,
        description: document.getElementById('editDescription').value.trim() || null
    };

    console.log('更新交易数据:', formData);

    // 显示加载状态
    const saveBtn = document.querySelector('#editTransactionModal .btn-primary');
    const originalText = saveBtn.textContent;
    saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>保存中...';
    saveBtn.disabled = true;

    // 发送PUT请求
    const apiUrl = `${apiBase}/${transactionId}`;
    console.log('更新URL:', apiUrl);

    fetch(apiUrl, {
        method: 'PUT',
        headers: requestHeaders,
        credentials: 'include',
        body: JSON.stringify(formData)
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP错误: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('更新响应:', data);

            // 恢复按钮状态
            saveBtn.textContent = originalText;
            saveBtn.disabled = false;

            if (data.success) {
                showAlert('交易更新成功！', 'success');

                // 关闭模态框
                const modal = bootstrap.Modal.getInstance(document.getElementById('editTransactionModal'));
                if (modal) modal.hide();

                // 刷新页面
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                throw new Error(data.message || '更新交易失败');
            }
        })
        .catch(error => {
            console.error('更新交易失败:', error);
            showAlert('更新交易失败: ' + error.message, 'danger');

            // 恢复按钮状态
            saveBtn.textContent = originalText;
            saveBtn.disabled = false;
        });
}

// 删除交易
function deleteTransaction(id) {
    console.log('删除交易ID:', id);

    if (!confirm(`确定要删除交易吗？`)) {
        return;
    }

    const apiUrl = `${apiBase}/${id}`;
    console.log('API地址:', apiUrl);

    // 显示加载状态
    const deleteBtn = event.target.closest('.btn-action');
    const originalHtml = deleteBtn.innerHTML;
    deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin fa-sm"></i>';
    deleteBtn.disabled = true;

    // 发送DELETE请求
    fetch(apiUrl, {
        method: 'DELETE',
        credentials: 'include',
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP错误: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('删除响应:', data);

            // 恢复按钮状态
            deleteBtn.innerHTML = originalHtml;
            deleteBtn.disabled = false;

            if (data.success) {
                showAlert('交易删除成功！', 'success');

                // 刷新页面
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                throw new Error(data.message || '删除交易失败');
            }
        })
        .catch(error => {
            console.error('删除交易失败:', error);
            showAlert('删除交易失败: ' + error.message, 'danger');

            // 恢复按钮状态
            deleteBtn.innerHTML = originalHtml;
            deleteBtn.disabled = false;
        });
}

// 刷新交易列表
function refreshTransactions() {
    window.location.reload();
}

// 页面加载完成后的初始化
document.addEventListener('DOMContentLoaded', function() {
    initTransactions();
});

// 导出函数（如果需要从其他文件调用）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        editTransaction,
        deleteTransaction,
        updateTransaction,
        showAlert
    };
}