<%-- login-content.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<div class="login-container">
    <div class="login-card">
        <!-- 登录页面具体内容 -->
        <div class="login-header">
            <h1><i class="fas fa-piggy-bank me-2"></i>个人经济管理系统</h1>
            <p>管理您的财务，掌控您的未来</p>
        </div>

        <form id="loginForm" class="login-form" novalidate>
            <div class="form-group">
                <label for="username" class="form-label">用户名</label>
                <input type="text" class="form-control" id="username" name="username"
                       placeholder="请输入用户名" required>
                <div class="feedback" id="username-feedback"></div>
            </div>

            <div class="form-group">
                <label for="password" class="form-label">密码</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="请输入密码" required>
                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <div class="password-strength">
                    <div class="password-strength-bar" id="password-strength-bar"></div>
                </div>
                <div class="feedback" id="password-feedback">
                    <i class="fas fa-info-circle"></i>
                    <span>密码强度：<span id="password-strength-text">未输入</span></span>
                </div>
            </div>

            <div class="login-options">
                <div class="remember-me">
                    <input type="checkbox" class="form-check-input" id="rememberMe" name="rememberMe">
                    <label for="rememberMe" class="form-check-label">记住我</label>
                </div>
                <a href="#" id="forgotPassword" class="forgot-password">忘记密码？</a>
            </div>

            <button type="submit" class="btn btn-primary login-btn">
                <i class="fas fa-sign-in-alt me-2"></i>登录
            </button>
        </form>

        <div class="register-guide">
            <p>还没有账户？</p>
            <a href="${contextPath}/register-page">立即注册</a>
        </div>
    </div>
</div>