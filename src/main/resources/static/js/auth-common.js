// auth-common.js - 认证相关通用方法
const AuthCommon = {

    // ================ 配置 ================
    config: {
        apiBase: '/api/auth',
        minPasswordLength: 6,
        maxPasswordLength: 50,
        minUsernameLength: 3,
        maxUsernameLength: 20
    },

    // ================ 表单验证方法 ================

    /**
     * 验证用户名格式
     * @param {string} username - 用户名
     * @returns {boolean} 是否有效
     */
    validateUsername(username) {
        if (!username || username.trim().length === 0) {
            return { valid: false, message: '用户名不能为空' };
        }

        const trimmed = username.trim();
        if (trimmed.length < this.config.minUsernameLength) {
            return {
                valid: false,
                message: `用户名至少${this.config.minUsernameLength}个字符`
            };
        }

        if (trimmed.length > this.config.maxUsernameLength) {
            return {
                valid: false,
                message: `用户名最多${this.config.maxUsernameLength}个字符`
            };
        }

        // 只允许字母、数字、下划线
        const pattern = /^[a-zA-Z0-9_]+$/;
        if (!pattern.test(trimmed)) {
            return {
                valid: false,
                message: '用户名只能包含字母、数字和下划线'
            };
        }

        return { valid: true, message: '用户名格式正确' };
    },

    /**
     * 验证邮箱格式
     * @param {string} email - 邮箱地址
     * @returns {boolean} 是否有效
     */
    validateEmail(email) {
        if (!email || email.trim().length === 0) {
            return { valid: false, message: '邮箱不能为空' };
        }

        const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!pattern.test(email.trim())) {
            return { valid: false, message: '邮箱格式不正确' };
        }

        return { valid: true, message: '邮箱格式正确' };
    },

    /**
     * 验证密码强度
     * @param {string} password - 密码
     * @returns {object} 验证结果和强度等级
     */
    validatePassword(password) {
        if (!password || password.length === 0) {
            return {
                valid: false,
                message: '密码不能为空',
                strength: 0
            };
        }

        if (password.length < this.config.minPasswordLength) {
            return {
                valid: false,
                message: `密码至少${this.config.minPasswordLength}位`,
                strength: 0
            };
        }

        if (password.length > this.config.maxPasswordLength) {
            return {
                valid: false,
                message: `密码最多${this.config.maxPasswordLength}位`,
                strength: 0
            };
        }

        // 计算密码强度
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
        const finalStrength = Math.min(3, Math.floor(strength / 2));

        const strengthText = ['弱', '一般', '良好', '强'][finalStrength];
        const strengthColor = [
            'var(--danger-color)',
            'var(--warning-color)',
            '#4cd964',
            'var(--success-color)'
        ][finalStrength];

        return {
            valid: true,
            message: `密码强度：${strengthText}`,
            strength: finalStrength,
            strengthText,
            strengthColor
        };
    },

    /**
     * 验证密码匹配
     * @param {string} password - 密码
     * @param {string} confirmPassword - 确认密码
     * @returns {object} 验证结果
     */
    validatePasswordMatch(password, confirmPassword) {
        if (!confirmPassword || confirmPassword.length === 0) {
            return { valid: false, message: '请确认密码' };
        }

        if (password !== confirmPassword) {
            return { valid: false, message: '两次输入的密码不一致' };
        }

        return { valid: true, message: '密码匹配' };
    },

    // ================ API调用方法 ================

    /**
     * 检查用户名是否可用
     * @param {string} username - 用户名
     * @returns {Promise<boolean>} 是否可用
     */
    async checkUsernameAvailability(username) {
        try {
            const response = await fetch(
                `${this.config.apiBase}/check-username?username=${encodeURIComponent(username)}`
            );

            if (response.ok) {
                const data = await response.json();
                return data.available;
            }
            return null; // API错误时返回null
        } catch (error) {
            console.error('检查用户名时出错:', error);
            return null;
        }
    },

    /**
     * 检查邮箱是否可用
     * @param {string} email - 邮箱地址
     * @returns {Promise<boolean>} 是否可用
     */
    async checkEmailAvailability(email) {
        try {
            const response = await fetch(
                `${this.config.apiBase}/check-email?email=${encodeURIComponent(email)}`
            );

            if (response.ok) {
                const data = await response.json();
                return data.available;
            }
            return null;
        } catch (error) {
            console.error('检查邮箱时出错:', error);
            return null;
        }
    },

    /**
     * 用户登录
     * @param {string} username - 用户名
     * @param {string} password - 密码
     * @param {boolean} rememberMe - 是否记住我
     * @returns {Promise<object>} 登录结果
     */
    async login(username, password, rememberMe = false) {
        try {
            const response = await FinanceUtils.http.post(`${this.config.apiBase}/login`, {
                username,
                password,
                rememberMe
            });

            return response;
        } catch (error) {
            console.error('登录时出错:', error);
            throw error;
        }
    },

    /**
     * 用户注册
     * @param {object} userData - 用户数据
     * @returns {Promise<object>} 注册结果
     */
    async register(userData) {
        try {
            const response = await FinanceUtils.http.post(`${this.config.apiBase}/register`, userData);
            return response;
        } catch (error) {
            console.error('注册时出错:', error);
            throw error;
        }
    },

    // ================ UI辅助方法 ================

    /**
     * 显示字段验证结果
     * @param {string} fieldId - 字段ID
     * @param {boolean} isValid - 是否有效
     * @param {string} message - 消息内容
     */
    showFieldValidation(fieldId, isValid, message) {
        const field = document.getElementById(fieldId);
        const feedback = document.getElementById(`${fieldId}-feedback`);

        if (!field) return;

        // 更新字段样式
        field.classList.remove('is-valid', 'is-invalid');
        field.classList.add(isValid ? 'is-valid' : 'is-invalid');

        // 更新反馈消息
        if (feedback) {
            const icon = isValid ? 'fa-check-circle' : 'fa-times-circle';
            const className = isValid ? 'valid-feedback' : 'invalid-feedback';

            feedback.innerHTML = `<i class="fas ${icon}"></i> ${message}`;
            feedback.className = `feedback ${className}`;
            feedback.style.display = 'block';
        }
    },

    /**
     * 清除字段验证状态
     * @param {string} fieldId - 字段ID
     */
    clearFieldValidation(fieldId) {
        const field = document.getElementById(fieldId);
        const feedback = document.getElementById(`${fieldId}-feedback`);

        if (field) {
            field.classList.remove('is-valid', 'is-invalid');
        }

        if (feedback) {
            feedback.innerHTML = '';
            feedback.style.display = 'none';
        }
    },

    /**
     * 更新密码强度显示
     * @param {string} password - 密码
     * @param {string} barId - 进度条元素ID
     * @param {string} textId - 文本显示元素ID
     */
    updatePasswordStrengthDisplay(password, barId, textId) {
        const result = this.validatePassword(password);
        const bar = document.getElementById(barId);
        const text = document.getElementById(textId);

        if (bar && text) {
            // 更新进度条
            bar.className = 'password-strength-bar';
            bar.style.width = `${(result.strength + 1) * 25}%`;
            bar.style.backgroundColor = result.strengthColor;

            // 更新文本
            text.textContent = result.message;
            text.style.color = result.strengthColor;
        }

        return result;
    },

    /**
     * 切换密码显示/隐藏
     * @param {string} passwordFieldId - 密码字段ID
     * @param {string} toggleButtonId - 切换按钮ID
     */
    togglePasswordVisibility(passwordFieldId, toggleButtonId) {
        const passwordInput = document.getElementById(passwordFieldId);
        const toggleBtn = document.getElementById(toggleButtonId);

        if (!passwordInput || !toggleBtn) return;

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            toggleBtn.innerHTML = '<i class="fas fa-eye-slash"></i>';
        } else {
            passwordInput.type = 'password';
            toggleBtn.innerHTML = '<i class="fas fa-eye"></i>';
        }
    },

    /**
     * 初始化表单实时验证
     * @param {object} fields - 字段配置 {fieldId: validationType}
     * @param {object} callbacks - 验证回调函数
     */
    initRealTimeValidation(fields, callbacks = {}) {
        Object.entries(fields).forEach(([fieldId, validationType]) => {
            const field = document.getElementById(fieldId);
            if (!field) return;

            field.addEventListener('blur', () => {
                const value = field.value.trim();

                switch (validationType) {
                    case 'username':
                        const usernameResult = this.validateUsername(value);
                        this.showFieldValidation(fieldId, usernameResult.valid, usernameResult.message);

                        // 如果格式正确，检查可用性
                        if (usernameResult.valid && callbacks.onUsernameCheck) {
                            callbacks.onUsernameCheck(value);
                        }
                        break;

                    case 'email':
                        const emailResult = this.validateEmail(value);
                        this.showFieldValidation(fieldId, emailResult.valid, emailResult.message);

                        if (emailResult.valid && callbacks.onEmailCheck) {
                            callbacks.onEmailCheck(value);
                        }
                        break;

                    case 'password':
                        const passwordResult = this.validatePassword(value);
                        this.showFieldValidation(fieldId, passwordResult.valid, passwordResult.message);

                        if (callbacks.onPasswordStrengthUpdate) {
                            callbacks.onPasswordStrengthUpdate(value);
                        }
                        break;
                }
            });

            // 清除验证状态
            field.addEventListener('input', () => {
                this.clearFieldValidation(fieldId);
            });
        });
    }
};

// 全局可用
window.AuthCommon = AuthCommon;