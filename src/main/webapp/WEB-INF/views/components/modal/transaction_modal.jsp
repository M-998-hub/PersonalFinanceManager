<!-- 添加/编辑交易模态框 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="modal fade" id="transactionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">添加交易</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="transactionForm" onsubmit="TransactionManager.saveTransaction(event)">
                <div class="modal-body">
                    <input type="hidden" id="transactionId">

                    <div class="mb-3">
                        <label for="modalType" class="form-label">交易类型 <span class="text-danger">*</span></label>
                        <select class="form-select" id="modalType" required>
                            <option value="">请选择类型</option>
                            <option value="INCOME">收入</option>
                            <option value="EXPENSE">支出</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="modalAmount" class="form-label">金额 <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text">¥</span>
                            <input type="number" class="form-control" id="modalAmount" step="0.01" min="0" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="modalDescription" class="form-label">描述 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="modalDescription" required maxlength="100">
                    </div>

                    <div class="mb-3">
                        <label for="modalCategory" class="form-label">分类 <span class="text-danger">*</span></label>
                        <select class="form-select" id="modalCategory" required>
                            <option value="">请选择分类</option>
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

                    <div class="mb-3">
                        <label for="modalDate" class="form-label">日期 <span class="text-danger">*</span></label>
                        <input type="datetime-local" class="form-control" id="modalDate" required>
                    </div>

                    <div class="mb-3">
                        <label for="modalNotes" class="form-label">备注</label>
                        <textarea class="form-control" id="modalNotes" rows="3" maxlength="500"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="submit" class="btn btn-primary" id="saveButton">
                        <span class="spinner-border spinner-border-sm me-2" role="status" style="display: none;"></span>
                        保存交易
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>