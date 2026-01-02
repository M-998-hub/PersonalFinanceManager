<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册 - 个人经济管理系统</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 图标 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- 密码强度检查库 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/password-strength-meter/2.3.1/password.min.css">

    <style>
        :root {
            --primary-color: #4361ee;
            --success-color: #06d6a0;
            --warning-color: #ffd166;
            --danger-color: #ef476f;
            --dark-color: #2b2d42;
            --light-color: #f8f9fa;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 20px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .register-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            max-width: 800px;
            width: 100%;
            margin: 0 auto;
        }

        .register-header {
            background: linear-gradient(to right, var(--primary-color), #3a56d4);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .register-header h1 {
            margin: 0;
            font-weight: 700;
            font-size: 2.2rem;
        }

        .register-header p {
            opacity: 0.9;
            margin-top: 10px;
            font-size: 1.1rem;
        }

        .register-body {
            padding: 40px;
        }

        .step-indicator {
            display: flex;
            justify-content: space-between;
            margin-bottom: 40px;
            position: relative;
        }

        .step-indicator::before {
            content: '';
            position: absolute;
            top: 15px;
            left: 0;
            right: 0;
            height: 2px;
            background: #e9ecef;
            z-index: 1;
        }

        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 2;
            flex: 1;
        }

        .step-circle {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #e9ecef;
            color: #6c757d;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-bottom: 10px;
            border: 3px solid white;
            transition: all 0.3s ease;
        }

        .step.active .step-circle {
            background: var(--primary-color);
            color: white;
            transform: scale(1.1);
        }

        .step.completed .step-circle {
            background: var(--success-color);
            color: white;
        }

        .step-label {
            font-size: 0.9rem;
            color: #6c757d;
            text-align: center;
        }

        .step.active .step-label {
            color: var(--primary-color);
            font-weight: 600;
        }

        .form-step {
            display: none;
        }

        .form-step.active {
            display: block;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--dark-color);
            display: flex;
            align-items: center;
        }

        .form-label .required {
            color: var(--danger-color);
            margin-left: 4px;
        }

        .form-control {
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
        }

        .form-control.is-valid {
            border-color: var(--success-color);
        }

        .form-control.is-invalid {
            border-color: var(--danger-color);
        }

        .input-group-text {
            background: #f8f9fa;
            border: 2px solid #e9ecef;
            border-right: none;
        }

        .input-group .form-control {
            border-left: none;
        }

        .input-group .form-control:focus {
            border-left: none;
        }

        .feedback {
            font-size: 0.875rem;
            margin-top: 5px;
            display: flex;
            align-items: center;
        }

        .valid-feedback {
            color: var(--success-color);
        }

        .invalid-feedback {
            color: var(--danger-color);
        }

        .feedback i {
            margin-right: 5px;
        }

        .password-strength {
            height: 5px;
            background: #e9ecef;
            border-radius: 5px;
            margin-top: 10px;
            overflow: hidden;
        }

        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: width 0.3s ease, background-color 0.3s ease;
        }

        .strength-weak {
            background-color: var(--danger-color);
            width: 25%;
        }

        .strength-fair {
            background-color: var(--warning-color);
            width: 50%;
        }

        .strength-good {
            background-color: #4cd964;
            width: 75%;
        }

        .strength-strong {
            background-color: var(--success-color);
            width: 100%;
        }

        .btn {
            border-radius: 10px;
            padding: 12px 24px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-primary:hover {
            background: #3a56d4;
            border-color: #3a56d4;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(67, 97, 238, 0.3);
        }

        .btn-outline-secondary {
            border-color: #dee2e6;
            color: #6c757d;
        }

        .btn-outline-secondary:hover {
            background: #f8f9fa;
            border-color: #adb5bd;
        }

        .step-buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }

        .terms-check {
            display: flex;
            align-items: flex-start;
            margin-top: 20px;
        }

        .terms-check input {
            margin-top: 3px;
            margin-right: 10px;
        }

        .terms-check label {
            font-size: 0.9rem;
            color: #6c757d;
        }

        .terms-check a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .terms-check a:hover {
            text-decoration: underline;
        }

        .login-link {
            text-align: center;
            margin-top: 30px;
            color: #6c757d;
        }

        .login-link a {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        .success-message {
            text-align: center;
            padding: 40px 0;
        }

        .success-message i {
            font-size: 4rem;
            color: var(--success-color);
            margin-bottom: 20px;
        }

        .avatar-preview {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: #f8f9fa;
            border: 3px solid #e9ecef;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .avatar-preview:hover {
            border-color: var(--primary-color);
            transform: scale(1.05);
        }

        .avatar-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .avatar-preview i {
            font-size: 2.5rem;
            color: #adb5bd;
        }

        .avatar-upload {
            display: none;
        }

        .progress {
            height: 8px;
            border-radius: 4px;
            margin-top: 10px;
        }

        .progress-bar {
            border-radius: 4px;
        }

        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1050;
        }

        .toast {
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
            border: none;
            margin-bottom: 10px;
            min-width: 300px;
        }

        @media (max-width: 768px) {
            .register-container {
                margin: 20px;
            }

            .register-body {
                padding: 25px;
            }

            .step-label {
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body>
<div class="register-container">
    <!-- 头部 -->
    <div class="register-header">
        <h1><i class="fas fa-piggy-bank me-2"></i>个人经济管理系统</h1>
        <p>开始您的财务管理之旅，轻松管理收支预算</p>
    </div>

    <!-- 注册表单主体 -->
    <div class="register-body">
        <!-- 步骤指示器 -->
        <div class="step-indicator">
            <div class="step active" id="step1">
                <div class="step-circle">1</div>
                <div class="step-label">账户信息</div>
            </div>
            <div class="step" id="step2">
                <div class="step-circle">2</div>
                <div class="step-label">个人资料</div>
            </div>
            <div class="step" id="step3">
                <div class="step-circle">3</div>
                <div class="step-label">完成注册</div>
            </div>
        </div>

        <!-- 第一步：账户信息 -->
        <div class="form-step active" id="step1-form">
            <h3 class="mb-4">创建您的账户</h3>

            <div class="form-group">
                <label class="form-label">用户名 <span class="required">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                    <input type="text" class="form-control" id="username" name="username"
                           placeholder="请输入用户名 (3-20位字母数字)"
                           minlength="3" maxlength="20"
                           pattern="[a-zA-Z0-9_]+" required>
                </div>
                <div class="feedback" id="username-feedback">
                    <i class="fas fa-info-circle"></i>
                    <span>用户名只能包含字母、数字和下划线</span>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">邮箱地址 <span class="required">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                    <input type="email" class="form-control" id="email" name="email"
                           placeholder="example@email.com" required>
                </div>
                <div class="feedback" id="email-feedback"></div>
            </div>

            <div class="form-group">
                <label class="form-label">密码 <span class="required">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="至少8位，包含字母和数字"
                           minlength="8" required>
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

            <div class="form-group">
                <label class="form-label">确认密码 <span class="required">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password" class="form-control" id="confirmPassword"
                           placeholder="请再次输入密码" required>
                </div>
                <div class="feedback" id="confirm-feedback"></div>
            </div>

            <div class="step-buttons">
                <div></div> <!-- 空div占位 -->
                <button class="btn btn-primary" id="next-step1">下一步 <i class="fas fa-arrow-right ms-2"></i></button>
            </div>
        </div>

        <!-- 第二步：个人资料 -->
        <div class="form-step" id="step2-form">
            <h3 class="mb-4">完善个人资料</h3>

            <!-- 头像上传 -->
            <div class="text-center mb-4">
                <div class="avatar-preview" id="avatarPreview">
                    <i class="fas fa-user-circle"></i>
                    <img id="avatarImage" style="display: none;">
                </div>
                <input type="file" class="avatar-upload" id="avatarUpload" accept="image/*">
                <button class="btn btn-outline-secondary btn-sm mt-2" id="uploadAvatarBtn">
                    <i class="fas fa-upload me-2"></i>上传头像
                </button>
                <div class="progress mt-2" id="uploadProgress" style="display: none;">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar"></div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label class="form-label">姓名</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-id-card"></i></span>
                            <input type="text" class="form-control" id="fullName" name="fullName"
                                   placeholder="请输入您的真实姓名">
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label class="form-label">手机号码</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-phone"></i></span>
                            <input type="tel" class="form-control" id="phone" name="phone"
                                   placeholder="请输入手机号码" pattern="[0-9]{11}">
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">性别</label>
                <div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="gender" id="male" value="MALE" checked>
                        <label class="form-check-label" for="male">男</label>
                    </div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="gender" id="female" value="FEMALE">
                        <label class="form-check-label" for="female">女</label>
                    </div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="gender" id="other" value="OTHER">
                        <label class="form-check-label" for="other">其他</label>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">出生日期</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-birthday-cake"></i></span>
                    <input type="date" class="form-control" id="birthDate" name="birthDate"
                           max="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">个人简介</label>
                <textarea class="form-control" id="bio" name="bio" rows="3"
                          placeholder="简单介绍一下自己... (最多200字)" maxlength="200"></textarea>
                <div class="text-end mt-2">
                    <small class="text-muted"><span id="bio-counter">0</span>/200</small>
                </div>
            </div>

            <div class="terms-check">
                <input type="checkbox" class="form-check-input" id="terms" required>
                <label class="form-check-label" for="terms">
                    我已阅读并同意 <a href="#" data-bs-toggle="modal" data-bs-target="#termsModal">《用户服务协议》</a> 和
                    <a href="#" data-bs-toggle="modal" data-bs-target="#privacyModal">《隐私政策》</a>
                </label>
            </div>

            <div class="step-buttons">
                <button class="btn btn-outline-secondary" id="prev-step2">
                    <i class="fas fa-arrow-left me-2"></i>上一步
                </button>
                <button class="btn btn-primary" id="next-step2">下一步 <i class="fas fa-arrow-right ms-2"></i></button>
            </div>
        </div>

        <!-- 第三步：完成注册 -->
        <div class="form-step" id="step3-form">
            <div class="success-message">
                <i class="fas fa-check-circle"></i>
                <h3 class="mb-3">注册信息确认</h3>
                <p class="text-muted mb-4">请确认您的注册信息，点击提交完成注册</p>

                <div class="card border-0 bg-light mb-4">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p><strong>用户名：</strong> <span id="summary-username"></span></p>
                                <p><strong>邮箱：</strong> <span id="summary-email"></span></p>
                                <p><strong>姓名：</strong> <span id="summary-name"></span></p>
                            </div>
                            <div class="col-md-6">
                                <p><strong>手机号：</strong> <span id="summary-phone"></span></p>
                                <p><strong>性别：</strong> <span id="summary-gender"></span></p>
                                <p><strong>出生日期：</strong> <span id="summary-birthdate"></span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="step-buttons">
                    <button class="btn btn-outline-secondary" id="prev-step3">
                        <i class="fas fa-arrow-left me-2"></i>返回修改
                    </button>
                    <button class="btn btn-success btn-lg" id="submit-register">
                        <i class="fas fa-user-plus me-2"></i>确认注册
                    </button>
                </div>
            </div>
        </div>

        <div class="login-link">
            已有账户？ <a href="/login-page">立即登录</a>
        </div>
    </div>
</div>

<!-- Toast消息容器 -->
<div class="toast-container"></div>

<!-- 条款模态框 -->
<div class="modal fade" id="termsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">用户服务协议</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>请在此处填写您的用户服务协议内容...</p>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="privacyModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">隐私政策</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>请在此处填写您的隐私政策内容...</p>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

<!-- 注册页面JavaScript -->
<script>
    // 全局变量
    let currentStep = 1;
    let formData = {
        username: '',
        email: '',
        password: '',
        fullName: '',
        phone: '',
        gender: 'MALE',
        birthDate: '',
        bio: '',
        avatar: null
    };

    // DOM加载完成后执行
    document.addEventListener('DOMContentLoaded', function() {
        initEventListeners();
        initFormValidation();
    });

    // 初始化事件监听器
    function initEventListeners() {
        // 步骤导航
        document.getElementById('next-step1').addEventListener('click', validateStep1);
        document.getElementById('prev-step2').addEventListener('click', () => goToStep(1));
        document.getElementById('next-step2').addEventListener('click', validateStep2);
        document.getElementById('prev-step3').addEventListener('click', () => goToStep(2));
        document.getElementById('submit-register').addEventListener('click', submitRegistration);

        // 密码显示/隐藏切换
        document.getElementById('togglePassword').addEventListener('click', togglePasswordVisibility);

        // 实时表单验证
        document.getElementById('username').addEventListener('blur', checkUsernameAvailability);
        document.getElementById('email').addEventListener('blur', checkEmailAvailability);
        document.getElementById('password').addEventListener('input', checkPasswordStrength);
        document.getElementById('confirmPassword').addEventListener('input', validatePasswordMatch);
        document.getElementById('bio').addEventListener('input', updateBioCounter);

        // 头像上传
        document.getElementById('uploadAvatarBtn').addEventListener('click', () => {
            document.getElementById('avatarUpload').click();
        });
        document.getElementById('avatarUpload').addEventListener('change', handleAvatarUpload);
    }

    // 初始化表单验证
    function initFormValidation() {
        const forms = document.querySelectorAll('.needs-validation');
        forms.forEach(form => {
            form.addEventListener('submit', event => {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }

    // 步骤1验证
    async function validateStep1() {
        const username = document.getElementById('username').value;
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        let isValid = true;

        // 验证用户名
        if (!validateUsername(username)) {
            showFieldError('username', '用户名格式不正确（3-20位字母、数字或下划线）');
            isValid = false;
        } else {
            const available = await checkUsernameAvailability();
            if (!available) {
                isValid = false;
            }
        }

        // 验证邮箱
        if (!validateEmail(email)) {
            showFieldError('email', '请输入有效的邮箱地址');
            isValid = false;
        } else {
            const available = await checkEmailAvailability();
            if (!available) {
                isValid = false;
            }
        }

        // 验证密码
        const passwordStrength = calculatePasswordStrength(password);
        if (passwordStrength < 2) { // 密码强度不足
            showFieldError('password', '密码强度不足，请使用更复杂的密码');
            isValid = false;
        }

        // 验证密码匹配
        if (password !== confirmPassword) {
            showFieldError('confirmPassword', '两次输入的密码不一致');
            isValid = false;
        }

        if (isValid) {
            formData.username = username;
            formData.email = email;
            formData.password = password;
            goToStep(2);
        }
    }

    // 步骤2验证
    function validateStep2() {
        // 收集表单数据
        formData.fullName = document.getElementById('fullName').value;
        formData.phone = document.getElementById('phone').value;
        formData.gender = document.querySelector('input[name="gender"]:checked').value;
        formData.birthDate = document.getElementById('birthDate').value;
        formData.bio = document.getElementById('bio').value;

        // 检查条款是否同意
        if (!document.getElementById('terms').checked) {
            showToast('请阅读并同意用户服务协议和隐私政策', 'warning');
            return;
        }

        // 更新确认页面信息
        updateSummary();
        goToStep(3);
    }

    // 更新确认页面信息
    function updateSummary() {
        document.getElementById('summary-username').textContent = formData.username;
        document.getElementById('summary-email').textContent = formData.email;
        document.getElementById('summary-name').textContent = formData.fullName || '未填写';
        document.getElementById('summary-phone').textContent = formData.phone || '未填写';
        document.getElementById('summary-gender').textContent =
            formData.gender === 'MALE' ? '男' : formData.gender === 'FEMALE' ? '女' : '其他';
        document.getElementById('summary-birthdate').textContent = formData.birthDate || '未填写';
    }

    // 检查用户名可用性
    async function checkUsernameAvailability() {
        const username = document.getElementById('username').value;
        const feedback = document.getElementById('username-feedback');

        if (username.length < 3) {
            return false;
        }

        try {
            // 调用后端API检查用户名是否可用
            const response = await fetch(`/api/auth/check-username?username=${encodeURIComponent(username)}`);

            if (response.ok) {
                const data = await response.json();

                if (data.available) {
                    showFieldSuccess('username', '✓ 用户名可用');
                    return true;
                } else {
                    showFieldError('username', '用户名已被使用');
                    return false;
                }
            }
        } catch (error) {
            console.error('检查用户名时出错:', error);
        }

        return false;
    }

    // 检查邮箱可用性
    async function checkEmailAvailability() {
        const email = document.getElementById('email').value;
        const feedback = document.getElementById('email-feedback');

        if (!validateEmail(email)) {
            return false;
        }

        try {
            // 调用后端API检查邮箱是否可用
            const response = await fetch(`/api/auth/check-email?email=${encodeURIComponent(email)}`);

            if (response.ok) {
                const data = await response.json();

                if (data.available) {
                    showFieldSuccess('email', '✓ 邮箱地址可用');
                    return true;
                } else {
                    showFieldError('email', '邮箱地址已被注册');
                    return false;
                }
            }
        } catch (error) {
            console.error('检查邮箱时出错:', error);
        }

        return false;
    }

    // 检查密码强度
    function checkPasswordStrength() {
        const password = document.getElementById('password').value;
        const strength = calculatePasswordStrength(password);
        const bar = document.getElementById('password-strength-bar');
        const text = document.getElementById('password-strength-text');

        // 更新进度条
        bar.className = 'password-strength-bar';

        switch(strength) {
            case 0:
                bar.classList.add('strength-weak');
                text.textContent = '弱';
                text.style.color = 'var(--danger-color)';
                break;
            case 1:
                bar.classList.add('strength-fair');
                text.textContent = '一般';
                text.style.color = 'var(--warning-color)';
                break;
            case 2:
                bar.classList.add('strength-good');
                text.textContent = '良好';
                text.style.color = '#4cd964';
                break;
            case 3:
                bar.classList.add('strength-strong');
                text.textContent = '强';
                text.style.color = 'var(--success-color)';
                break;
        }
    }

    // 计算密码强度
    function calculatePasswordStrength(password) {
        let strength = 0;

        // 长度检查
        if (password.length >= 8) strength++;
        if (password.length >= 12) strength++;

        // 复杂度检查
        if (/[a-z]/.test(password)) strength++;
        if (/[A-Z]/.test(password)) strength++;
        if (/[0-9]/.test(password)) strength++;
        if (/[^a-zA-Z0-9]/.test(password)) strength++;

        // 限制最大强度为3
        return Math.min(3, Math.floor(strength / 2));
    }

    // 验证密码匹配
    function validatePasswordMatch() {
        const password = document.getElementById('password').value;
        const confirm = document.getElementById('confirmPassword').value;
        const feedback = document.getElementById('confirm-feedback');

        if (confirm.length === 0) {
            feedback.innerHTML = '';
            return;
        }

        if (password === confirm) {
            showFieldSuccess('confirmPassword', '✓ 密码匹配');
            return true;
        } else {
            showFieldError('confirmPassword', '两次输入的密码不一致');
            return false;
        }
    }

    // 更新个人简介字数统计
    function updateBioCounter() {
        const bio = document.getElementById('bio').value;
        document.getElementById('bio-counter').textContent = bio.length;
    }

    // 处理头像上传
    function handleAvatarUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

        // 验证文件类型
        if (!file.type.match('image.*')) {
            showToast('请选择图片文件', 'warning');
            return;
        }

        // 验证文件大小（限制2MB）
        if (file.size > 2 * 1024 * 1024) {
            showToast('图片大小不能超过2MB', 'warning');
            return;
        }

        // 显示上传进度
        const progressBar = document.querySelector('#uploadProgress .progress-bar');
        const progressContainer = document.getElementById('uploadProgress');
        progressContainer.style.display = 'block';

        // 模拟上传过程（实际项目中应该使用FormData上传到服务器）
        let progress = 0;
        const interval = setInterval(() => {
            progress += 10;
            progressBar.style.width = `${progress}%`;

            if (progress >= 100) {
                clearInterval(interval);
                progressContainer.style.display = 'none';

                // 预览图片
                const reader = new FileReader();
                reader.onload = function(e) {
                    const avatarImage = document.getElementById('avatarImage');
                    avatarImage.src = e.target.result;
                    avatarImage.style.display = 'block';
                    document.querySelector('#avatarPreview i').style.display = 'none';
                    formData.avatar = e.target.result;

                    showToast('头像上传成功', 'success');
                };
                reader.readAsDataURL(file);
            }
        }, 100);
    }

    // 提交注册
    async function submitRegistration() {
        const submitBtn = document.getElementById('submit-register');
        const originalText = submitBtn.innerHTML;

        // 显示加载状态
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>注册中...';

        try {
            // 准备提交数据
            const registrationData = {
                username: formData.username,
                email: formData.email,
                password: formData.password,
                fullName: formData.fullName,
                phone: formData.phone,
                gender: formData.gender,
                birthDate: formData.birthDate,
                bio: formData.bio
            };

            // 发送注册请求
            const response = await fetch('/api/auth/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(registrationData)
            });

            if (response.ok) {
                const data = await response.json();

                if (data.success) {
                    showToast('注册成功！正在跳转到登录页面...', 'success');

                    // 3秒后跳转到登录页面
                    setTimeout(() => {
                        window.location.href = '/login-page';
                    }, 3000);
                } else {
                    showToast(data.message || '注册失败', 'danger');
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                }
            } else {
                const error = await response.json();
                showToast(error.message || '注册请求失败', 'danger');
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            }
        } catch (error) {
            console.error('注册时出错:', error);
            showToast('网络错误，请稍后重试', 'danger');
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    }

    // 切换密码显示/隐藏
    function togglePasswordVisibility() {
        const passwordInput = document.getElementById('password');
        const toggleBtn = document.getElementById('togglePassword');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            toggleBtn.innerHTML = '<i class="fas fa-eye-slash"></i>';
        } else {
            passwordInput.type = 'password';
            toggleBtn.innerHTML = '<i class="fas fa-eye"></i>';
        }
    }

    // 跳转到指定步骤
    function goToStep(step) {
        // 更新步骤指示器
        document.querySelectorAll('.step').forEach((el, index) => {
            if (index + 1 < step) {
                el.classList.remove('active');
                el.classList.add('completed');
            } else if (index + 1 === step) {
                el.classList.add('active');
                el.classList.remove('completed');
            } else {
                el.classList.remove('active', 'completed');
            }
        });

        // 显示对应表单步骤
        document.querySelectorAll('.form-step').forEach((el, index) => {
            if (index + 1 === step) {
                el.classList.add('active');
            } else {
                el.classList.remove('active');
            }
        });

        currentStep = step;
    }

    // 显示字段错误
    function showFieldError(fieldId, message) {
        const field = document.getElementById(fieldId);
        const feedback = document.getElementById(`${fieldId}-feedback`);

        field.classList.remove('is-valid');
        field.classList.add('is-invalid');

        if (feedback) {
            feedback.innerHTML = `<i class="fas fa-times-circle"></i> ${message}`;
            feedback.className = 'feedback invalid-feedback';
        }
    }

    // 显示字段成功
    function showFieldSuccess(fieldId, message) {
        const field = document.getElementById(fieldId);
        const feedback = document.getElementById(`${fieldId}-feedback`);

        field.classList.remove('is-invalid');
        field.classList.add('is-valid');

        if (feedback) {
            feedback.innerHTML = `<i class="fas fa-check-circle"></i> ${message}`;
            feedback.className = 'feedback valid-feedback';
        }
    }

    // 显示Toast消息
    function showToast(message, type = 'info') {
        const toastContainer = document.querySelector('.toast-container');
        const toastId = 'toast-' + Date.now();

        const toast = document.createElement('div');
        toast.className = `toast show`;
        toast.setAttribute('role', 'alert');
        toast.id = toastId;

        const bgClass = type === 'success' ? 'bg-success' :
            type === 'warning' ? 'bg-warning' :
                type === 'danger' ? 'bg-danger' : 'bg-info';

        const icon = type === 'success' ? 'fa-check-circle' :
            type === 'warning' ? 'fa-exclamation-triangle' :
                type === 'danger' ? 'fa-times-circle' : 'fa-info-circle';

        toast.innerHTML = `
                <div class="toast-header ${bgClass} text-white">
                    <i class="fas ${icon} me-2"></i>
                    <strong class="me-auto">系统消息</strong>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
                </div>
                <div class="toast-body">
                    ${message}
                </div>
            `;

        toastContainer.appendChild(toast);

        // 5秒后自动移除
        setTimeout(() => {
            const toastEl = document.getElementById(toastId);
            if (toastEl) {
                toastEl.remove();
            }
        }, 5000);
    }

    // 验证用户名格式
    function validateUsername(username) {
        const pattern = /^[a-zA-Z0-9_]{3,20}$/;
        return pattern.test(username);
    }

    // 验证邮箱格式
    function validateEmail(email) {
        const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return pattern.test(email);
    }
</script>
</body>
</html>