<%-- user_login.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/layout/auth-base.jsp">
    <jsp:param name="pageTitle" value="用户登录 - 个人经济管理系统" />
    <jsp:param name="pageClass" value="login-page" />
    <jsp:param name="pageCss" value="login.css" />
    <jsp:param name="pageJs" value="login.js" />
    <jsp:param name="contentPage" value="/WEB-INF/views/pages/login-content.jsp" />
</jsp:include>
