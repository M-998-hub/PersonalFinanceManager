<!-- 筛选表单 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="filter-card">
    <h5 class="fw-bold mb-3">筛选交易</h5>
    <form id="filterForm" onsubmit="TransactionManager.filterTransactions(event)">
        <div class="row g-3">
            <div class="col-md-3">
                <label for="startDate" class="form-label">开始日期</label>
                <input type="date" class="form-control" id="startDate">
            </div>
            <div class="col-md-3">
                <label for="endDate" class="form-label">结束日期</label>
                <input type="date" class="form-control" id="endDate">
            </div>
            <div class="col-md-2">
                <label for="type" class="form-label">交易类型</label>
                <select class="form-select" id="type">
                    <option value="">全部类型</option>
                    <option value="INCOME">收入</option>
                    <option value="EXPENSE">支出</option>
                </select>
            </div>
            <div class="col-md-2">
                <label for="category" class="form-label">分类</label>
                <select class="form-select" id="category">
                    <option value="">全部分类</option>
                    <option value="FOOD">餐饮</option>
                    <option value="TRANSPORTATION">交通</option>
                    <option value="SHOPPING">购物</option>
                    <option value="ENTERTAINMENT">娱乐</option>
                    <option value="UTILITIES">生活缴费</option>
                    <option value="HEALTH">医疗健康</option>
                    <option value="EDUCATION">教育学习</option>
                    <option value="SALARY">工资收入</option>
                    <option value="INVESTMENT">投资收益</option>
                    <option value="OTHER">其他</option>
                </select>
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <div class="d-flex gap-2 w-100">
                    <button type="submit" class="btn btn-primary flex-grow-1">
                        <i class="fas fa-filter me-2"></i>筛选
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="TransactionManager.resetFilters()">
                        <i class="fas fa-redo"></i>
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>