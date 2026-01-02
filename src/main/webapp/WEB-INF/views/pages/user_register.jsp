<%-- user_register.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/layout/auth-base.jsp">
    <jsp:param name="pageTitle" value="用户注册 - 个人经济管理系统" />
    <jsp:param name="pageClass" value="register-page" />
    <jsp:param name="pageCss" value="register.css" />
    <jsp:param name="pageJs" value="register.js" />
    <jsp:param name="contentPage" value="/WEB-INF/views/pages/register-content.jsp" />
</jsp:include>
