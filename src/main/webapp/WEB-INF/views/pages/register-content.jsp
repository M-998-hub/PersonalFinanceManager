<%-- register-content.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<div class="register-card">
    <div class="register-header">
        <h1><i class="fas fa-piggy-bank me-2"></i>个人经济管理系统</h1>
        <p class="mt-2">开始您的财务管理之旅</p>
    </div>

    <!-- 注册表单 -->
    <div class="register-body">
        <!-- 步骤指示器 -->
        <div class="step-indicator">
            <div class="step active" data-step="1">
                <div class="step-circle">1</div>
                <div class="step-label">账户信息</div>
            </div>
            <div class="step" data-step="2">
                <div class="step-circle">2</div>
                <div class="step-label">个人资料</div>
            </div>
            <div class="step" data-step="3">
                <div class="step-circle">3</div>
                <div class="step-label">完成</div>
            </div>
        </div>

        <!-- 步骤1：账户信息 -->
        <form class="form-step active" data-step="1">
            <h3 class="mb-4">账户信息</h3>

            <div class="form-group">
                <label class="form-label">用户名</label>
                <input type="text" class="form-control" id="username" name="username" required>
            </div>

            <div class="form-group">
                <label class="form-label">邮箱</label>
                <input type="email" class="form-control" id="email" name="email" required>
            </div>

            <div class="form-group">
                <label class="form-label">密码</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="password" name="password" required>
                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">确认密码</label>
                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
            </div>

            <div class="d-flex justify-content-end mt-4">
                <button type="button" class="btn btn-primary" id="next-step-1">
                    下一步 <i class="fas fa-arrow-right ms-2"></i>
                </button>
            </div>
        </form>

        <!-- 步骤2：个人资料 -->
        <form class="form-step" data-step="2">
            <h3 class="mb-4">个人资料</h3>

            <div class="form-group">
                <label class="form-label">姓名</label>
                <input type="text" class="form-control" id="fullName" name="fullName">
            </div>

            <div class="form-group">
                <label class="form-label">手机号</label>
                <input type="tel" class="form-control" id="phone" name="phone">
            </div>

            <div class="terms-check">
                <input type="checkbox" class="form-check-input" id="terms" required>
                <label class="form-check-label" for="terms">
                    我已阅读并同意 <a href="#" data-bs-toggle="modal" data-bs-target="#termsModal">《用户服务协议》</a> 和
                    <a href="#" data-bs-toggle="modal" data-bs-target="#privacyModal">《隐私政策》</a>
                </label>
            </div>

            <div class="d-flex justify-content-between mt-4">
                <button type="button" class="btn btn-outline-secondary" id="prev-step-2">
                    <i class="fas fa-arrow-left me-2"></i>上一步
                </button>
                <button type="button" class="btn btn-primary" id="next-step-2">
                    下一步 <i class="fas fa-arrow-right ms-2"></i>
                </button>
            </div>
        </form>

        <!-- 步骤3：确认 -->
        <div class="form-step" data-step="3">
            <div class="text-center">
                <i class="fas fa-check-circle success-icon"></i>
                <h3 class="mb-3">确认注册</h3>

                <div class="card bg-light mb-4">
                    <div class="card-body text-start">
                        <p><strong>用户名：</strong> <span id="summary-username"></span></p>
                        <p><strong>邮箱：</strong> <span id="summary-email"></span></p>
                    </div>
                </div>

                <div class="d-flex justify-content-between">
                    <button type="button" class="btn btn-outline-secondary" id="prev-step-3">
                        <i class="fas fa-arrow-left me-2"></i>返回
                    </button>
                    <button type="button" class="btn btn-success" id="submit-register">
                        <i class="fas fa-check me-2"></i>确认注册
                    </button>
                </div>
            </div>
        </div>

        <!-- 登录链接 -->
        <div class="text-center mt-4">
            <a href="/login-page" class="text-primary">已有账户？立即登录</a>
        </div>
    </div>
</div>