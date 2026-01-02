// register.js - 注册页面专用逻辑
class RegisterPage {
    constructor() {
        this.currentStep = 1;
        this.formData = {
            username: '',
            email: '',
            password: '',
            fullName: '',
            phone: '',
            gender: 'MALE',
            birthDate: '',
            bio: ''
        };
        this.init();
    }

    init() {
        this.bindEvents();
        this.initRealTimeValidation();
        FinanceUtils.init();
    }

    bindEvents() {
        // 步骤导航
        document.getElementById('next-step-1')?.addEventListener('click', () => this.validateStep1());
        document.getElementById('prev-step-2')?.addEventListener('click', () => this.goToStep(1));
        document.getElementById('next-step-2')?.addEventListener('click', () => this.validateStep2());
        document.getElementById('prev-step-3')?.addEventListener('click', () => this.goToStep(2));
        document.getElementById('submit-register')?.addEventListener('click', () => this.submitRegistration());

        // 密码切换
        document.getElementById('togglePassword')?.addEventListener('click', () => {
            AuthCommon.togglePasswordVisibility('password', 'togglePassword');
        });
    }

    initRealTimeValidation() {
        AuthCommon.initRealTimeValidation({
            username: 'username',
            email: 'email',
            password: 'password'
        }, {
            onUsernameCheck: (username) => this.checkUsernameAvailability(username),
            onEmailCheck: (email) => this.checkEmailAvailability(email),
            onPasswordStrengthUpdate: (password) => {
                AuthCommon.updatePasswordStrengthDisplay(
                    password,
                    'password-strength-bar',
                    'password-strength-text'
                );
            }
        });

        // 确认密码实时验证
        document.getElementById('confirmPassword')?.addEventListener('input', () => {
            const password = document.getElementById('password').value;
            const confirm = document.getElementById('confirmPassword').value;

            if (confirm) {
                const result = AuthCommon.validatePasswordMatch(password, confirm);
                AuthCommon.showFieldValidation('confirmPassword', result.valid, result.message);
            } else {
                AuthCommon.clearFieldValidation('confirmPassword');
            }
        });
    }

    // 步骤切换
    goToStep(step) {
        if (step < 1 || step > 3) return;
        this.currentStep = step;

        // 更新步骤指示器
        document.querySelectorAll('.step').forEach((el, index) => {
            const stepNum = parseInt(el.dataset.step);
            if (stepNum < step) {
                el.classList.remove('active');
                el.classList.add('completed');
            } else if (stepNum === step) {
                el.classList.add('active');
                el.classList.remove('completed');
            } else {
                el.classList.remove('active', 'completed');
            }
        });

        // 显示对应表单步骤
        document.querySelectorAll('.form-step').forEach((el, index) => {
            const stepNum = parseInt(el.dataset.step);
            el.classList.toggle('active', stepNum === step);
        });

        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // 步骤1验证
    async validateStep1() {
        const username = document.getElementById('username').value.trim();
        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        let isValid = true;

        // 验证用户名
        const usernameResult = AuthCommon.validateUsername(username);
        if (!usernameResult.valid) {
            AuthCommon.showFieldValidation('username', false, usernameResult.message);
            isValid = false;
        } else {
            // 检查用户名可用性
            const available = await AuthCommon.checkUsernameAvailability(username);
            if (available === false) {
                AuthCommon.showFieldValidation('username', false, '用户名已被使用');
                isValid = false;
            } else if (available === true) {
                AuthCommon.showFieldValidation('username', true, '用户名可用');
            }
        }

        // 验证邮箱
        const emailResult = AuthCommon.validateEmail(email);
        if (!emailResult.valid) {
            AuthCommon.showFieldValidation('email', false, emailResult.message);
            isValid = false;
        } else {
            // 检查邮箱可用性
            const available = await AuthCommon.checkEmailAvailability(email);
            if (available === false) {
                AuthCommon.showFieldValidation('email', false, '邮箱已被注册');
                isValid = false;
            } else if (available === true) {
                AuthCommon.showFieldValidation('email', true, '邮箱可用');
            }
        }

        // 验证密码
        const passwordResult = AuthCommon.validatePassword(password);
        if (!passwordResult.valid) {
            AuthCommon.showFieldValidation('password', false, passwordResult.message);
            isValid = false;
        }

        // 验证密码匹配
        const matchResult = AuthCommon.validatePasswordMatch(password, confirmPassword);
        if (!matchResult.valid) {
            AuthCommon.showFieldValidation('confirmPassword', false, matchResult.message);
            isValid = false;
        }

        if (isValid) {
            this.collectStep1Data();
            this.goToStep(2);
        }
    }

    collectStep1Data() {
        this.formData.username = document.getElementById('username').value.trim();
        this.formData.email = document.getElementById('email').value.trim();
        this.formData.password = document.getElementById('password').value;
    }

    // 步骤2验证
    validateStep2() {
        this.collectStep2Data();

        // 检查条款是否同意
        if (!document.getElementById('terms')?.checked) {
            FinanceUtils.toast.warning('请阅读并同意用户服务协议和隐私政策');
            return;
        }

        this.updateSummary();
        this.goToStep(3);
    }

    collectStep2Data() {
        this.formData.fullName = document.getElementById('fullName')?.value.trim() || '';
        this.formData.phone = document.getElementById('phone')?.value.trim() || '';
        this.formData.gender = document.querySelector('input[name="gender"]:checked')?.value || 'MALE';
        this.formData.birthDate = document.getElementById('birthDate')?.value || '';
        this.formData.bio = document.getElementById('bio')?.value.trim() || '';
    }

    updateSummary() {
        const elements = {
            'summary-username': this.formData.username,
            'summary-email': this.formData.email,
            'summary-name': this.formData.fullName || '未填写',
            'summary-phone': this.formData.phone || '未填写',
            'summary-birthdate': this.formData.birthDate || '未填写'
        };

        Object.entries(elements).forEach(([id, value]) => {
            const element = document.getElementById(id);
            if (element) element.textContent = value;
        });

        const genderElement = document.getElementById('summary-gender');
        if (genderElement) {
            const genderText = { 'MALE': '男', 'FEMALE': '女', 'OTHER': '其他' };
            genderElement.textContent = genderText[this.formData.gender] || '未填写';
        }
    }

    // 提交注册
    async submitRegistration() {
        const submitBtn = document.getElementById('submit-register');
        const originalText = submitBtn?.innerHTML;

        try {
            // 显示加载状态
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>注册中...';
            }

            // 提交注册
            const response = await AuthCommon.register(this.formData);

            if (response.success) {
                FinanceUtils.toast.success('注册成功！正在跳转到登录页面...');

                // 3秒后跳转到登录页面
                setTimeout(() => {
                    window.location.href = '/login-page';
                }, 3000);
            } else {
                FinanceUtils.toast.error(response.message || '注册失败');
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                }
            }
        } catch (error) {
            console.error('注册时出错:', error);
            FinanceUtils.toast.error('网络错误，请稍后重试');
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            }
        }
    }

    // 辅助方法
    async checkUsernameAvailability(username) {
        const available = await AuthCommon.checkUsernameAvailability(username);
        return available;
    }

    async checkEmailAvailability(email) {
        const available = await AuthCommon.checkEmailAvailability(email);
        return available;
    }
}

// 页面初始化
document.addEventListener('DOMContentLoaded', () => {
    if (document.querySelector('.register-page')) {
        window.registerPage = new RegisterPage();
        console.log('RegisterPage 初始化完成');
    }
});