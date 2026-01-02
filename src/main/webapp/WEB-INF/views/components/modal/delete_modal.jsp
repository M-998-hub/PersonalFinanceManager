<!-- 删除确认模态框 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title text-danger">确认删除</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>您确定要删除这笔交易吗？此操作无法撤销。</p>
                <p class="text-muted" id="deleteTransactionInfo"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteButton" onclick="TransactionManager.deleteTransaction()">
                    <span class="spinner-border spinner-border-sm me-2" role="status" style="display: none;"></span>
                    确认删除
                </button>
            </div>
        </div>
    </div>
</div>