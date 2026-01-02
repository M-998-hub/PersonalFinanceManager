<%-- auth-base.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // 获取应用上下文路径
    String contextPath = request.getContextPath();
    pageContext.setAttribute("contextPath", contextPath);

    // 获取页面特定参数
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = request.getParameter("pageTitle");
    }

    String pageClass = (String) request.getAttribute("pageClass");
    if (pageClass == null) {
        pageClass = request.getParameter("pageClass");
    }
    if (pageClass == null) {
        pageClass = "auth-page";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="<%= pageTitle %>" default="个人经济管理系统" /></title>

    <!-- 图标 -->
    <link rel="icon" href="${contextPath}/favicon.ico" type="image/x-icon">

    <!-- Bootstrap 5.3 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- 本地设计系统 -->
    <link href="${contextPath}/css/global.css" rel="stylesheet">
    <link href="${contextPath}/css/components.css" rel="stylesheet">
    <link href="${contextPath}/css/layout.css" rel="stylesheet">

    <!-- 页面特定CSS -->
    <%
        String pageCss = (String) request.getAttribute("pageCss");
        if (pageCss == null) {
            pageCss = request.getParameter("pageCss");
        }
        if (pageCss != null && !pageCss.isEmpty()) {
    %>
    <link href="${contextPath}/css/<%= pageCss %>" rel="stylesheet">
    <%
        }
    %>
</head>
<body class="<%= pageClass %>">
<!-- 消息容器 -->
<div class="toast-container" aria-live="polite" aria-atomic="true"></div>

<!-- 页面内容 -->
<main class="auth-container <%= pageClass %>-container">
    <%
        String contentPage = (String) request.getAttribute("contentPage");
        if (contentPage == null) {
            contentPage = request.getParameter("contentPage");
        }
        if (contentPage != null && !contentPage.isEmpty()) {
    %>
    <jsp:include page="<%= contentPage %>" />
    <%
        }
    %>
</main>

<!-- 条款模态框 -->
<div class="modal fade" id="termsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">用户服务协议</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <h6>1. 服务条款的接受</h6>
                <p>欢迎使用个人经济管理系统。请您仔细阅读以下条款，如果您对本协议的任何条款表示异议，您可以选择不使用本系统。</p>

                <h6>2. 服务内容</h6>
                <p>本系统为您提供个人财务管理功能，包括但不限于：收支记录、预算管理、报表分析等。</p>

                <h6>3. 用户责任</h6>
                <p>您应保证提供的注册信息真实、准确、完整，并及时更新。您应对账户和密码的安全负责。</p>

                <h6>4. 隐私保护</h6>
                <p>我们将保护您的个人信息安全，具体政策请参见《隐私政策》。</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button>
            </div>
        </div>
    </div>
</div>

<!-- 隐私政策模态框 -->
<div class="modal fade" id="privacyModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">隐私政策</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <h6>1. 信息收集</h6>
                <p>我们收集的信息包括：您注册时提供的信息、使用服务时产生的数据等。</p>

                <h6>2. 信息使用</h6>
                <p>您的信息将用于：提供和改善服务、与您沟通、保障账户安全等。</p>

                <h6>3. 信息保护</h6>
                <p>我们采取合理的安全措施保护您的个人信息，防止未经授权的访问、使用或泄露。</p>

                <h6>4. 信息共享</h6>
                <p>未经您同意，我们不会向第三方共享您的个人信息，除非法律法规要求。</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- 本地工具库 -->
<script src="${contextPath}/js/utils.js"></script>
<script src="${contextPath}/js/auth-common.js"></script>

<!-- 页面特定JS -->
<%
    String pageJs = (String) request.getAttribute("pageJs");
    if (pageJs == null) {
        pageJs = request.getParameter("pageJs");
    }
    if (pageJs != null && !pageJs.isEmpty()) {
%>
<script src="${contextPath}/js/<%= pageJs %>"></script>
<%
    }
%>
</body>
</html>