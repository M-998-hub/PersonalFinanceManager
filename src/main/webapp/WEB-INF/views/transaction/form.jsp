<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>${pageTitle}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
    <h1>${pageTitle}</h1>

    <form method="post" action="/admin/transactions">
        <!-- 如果是编辑，需要隐藏的ID字段 -->
        <c:if test="${not empty transaction.id}">
            <input type="hidden" name="id" value="${transaction.id}">
        </c:if>

        <div class="mb-3">
            <label class="form-label">类别 *</label>
            <input type="text" class="form-control" name="category"
                   value="${transaction.category}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">类型 *</label>
            <select class="form-select" name="type" required>
                <option value="INCOME" ${transaction.type == 'INCOME' ? 'selected' : ''}>收入</option>
                <option value="EXPENSE" ${transaction.type == 'EXPENSE' ? 'selected' : ''}>支出</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">金额 *</label>
            <input type="number" step="0.01" class="form-control" name="amount"
                   value="${transaction.amount}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">描述</label>
            <textarea class="form-control" name="description">${transaction.description}</textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">日期</label>
            <input type="datetime-local" class="form-control" name="date"
                   value="${transaction.date != null ? transaction.date.format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) : ''}">
            <small class="text-muted">留空则使用当前时间</small>
        </div>

        <button type="submit" class="btn btn-primary">保存</button>
        <a href="/admin/transactions" class="btn btn-secondary">取消</a>
    </form>
</div>
</body>
</html>