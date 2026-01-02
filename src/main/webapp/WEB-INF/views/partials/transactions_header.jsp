<!-- 页面标题和操作按钮 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h2 fw-bold mb-1">交易管理</h1>
        <p class="text-muted mb-0">管理您的所有收入和支出记录</p>
    </div>
    <div>
        <button type="button" class="btn btn-primary" onclick="openAddTransactionModal()">
            <i class="fas fa-plus me-2"></i>添加交易
        </button>
    </div>
</div>