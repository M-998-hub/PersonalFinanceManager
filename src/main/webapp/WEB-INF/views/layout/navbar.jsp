<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="/dashboard-page">
            <i class="fas fa-piggy-bank me-2"></i>
            个人经济管家
        </a>

        <div class="d-flex align-items-center">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <span class="me-3 text-muted">
                        欢迎，<strong>${sessionScope.currentUser.username}</strong>
                    </span>
                    <div class="dropdown">
                        <button class="btn btn-outline-secondary dropdown-toggle" type="button"
                                data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle"></i>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="/dashboard-page">
                                <i class="fas fa-tachometer-alt me-2"></i>仪表板
                            </a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="/api/auth/logout">
                                <i class="fas fa-sign-out-alt me-2"></i>退出登录
                            </a></li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="/login-page" class="btn btn-outline-primary me-2">登录</a>
                    <a href="/register-page" class="btn btn-primary">注册</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>