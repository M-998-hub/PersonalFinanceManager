// login.js - 登录页面专用逻辑
class LoginPage {
    constructor() {
        this.loginAttempts = 0;
        this.maxAttempts = 5;
        this.init();
    }

    init() {
        this.bindEvents();
        this.initFormValidation();
        this.restoreRememberedUser();
        FinanceUtils.init();
    }

    bindEvents() {
        // 表单提交
        document.getElementById('loginForm')?.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        // 密码切换
        document.getElementById('togglePassword')?.addEventListener('click', () => {
            AuthCommon.togglePasswordVisibility('password', 'togglePassword');
        });

        // 记住我状态变化
        document.getElementById('rememberMe')?.addEventListener('change', (e) => {
            this.handleRememberMeChange(e.target.checked);
        });

        // 忘记密码
        document.getElementById('forgotPassword')?.addEventListener('click', (e) => {
            e.preventDefault();
            this.handleForgotPassword();
        });
    }

    initFormValidation() {
        // 用户名实时验证
        document.getElementById('username')?.addEventListener('blur', () => {
            const username = document.getElementById('username').value.trim();
            const result = AuthCommon.validateUsername(username);
            AuthCommon.showFieldValidation('username', result.valid, result.message);
        });

        // 密码实时验证
        document.getElementById('password')?.addEventListener('input', () => {
            const password = document.getElementById('password').value;
            AuthCommon.updatePasswordStrengthDisplay(
                password,
                'password-strength-bar',
                'password-strength-text'
            );
        });
    }

    // 恢复记住的用户名
    restoreRememberedUser() {
        const rememberedUsername = localStorage.getItem('remembered_username');
        const rememberMeChecked = localStorage.getItem('remember_me') === 'true';

        if (rememberedUsername) {
            document.getElementById('username').value = rememberedUsername;
            if (document.getElementById('rememberMe')) {
                document.getElementById('rememberMe').checked = rememberMeChecked;
            }
        }
    }

    // 处理记住我
    handleRememberMeChange(checked) {
        const username = document.getElementById('username').value.trim();

        if (checked && username) {
            localStorage.setItem('remembered_username', username);
            localStorage.setItem('remember_me', 'true');
        } else {
            localStorage.removeItem('remembered_username');
            localStorage.removeItem('remember_me');
        }
    }

    // 处理登录
    async handleLogin() {
        // 检查登录尝试次数
        if (this.loginAttempts >= this.maxAttempts) {
            FinanceUtils.toast.error('登录尝试次数过多，请稍后再试');
            return;
        }

        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value;
        const rememberMe = document.getElementById('rememberMe')?.checked || false;

        // 基本验证
        const usernameResult = AuthCommon.validateUsername(username);
        if (!usernameResult.valid) {
            AuthCommon.showFieldValidation('username', false, usernameResult.message);
            return;
        }

        const passwordResult = AuthCommon.validatePassword(password);
        if (!passwordResult.valid) {
            AuthCommon.showFieldValidation('password', false, passwordResult.message);
            return;
        }

        // 显示加载状态
        const submitBtn = document.querySelector('#loginForm button[type="submit"]');
        const originalText = submitBtn?.innerHTML;

        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>登录中...';
        }

        try {
            // 调用登录API
            const response = await AuthCommon.login(username, password, rememberMe);

            if (response.success) {
                this.loginAttempts = 0; // 重置尝试次数

                // 如果记住我，保存用户名
                if (rememberMe) {
                    localStorage.setItem('remembered_username', username);
                    localStorage.setItem('remember_me', 'true');
                }

                FinanceUtils.toast.success('登录成功！正在跳转...');

                // 延迟跳转，让用户看到成功消息
                setTimeout(() => {
                    // 跳转到登录前页面或默认页面
                    const redirectUrl = response.redirectUrl || '/dashboard-page';
                    window.location.href = redirectUrl;
                }, 1500);

            } else {
                this.loginAttempts++;
                FinanceUtils.toast.error(response.message || '登录失败');

                // 更新UI显示错误
                AuthCommon.showFieldValidation('username', false, '用户名或密码错误');
                AuthCommon.showFieldValidation('password', false, '用户名或密码错误');

                // 重新启用按钮
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                }
            }

        } catch (error) {
            this.loginAttempts++;
            console.error('登录时出错:', error);
            FinanceUtils.toast.error('网络错误，请稍后重试');

            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            }
        }
    }

    // 处理忘记密码
    handleForgotPassword() {
        FinanceUtils.toast.info('忘记密码功能开发中...');
        // TODO: 实现忘记密码流程
    }
}

// 页面初始化
document.addEventListener('DOMContentLoaded', () => {
    if (document.querySelector('.login-page')) {
        window.loginPage = new LoginPage();
        console.log('LoginPage 初始化完成');
    }
});