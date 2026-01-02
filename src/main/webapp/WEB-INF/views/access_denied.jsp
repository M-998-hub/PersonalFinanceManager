<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>访问被拒绝</title>
</head>
<body>
<h1>访问被拒绝</h1>
<p>您没有权限访问此页面。</p>
<a href="/dashboard-page">返回首页</a> |
<a href="#" onclick="logout()">退出登录</a>

<script>
    function logout() {
        fetch('/api/auth/logout', { method: 'POST' })
            .then(() => window.location.href = '/login-page');
    }
</script>
</body>
</html>