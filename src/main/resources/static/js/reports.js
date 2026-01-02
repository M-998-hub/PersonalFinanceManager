/**
 * 报表统计JavaScript
 */

// 全局变量
let currentReportType = 'monthly';
let currentMonth = new Date().getMonth() + 1;
let currentYear = new Date().getFullYear();
let monthlyChart = null;
let trendChart = null;
let pieChart = null;
let barChart = null;

/**
 * 加载快速统计数据
 */
async function loadQuickStats() {
    try {
        showLoading('#monthlyReport');

        const response = await fetch('/api/reports/quick-balance', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include'
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();

        if (result.success) {
            const data = result.data;

            // 更新统计卡片
            updateElementText('totalIncome', formatCurrency(data.totalIncome || 0));
            updateElementText('totalExpense', formatCurrency(data.totalExpense || 0));
            updateElementText('totalBalance', formatCurrency(data.netIncome || 0));
            updateElementText('monthlyNet', formatCurrency(data.monthlyNet || 0));

            // 加载月度报告 - 使用当前日期
            const today = new Date();
            currentYear = today.getFullYear();
            currentMonth = today.getMonth() + 1;
            loadMonthlyReport(currentYear, currentMonth);

        } else {
            throw new Error(result.message || '加载失败');
        }
    } catch (error) {
        console.error('加载快速统计失败:', error);
        showError('加载统计数据失败: ' + error.message);
    }
}

/**
 * 加载月度收支报告
 */
async function loadMonthlyReport(year, month) {
    try {
        showLoading('#monthlyReport');

        const response = await fetch(`/api/reports/monthly?year=${year}&month=${month}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include'
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();

        if (result.success) {
            const data = result.data;

            // 更新月度统计
            updateElementText('monthlyIncome', formatCurrency(data.totalIncome || 0));
            updateElementText('monthlyExpense', formatCurrency(data.totalExpense || 0));
            updateElementText('monthlyBalance', formatCurrency(data.netIncome || 0));
            updateElementText('transactionCount', data.transactionCount || 0);

            // 更新标题
            updateElementText('monthlyReportTitle', `${year}年${month}月`);

            // 更新分类排名
            updateCategoryRanking('#incomeCategories', data.topIncomeCategories || [], '收入');
            updateCategoryRanking('#expenseCategories', data.topExpenseCategories || [], '支出');

            // 加载月度趋势图（最近6个月）
            loadRecentMonthsTrend(year, month);

        } else {
            throw new Error(result.message || '加载失败');
        }
    } catch (error) {
        console.error('加载月度报告失败:', error);
        showError('加载月度报告失败: ' + error.message);
        hideLoading('#monthlyReport');
    }
}

/**
 * 加载最近N个月的趋势
 */
async function loadRecentMonthsTrend(year, month) {
    try {
        const response = await fetch(`/api/reports/trend/recent?months=6`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include'
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();

        if (result.success) {
            const trendData = result.data;
            renderMonthlyTrendChart(trendData);
            hideLoading('#monthlyReport');
        } else {
            throw new Error(result.message || '加载失败');
        }
    } catch (error) {
        console.error('加载月度趋势失败:', error);
        hideLoading('#monthlyReport');
    }
}

/**
 * 加载年度趋势报告
 */
async function loadTrendReport() {
    const year = document.getElementById('trendYear').value;

    try {
        showLoading('#trendReport');

        const response = await fetch(`/api/reports/trend/yearly?year=${year}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include'
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();

        if (result.success) {
            const trendData = result.data;
            renderYearlyTrendChart(trendData, year);
            updateYearlyStatistics(trendData);
            hideLoading('#trendReport');
        } else {
            throw new Error(result.message || '加载失败');
        }
    } catch (error) {
        console.error('加载年度趋势报告失败:', error);
        showError('加载年度趋势报告失败: ' + error.message);
        hideLoading('#trendReport');
    }
}

/**
 * 加载类别占比分析
 */
async function loadCategoryAnalysis() {
    const period = document.getElementById('categoryPeriod').value;
    let startDate, endDate;

    const today = new Date();
    endDate = formatDate(today, 'yyyy-MM-dd');

    switch (period) {
        case 'month':
            startDate = formatDate(new Date(today.getFullYear(), today.getMonth(), 1), 'yyyy-MM-dd');
            break;
        case 'quarter':
            const quarter = Math.floor(today.getMonth() / 3);
            startDate = formatDate(new Date(today.getFullYear(), quarter * 3, 1), 'yyyy-MM-dd');
            break;
        case 'year':
            startDate = formatDate(new Date(today.getFullYear(), 0, 1), 'yyyy-MM-dd');
            break;
        default:
            startDate = formatDate(new Date(today.getFullYear(), today.getMonth(), 1), 'yyyy-MM-dd');
    }

    try {
        showLoading('#categoryReport');

        const response = await fetch(
            `/api/reports/category-analysis?startDate=${startDate}&endDate=${endDate}`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include'
            });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();

        if (result.success) {
            const categoryData = result.data;
            renderCategoryCharts(categoryData);
            updateCategoryTable(categoryData);
            hideLoading('#categoryReport');
        } else {
            throw new Error(result.message || '加载失败');
        }
    } catch (error) {
        console.error('加载类别分析失败:', error);
        showError('加载类别分析失败: ' + error.message);
        hideLoading('#categoryReport');
    }
}

/**
 * 渲染月度趋势图表
 */
function renderMonthlyTrendChart(trendData) {
    const ctx = document.getElementById('monthlyTrendChart').getContext('2d');

    // 销毁之前的图表
    if (monthlyChart) {
        monthlyChart.destroy();
    }

    monthlyChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: trendData.labels || [],
            datasets: [
                {
                    label: '收入',
                    data: trendData.incomes || [],
                    borderColor: '#4CAF50',
                    backgroundColor: 'rgba(76, 175, 80, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                },
                {
                    label: '支出',
                    data: trendData.expenses || [],
                    borderColor: '#F44336',
                    backgroundColor: 'rgba(244, 67, 54, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `${context.dataset.label}: ${formatCurrency(context.raw)}`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return '¥' + value.toLocaleString();
                        }
                    }
                }
            }
        }
    });
}

/**
 * 渲染年度趋势图表
 */
function renderYearlyTrendChart(trendData, year) {
    const ctx = document.getElementById('yearlyTrendChart').getContext('2d');

    // 销毁之前的图表
    if (trendChart) {
        trendChart.destroy();
    }

    trendChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: trendData.labels || [],
            datasets: [
                {
                    label: '收入',
                    data: trendData.incomes || [],
                    backgroundColor: 'rgba(76, 175, 80, 0.7)',
                    borderColor: '#4CAF50',
                    borderWidth: 1
                },
                {
                    label: '支出',
                    data: trendData.expenses || [],
                    backgroundColor: 'rgba(244, 67, 54, 0.7)',
                    borderColor: '#F44336',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                },
                title: {
                    display: true,
                    text: `${year}年收支趋势`
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return '¥' + value.toLocaleString();
                        }
                    }
                }
            }
        }
    });

    // 更新趋势表格
    updateTrendTable(trendData);
}

/**
 * 渲染类别分析图表
 */
function renderCategoryCharts(categoryData) {
    // 饼图
    const pieCtx = document.getElementById('categoryPieChart').getContext('2d');
    if (pieChart) {
        pieChart.destroy();
    }

    pieChart = new Chart(pieCtx, {
        type: 'pie',
        data: {
            labels: categoryData.categories || [],
            datasets: [{
                data: categoryData.amounts || [],
                backgroundColor: generateColors(categoryData.categories?.length || 0),
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right',
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const value = context.raw || 0;
                            const total = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                            const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                            return `${context.label}: ${formatCurrency(value)} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });

    // 柱状图
    const barCtx = document.getElementById('categoryBarChart').getContext('2d');
    if (barChart) {
        barChart.destroy();
    }

    barChart = new Chart(barCtx, {
        type: 'bar',
        data: {
            labels: categoryData.categories || [],
            datasets: [{
                label: '金额',
                data: categoryData.amounts || [],
                backgroundColor: generateColors(categoryData.categories?.length || 0, 0.7),
                borderColor: generateColors(categoryData.categories?.length || 0),
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return '¥' + value.toLocaleString();
                        }
                    }
                }
            }
        }
    });
}

/**
 * 更新分类排名
 */
function updateCategoryRanking(containerId, categories, type) {
    const container = document.querySelector(containerId);
    if (!container) return;

    if (!categories || categories.length === 0) {
        container.innerHTML = `
            <div class="text-center py-4">
                <i class="fas fa-chart-bar fa-2x text-muted mb-3"></i>
                <p class="text-muted">暂无${type}数据</p>
            </div>
        `;
        return;
    }

    let html = '';
    categories.forEach((category, index) => {
        const rankClass = index < 3 ? `top-${index + 1}` : '';
        html += `
            <div class="category-rank-item fade-in">
                <div class="rank-number ${rankClass}">${index + 1}</div>
                <div class="category-info">
                    <div class="d-flex justify-content-between">
                        <span class="category-name">${category.category || '未分类'}</span>
                        <span class="category-amount">${formatCurrency(category.amount || 0)}</span>
                    </div>
                    <div class="progress progress-sm">
                        <div class="progress-bar ${type === '收入' ? 'bg-success' : 'bg-danger'}" 
                             style="width: ${category.percentage || 0}%"></div>
                    </div>
                    <div class="d-flex justify-content-between mt-1">
                        <small class="text-muted">占比</small>
                        <small class="category-percentage">${(category.percentage || 0).toFixed(1)}%</small>
                    </div>
                </div>
            </div>
        `;
    });

    container.innerHTML = html;
}

/**
 * 更新年度统计
 */
function updateYearlyStatistics(trendData) {
    const totalIncome = trendData.incomes?.reduce((sum, income) => sum + (income || 0), 0) || 0;
    const totalExpense = trendData.expenses?.reduce((sum, expense) => sum + (expense || 0), 0) || 0;
    const balance = totalIncome - totalExpense;

    updateElementText('yearlyTotalIncome', formatCurrency(totalIncome));
    updateElementText('yearlyTotalExpense', formatCurrency(totalExpense));
    updateElementText('yearlyBalance', formatCurrency(balance));
}

/**
 * 更新趋势表格
 */
function updateTrendTable(trendData) {
    const tbody = document.getElementById('trendTableBody');
    if (!tbody) return;

    let html = '';
    const incomes = trendData.incomes || [];
    const expenses = trendData.expenses || [];

    incomes.forEach((income, index) => {
        const expense = expenses[index] || 0;
        const balance = income - expense;
        const monthLabel = trendData.labels?.[index] || `第${index + 1}月`;

        // 计算趋势
        const prevIncome = incomes[index - 1] || 0;
        const prevExpense = expenses[index - 1] || 0;
        const incomeTrend = prevIncome > 0 ? ((income - prevIncome) / prevIncome * 100).toFixed(1) : 0;
        const expenseTrend = prevExpense > 0 ? ((expense - prevExpense) / prevExpense * 100).toFixed(1) : 0;

        html += `
            <tr>
                <td>${monthLabel}</td>
                <td class="text-success">${formatCurrency(income)}</td>
                <td class="text-danger">${formatCurrency(expense)}</td>
                <td class="${balance >= 0 ? 'text-success' : 'text-danger'}">${formatCurrency(balance)}</td>
                <td>
                    <span class="trend-indicator ${incomeTrend > 0 ? 'trend-up' : incomeTrend < 0 ? 'trend-down' : 'trend-stable'}">
                        <i class="fas ${incomeTrend > 0 ? 'fa-arrow-up' : incomeTrend < 0 ? 'fa-arrow-down' : 'fa-minus'} me-1"></i>
                        ${Math.abs(incomeTrend)}%
                    </span>
                </td>
                <td>
                    <span class="trend-indicator ${expenseTrend > 0 ? 'trend-up' : expenseTrend < 0 ? 'trend-down' : 'trend-stable'}">
                        <i class="fas ${expenseTrend > 0 ? 'fa-arrow-up' : expenseTrend < 0 ? 'fa-arrow-down' : 'fa-minus'} me-1"></i>
                        ${Math.abs(expenseTrend)}%
                    </span>
                </td>
            </tr>
        `;
    });

    tbody.innerHTML = html;
}

/**
 * 更新分类表格
 */
function updateCategoryTable(categoryData) {
    const tbody = document.getElementById('categoryTableBody');
    if (!tbody) return;

    let html = '';
    const categories = categoryData.categories || [];
    const amounts = categoryData.amounts || [];
    const total = categoryData.total || 0;

    categories.forEach((category, index) => {
        const amount = amounts[index] || 0;
        const percentage = total > 0 ? ((amount / total) * 100).toFixed(1) : 0;

        // 解析分类和类型
        const [categoryName, type] = category.includes('(收入)') ?
            [category.replace('(收入)', ''), '收入'] :
            [category.replace('(支出)', ''), '支出'];

        html += `
            <tr>
                <td>${categoryName}</td>
                <td>
                    <span class="badge ${type === '收入' ? 'bg-success' : 'bg-danger'}">
                        ${type}
                    </span>
                </td>
                <td class="${type === '收入' ? 'text-success' : 'text-danger'}">${formatCurrency(amount)}</td>
                <td>${percentage}%</td>
                <td>${formatCurrency(amount / 12)}</td>
            </tr>
        `;
    });

    tbody.innerHTML = html;
}

/**
 * 切换报表类型
 */
function switchReport(type) {
    // 更新当前报表类型
    currentReportType = type;

    // 更新按钮状态
    document.querySelectorAll('[data-report-type]').forEach(btn => {
        if (btn.getAttribute('data-report-type') === type) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    // 显示对应的报表区域
    document.querySelectorAll('.report-section').forEach(section => {
        if (section.id === type + 'Report') {
            section.style.display = 'block';
            section.classList.add('fade-in');

            // 加载对应报表数据
            switch (type) {
                case 'monthly':
                    loadMonthlyReport(currentYear, currentMonth);
                    break;
                case 'trend':
                    loadTrendReport();
                    break;
                case 'categories':
                    loadCategoryAnalysis();
                    break;
                case 'export':
                    loadExportHistory();
                    break;
            }
        } else {
            section.style.display = 'none';
            section.classList.remove('fade-in');
        }
    });

    // 更新URL
    updateUrlParam('reportType', type);
}

/**
 * 应用日期筛选
 */
function applyDateFilter() {
    const period = document.getElementById('reportPeriod').value;
    const today = new Date();

    switch (period) {
        case 'current':
            currentMonth = today.getMonth() + 1;
            currentYear = today.getFullYear();
            break;
        case 'last':
            const lastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            currentMonth = lastMonth.getMonth() + 1;
            currentYear = lastMonth.getFullYear();
            break;
        case 'quarter':
            // 加载季度报告
            loadQuarterReport();
            return;
        case 'year':
            // 加载年度报告
            switchReport('trend');
            return;
        case 'custom':
            // 显示自定义日期范围选择器
            return;
    }

    // 重新加载月度报告
    loadMonthlyReport(currentYear, currentMonth);
}

/**
 * 生成自定义报表
 */
async function generateCustomReport() {
    const startDate = document.getElementById('startDate').value;
    const endDate = document.getElementById('endDate').value;
    const reportType = document.getElementById('customReportType').value;

    if (!startDate || !endDate) {
        showError('请选择开始日期和结束日期');
        return;
    }

    try {
        showLoading('#' + reportType + 'Report');

        const response = await fetch('/api/reports/custom', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                startDate: startDate,
                endDate: endDate,
                reportType: reportType
            })
        });

        const result = await response.json();

        if (result.success) {
            showSuccess('自定义报表生成成功');
            // 根据报表类型处理结果
            switch (reportType) {
                case 'monthly':
                    // 处理月度汇总
                    break;
                case 'trend':
                    // 处理趋势分析
                    break;
                case 'categories':
                    // 处理类别分析
                    break;
            }
        } else {
            throw new Error(result.message);
        }
    } catch (error) {
        console.error('生成自定义报表失败:', error);
        showError('生成自定义报表失败: ' + error.message);
    }
}

/**
 * 导出报表
 */
async function exportReports() {
    const startDate = document.getElementById('exportStartDate').value;
    const endDate = document.getElementById('exportEndDate').value;
    const format = document.querySelector('input[name="exportFormat"]:checked').value;

    // 收集选中的报表类型
    const reportTypes = [];
    if (document.getElementById('exportMonthly').checked) reportTypes.push('monthly');
    if (document.getElementById('exportTrend').checked) reportTypes.push('trend');
    if (document.getElementById('exportCategories').checked) reportTypes.push('categories');

    if (reportTypes.length === 0) {
        showError('请至少选择一种报表类型');
        return;
    }

    try {
        showLoading('#exportReport');

        const response = await fetch('/api/reports/export', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                startDate: startDate,
                endDate: endDate,
                formats: format,
                reportTypes: reportTypes
            })
        });

        const result = await response.json();

        if (result.success && result.data && result.data.downloadUrl) {
            // 创建下载链接
            const link = document.createElement('a');
            link.href = result.data.downloadUrl;
            link.download = result.data.filename;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            showSuccess('报表导出成功，开始下载');

            // 添加到导出历史
            addExportHistory({
                filename: result.data.filename,
                format: format,
                size: result.data.size,
                timestamp: new Date().toISOString()
            });

        } else {
            throw new Error(result.message || '导出失败');
        }
    } catch (error) {
        console.error('导出报表失败:', error);
        showError('导出报表失败: ' + error.message);
    } finally {
        hideLoading('#exportReport');
    }
}

/**
 * 加载导出历史
 */
function loadExportHistory() {
    // 从本地存储获取导出历史
    const history = JSON.parse(localStorage.getItem('exportHistory') || '[]');
    const container = document.getElementById('exportHistory');

    if (!history.length) {
        container.innerHTML = `
            <div class="text-center py-3">
                <i class="fas fa-history fa-2x text-muted mb-2"></i>
                <p class="text-muted">暂无导出记录</p>
            </div>
        `;
        return;
    }

    let html = '';
    history.slice(0, 5).forEach(item => {
        html += `
            <div class="export-history-item">
                <div class="export-file-icon">
                    <i class="fas fa-file-${item.format === 'pdf' ? 'pdf' : 'excel'}"></i>
                </div>
                <div class="export-file-info">
                    <div class="export-file-name">${item.filename}</div>
                    <div class="export-file-meta">
                        ${formatDate(new Date(item.timestamp), 'yyyy-MM-dd HH:mm')} | 
                        ${formatFileSize(item.size || 0)}
                    </div>
                </div>
                <button class="export-download-btn" onclick="downloadExport('${item.filename}')">
                    <i class="fas fa-download"></i>
                </button>
            </div>
        `;
    });

    container.innerHTML = html;
}

/**
 * 添加上月
 */
function prevMonth() {
    currentMonth--;
    if (currentMonth < 1) {
        currentMonth = 12;
        currentYear--;
    }
    loadMonthlyReport(currentYear, currentMonth);
}

/**
 * 添加下月
 */
function nextMonth() {
    currentMonth++;
    if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
    }
    loadMonthlyReport(currentYear, currentMonth);
}

/**
 * 工具函数：格式化货币
 */
function formatCurrency(amount) {
    if (typeof amount === 'string') amount = parseFloat(amount);
    return new Intl.NumberFormat('zh-CN', {
        style: 'currency',
        currency: 'CNY',
        minimumFractionDigits: 2
    }).format(amount || 0);
}

/**
 * 工具函数：格式化日期
 */
function formatDate(date, format) {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');

    return format
        .replace('yyyy', year)
        .replace('MM', month)
        .replace('dd', day)
        .replace('HH', hours)
        .replace('mm', minutes);
}

/**
 * 工具函数：生成颜色
 */
function generateColors(count, opacity = 1) {
    const colors = [
        `rgba(76, 175, 80, ${opacity})`,   // 绿色
        `rgba(244, 67, 54, ${opacity})`,   // 红色
        `rgba(33, 150, 243, ${opacity})`,  // 蓝色
        `rgba(255, 193, 7, ${opacity})`,   // 黄色
        `rgba(156, 39, 176, ${opacity})`,  // 紫色
        `rgba(255, 87, 34, ${opacity})`,   // 橙色
        `rgba(0, 150, 136, ${opacity})`,   // 青色
        `rgba(121, 85, 72, ${opacity})`,   // 棕色
    ];

    const result = [];
    for (let i = 0; i < count; i++) {
        result.push(colors[i % colors.length]);
    }
    return result;
}

/**
 * 工具函数：更新元素文本
 */
function updateElementText(id, text) {
    const element = document.getElementById(id);
    if (element) {
        element.textContent = text;
    }
}

/**
 * 工具函数：显示/隐藏加载状态
 */
function showLoading(container = '#monthlyReport') {
    const element = document.querySelector(container);
    if (element) {
        element.classList.add('loading');
    }
}

function hideLoading(container = '#monthlyReport') {
    const element = document.querySelector(container);
    if (element) {
        element.classList.remove('loading');
    }
}

/**
 * 工具函数：显示消息
 */
function showSuccess(message) {
    showMessage(message, 'success');
}

function showError(message) {
    showMessage(message, 'danger');
}

function showMessage(message, type) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    alertDiv.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'} me-2"></i>
            <div class="flex-grow-1">${message}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;

    document.body.appendChild(alertDiv);

    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.remove();
        }
    }, 5000);
}

// 在 reports.js 中添加日期工具函数
function formatDateForInput(date) {
    if (!date) return '';
    if (date instanceof Date) {
        return date.toISOString().split('T')[0];
    }
    if (typeof date === 'string') {
        return date.split('T')[0];
    }
    return '';
}

/**
 * 工具函数：更新URL参数
 */
function updateUrlParam(key, value) {
    const url = new URL(window.location);
    url.searchParams.set(key, value);
    window.history.replaceState({}, '', url);
}

// 初始化页面
document.addEventListener('DOMContentLoaded', function() {
    console.log('报表统计页面初始化完成');

    // 设置默认报表
    switchReport('monthly');

    // 设置事件监听器
    document.getElementById('reportPeriod')?.addEventListener('change', applyDateFilter);
});