<%-- 参数说明：
     type: 'income', 'expense', 'balance'
     title: 卡片标题
     value: 显示的值
     id: DOM元素ID
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="cardConfig">
    <c:choose>
        <c:when test="${param.type == 'income'}">
            {"color": "success", "icon": "fa-arrow-down", "textClass": "transaction-amount-income"}
        </c:when>
        <c:when test="${param.type == 'expense'}">
            {"color": "danger", "icon": "fa-arrow-up", "textClass": "transaction-amount-expense"}
        </c:when>
        <c:otherwise>
            {"color": "primary", "icon": "fa-wallet", "textClass": "text-primary"}
        </c:otherwise>
    </c:choose>
</c:set>

<div class="stats-card">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h6 class="text-muted mb-2">${param.title}</h6>
            <h3 class="mb-0 ${textClass}" id="${param.id}">${param.value}</h3>
        </div>
        <div class="bg-${color} bg-opacity-10 p-3 rounded-circle">
            <i class="fas ${icon} text-${color} fs-4"></i>
        </div>
    </div>
</div>