<!-- 交易表格 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="table-container">
    <div class="table-header">
        <h5 class="mb-0 fw-bold">交易列表</h5>
        <div class="text-muted" id="totalCountText">共 0 条记录</div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover" id="transactionsTable">
            <thead>
            <tr>
                <th width="15%">日期</th>
                <th width="25%">描述</th>
                <th width="15%">分类</th>
                <th width="15%">类型</th>
                <th width="15%">金额</th>
                <th width="15%">操作</th>
            </tr>
            </thead>
            <tbody id="transactionsBody">
            <!-- 交易数据将通过JavaScript动态加载 -->
            <tr id="loadingRow">
                <td colspan="6" class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">加载中...</span>
                    </div>
                    <p class="mt-2 text-muted">正在加载交易数据...</p>
                </td>
            </tr>
            </tbody>
        </table>

        <!-- 空状态 -->
        <div id="emptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-receipt"></i>
            </div>
            <h5 class="mb-2" id="emptyStateMessage">暂无交易记录</h5>
            <p class="text-muted mb-4">添加您的第一笔交易开始记录吧</p>
            <button type="button" class="btn btn-primary" onclick="TransactionManager.openAddModal()">
                <i class="fas fa-plus me-2"></i>添加交易
            </button>
        </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-container" id="paginationContainer" style="display: none;">
        <nav aria-label="交易分页">
            <ul class="pagination" id="pagination">
                <!-- 分页按钮将通过JavaScript动态生成 -->
            </ul>
        </nav>
    </div>
</div>