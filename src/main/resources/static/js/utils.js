// ===== 全局工具库 =====
const FinanceUtils = {
    // 配置
    config: {
        apiBaseUrl: '',
        toastDuration: 5000,
        debounceDelay: 300
    },

    // ===== 消息通知系统 =====
    toast: {
        container: null,

        init() {
            if (!this.container) {
                this.container = document.createElement('div');
                this.container.className = 'toast-container';
                document.body.appendChild(this.container);
            }
        },

        show(message, type = 'info', duration = FinanceUtils.config.toastDuration) {
            this.init();

            const toastId = 'toast-' + Date.now();
            const bgClass = this.getToastBgClass(type);
            const icon = this.getToastIcon(type);

            const toast = document.createElement('div');
            toast.className = `toast show fade-in`;
            toast.setAttribute('role', 'alert');
            toast.id = toastId;

            toast.innerHTML = `
                <div class="toast-header ${bgClass} text-white">
                    <i class="fas ${icon} me-2"></i>
                    <strong class="me-auto">系统消息</strong>
                    <button type="button" class="btn-close btn-close-white" onclick="FinanceUtils.toast.hide('${toastId}')"></button>
                </div>
                <div class="toast-body">
                    ${message}
                </div>
            `;

            this.container.appendChild(toast);

            if (duration > 0) {
                setTimeout(() => {
                    this.hide(toastId);
                }, duration);
            }

            return toastId;
        },

        hide(toastId) {
            const toast = document.getElementById(toastId);
            if (toast) {
                toast.classList.remove('show');
                toast.classList.add('fade');
                setTimeout(() => toast.remove(), 300);
            }
        },

        success(message, duration) {
            return this.show(message, 'success', duration);
        },

        error(message, duration) {
            return this.show(message, 'danger', duration);
        },

        warning(message, duration) {
            return this.show(message, 'warning', duration);
        },

        info(message, duration) {
            return this.show(message, 'info', duration);
        },

        getToastBgClass(type) {
            const classes = {
                'success': 'bg-success',
                'danger': 'bg-danger',
                'warning': 'bg-warning',
                'info': 'bg-info'
            };
            return classes[type] || 'bg-info';
        },

        getToastIcon(type) {
            const icons = {
                'success': 'fa-check-circle',
                'danger': 'fa-times-circle',
                'warning': 'fa-exclamation-triangle',
                'info': 'fa-info-circle'
            };
            return icons[type] || 'fa-info-circle';
        }
    },

    // ===== 表单验证工具 =====
    validation: {
        patterns: {
            username: /^[a-zA-Z0-9_]{3,20}$/,
            email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
            phone: /^1[3-9]\d{9}$/,
            password: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
            amount: /^\d+(\.\d{1,2})?$/,
            date: /^\d{4}-\d{2}-\d{2}$/
        },

        validateField(field, type, customPattern = null) {
            const value = field.value.trim();
            const pattern = customPattern || this.patterns[type];

            if (!pattern) {
                console.warn(`未定义的验证类型: ${type}`);
                return true;
            }

            if (value === '') {
                return field.required ? false : true;
            }

            return pattern.test(value);
        },

        validateForm(formElement) {
            let isValid = true;
            const fields = formElement.querySelectorAll('[data-validation]');

            fields.forEach(field => {
                const validationType = field.getAttribute('data-validation');
                if (!this.validateField(field, validationType)) {
                    this.showFieldError(field, this.getErrorMessage(validationType));
                    isValid = false;
                } else {
                    this.clearFieldError(field);
                }
            });

            return isValid;
        },

        showFieldError(field, message) {
            field.classList.add('is-invalid');

            let feedback = field.nextElementSibling;
            if (!feedback || !feedback.classList.contains('feedback')) {
                feedback = document.createElement('div');
                feedback.className = 'feedback invalid-feedback';
                field.parentNode.insertBefore(feedback, field.nextSibling);
            }

            feedback.innerHTML = `<i class="fas fa-times-circle"></i> ${message}`;
        },

        clearFieldError(field) {
            field.classList.remove('is-invalid');
            field.classList.add('is-valid');

            let feedback = field.nextElementSibling;
            if (feedback && feedback.classList.contains('feedback')) {
                feedback.remove();
            }
        },

        getErrorMessage(type) {
            const messages = {
                'username': '用户名格式不正确（3-20位字母、数字或下划线）',
                'email': '请输入有效的邮箱地址',
                'phone': '请输入有效的手机号码',
                'password': '密码必须包含大小写字母、数字和特殊字符，至少8位',
                'amount': '请输入有效的金额格式（如：100.00）',
                'date': '请输入有效的日期格式（YYYY-MM-DD）'
            };
            return messages[type] || '输入格式不正确';
        },

        // 实时验证
        setupRealTimeValidation(formElement) {
            const fields = formElement.querySelectorAll('[data-validation]');

            fields.forEach(field => {
                field.addEventListener('blur', () => {
                    const type = field.getAttribute('data-validation');
                    if (!this.validateField(field, type)) {
                        this.showFieldError(field, this.getErrorMessage(type));
                    } else {
                        this.clearFieldError(field);
                    }
                });

                field.addEventListener('input', () => {
                    field.classList.remove('is-invalid', 'is-valid');
                    const feedback = field.nextElementSibling;
                    if (feedback && feedback.classList.contains('feedback')) {
                        feedback.remove();
                    }
                });
            });
        },

        // 密码强度检查
        checkPasswordStrength(password) {
            let strength = 0;

            if (password.length >= 8) strength++;
            if (password.length >= 12) strength++;

            if (/[a-z]/.test(password)) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^a-zA-Z0-9]/.test(password)) strength++;

            const levels = [
                { level: 0, text: '弱', class: 'strength-weak', color: 'var(--danger-color)' },
                { level: 1, text: '一般', class: 'strength-fair', color: 'var(--warning-color)' },
                { level: 2, text: '良好', class: 'strength-good', color: '#4cd964' },
                { level: 3, text: '强', class: 'strength-strong', color: 'var(--success-color)' }
            ];

            const strengthLevel = Math.min(3, Math.floor(strength / 2));
            return levels.find(level => level.level === strengthLevel) || levels[0];
        }
    },

    // ===== 加载状态管理 =====
    loading: {
        show(element, text = '加载中...') {
            const originalContent = element.innerHTML;
            element.dataset.originalContent = originalContent;
            element.disabled = true;

            element.innerHTML = `
                <span class="spinner-border spinner-border-sm me-2" role="status"></span>
                ${text}
            `;
        },

        hide(element) {
            if (element.dataset.originalContent) {
                element.innerHTML = element.dataset.originalContent;
                delete element.dataset.originalContent;
            }
            element.disabled = false;
        },

        showOverlay(container, message = '加载中...') {
            const overlayId = 'loading-overlay-' + Date.now();
            const overlay = document.createElement('div');
            overlay.id = overlayId;
            overlay.className = 'loading-overlay';
            overlay.innerHTML = `
                <div class="loading-content">
                    <div class="spinner-border text-primary mb-3" style="width: 3rem; height: 3rem;"></div>
                    <p class="loading-message">${message}</p>
                </div>
            `;

            // 添加样式
            if (!document.querySelector('#loading-overlay-style')) {
                const style = document.createElement('style');
                style.id = 'loading-overlay-style';
                style.textContent = `
                    .loading-overlay {
                        position: fixed;
                        top: 0;
                        left: 0;
                        right: 0;
                        bottom: 0;
                        background: rgba(255, 255, 255, 0.9);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        z-index: 9999;
                    }
                    .loading-content {
                        text-align: center;
                    }
                    .loading-message {
                        color: var(--dark-color);
                        font-size: var(--font-size-lg);
                    }
                `;
                document.head.appendChild(style);
            }

            document.body.appendChild(overlay);
            return overlayId;
        },

        hideOverlay(overlayId) {
            const overlay = document.getElementById(overlayId);
            if (overlay) {
                overlay.remove();
            }
        }
    },

    // ===== HTTP请求工具 =====
    http: {
        async get(url, options = {}) {
            return this.request('GET', url, null, options);
        },

        async post(url, data, options = {}) {
            return this.request('POST', url, data, options);
        },

        async put(url, data, options = {}) {
            return this.request('PUT', url, data, options);
        },

        async delete(url, options = {}) {
            return this.request('DELETE', url, null, options);
        },

        async request(method, url, data = null, options = {}) {
            const config = {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            };

            if (data && method !== 'GET') {
                config.body = JSON.stringify(data);
            }

            try {
                const response = await fetch(url, config);

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                const contentType = response.headers.get('content-type');
                if (contentType && contentType.includes('application/json')) {
                    return await response.json();
                } else {
                    return await response.text();
                }
            } catch (error) {
                console.error('HTTP请求失败:', error);
                FinanceUtils.toast.error(`请求失败: ${error.message}`);
                throw error;
            }
        },

        // 添加请求拦截器
        addInterceptor(interceptor) {
            const originalRequest = this.request;
            this.request = async function(...args) {
                if (interceptor.before) {
                    args = interceptor.before(...args) || args;
                }

                try {
                    const result = await originalRequest.apply(this, args);

                    if (interceptor.after) {
                        return interceptor.after(result);
                    }

                    return result;
                } catch (error) {
                    if (interceptor.error) {
                        interceptor.error(error);
                    }
                    throw error;
                }
            };
        }
    },

    // ===== 格式化工具 =====
    format: {
        currency(amount, currency = '¥') {
            if (amount === null || amount === undefined) return `${currency}0.00`;

            const number = parseFloat(amount);
            if (isNaN(number)) return `${currency}0.00`;

            return `${currency}${number.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')}`;
        },

        date(dateString, format = 'yyyy-MM-dd') {
            if (!dateString) return '';

            const date = new Date(dateString);
            if (isNaN(date.getTime())) return dateString;

            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
            const seconds = String(date.getSeconds()).padStart(2, '0');

            return format
                .replace('yyyy', year)
                .replace('MM', month)
                .replace('dd', day)
                .replace('HH', hours)
                .replace('mm', minutes)
                .replace('ss', seconds);
        },

        timeAgo(dateString) {
            const date = new Date(dateString);
            const now = new Date();
            const diffInSeconds = Math.floor((now - date) / 1000);

            if (diffInSeconds < 60) return '刚刚';
            if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}分钟前`;
            if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}小时前`;
            if (diffInSeconds < 2592000) return `${Math.floor(diffInSeconds / 86400)}天前`;
            if (diffInSeconds < 31536000) return `${Math.floor(diffInSeconds / 2592000)}个月前`;
            return `${Math.floor(diffInSeconds / 31536000)}年前`;
        },

        truncate(text, maxLength = 100, suffix = '...') {
            if (!text || text.length <= maxLength) return text;
            return text.substring(0, maxLength) + suffix;
        }
    },

    // ===== 工具函数 =====
    utils: {
        debounce(func, wait = FinanceUtils.config.debounceDelay) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        },

        throttle(func, limit = 1000) {
            let inThrottle;
            return function(...args) {
                if (!inThrottle) {
                    func.apply(this, args);
                    inThrottle = true;
                    setTimeout(() => inThrottle = false, limit);
                }
            };
        },

        deepClone(obj) {
            return JSON.parse(JSON.stringify(obj));
        },

        isEmpty(value) {
            if (value === null || value === undefined) return true;
            if (typeof value === 'string') return value.trim() === '';
            if (Array.isArray(value)) return value.length === 0;
            if (typeof value === 'object') return Object.keys(value).length === 0;
            return false;
        },

        generateId(prefix = '') {
            return `${prefix}${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        },

        copyToClipboard(text) {
            return new Promise((resolve, reject) => {
                if (navigator.clipboard) {
                    navigator.clipboard.writeText(text).then(resolve).catch(reject);
                } else {
                    const textarea = document.createElement('textarea');
                    textarea.value = text;
                    textarea.style.position = 'fixed';
                    textarea.style.opacity = '0';
                    document.body.appendChild(textarea);
                    textarea.select();

                    try {
                        document.execCommand('copy');
                        resolve();
                    } catch (err) {
                        reject(err);
                    } finally {
                        document.body.removeChild(textarea);
                    }
                }
            });
        }
    },

    // ===== 本地存储工具 =====
    storage: {
        set(key, value) {
            try {
                const serialized = JSON.stringify(value);
                localStorage.setItem(key, serialized);
            } catch (error) {
                console.error('本地存储设置失败:', error);
            }
        },

        get(key, defaultValue = null) {
            try {
                const serialized = localStorage.getItem(key);
                return serialized ? JSON.parse(serialized) : defaultValue;
            } catch (error) {
                console.error('本地存储读取失败:', error);
                return defaultValue;
            }
        },

        remove(key) {
            try {
                localStorage.removeItem(key);
            } catch (error) {
                console.error('本地存储删除失败:', error);
            }
        },

        clear() {
            try {
                localStorage.clear();
            } catch (error) {
                console.error('本地存储清空失败:', error);
            }
        }
    },

    // ===== 初始化函数 =====
    init(config = {}) {
        // 合并配置
        this.config = { ...this.config, ...config };

        // 初始化消息容器
        this.toast.init();

        // 全局错误处理
        window.addEventListener('error', (event) => {
            console.error('全局错误:', event.error);
            this.toast.error('发生了一个错误，请刷新页面重试');
        });

        // 未捕获的Promise错误
        window.addEventListener('unhandledrejection', (event) => {
            console.error('未处理的Promise错误:', event.reason);
            this.toast.error('请求失败，请稍后重试');
        });

        console.log('FinanceUtils 初始化完成');
    }
};

// ===== 全局导出 =====
// 确保在全局作用域中可用
window.FinanceUtils = FinanceUtils;

// 自动初始化（可在页面中覆盖配置）
document.addEventListener('DOMContentLoaded', () => {
    FinanceUtils.init();
});