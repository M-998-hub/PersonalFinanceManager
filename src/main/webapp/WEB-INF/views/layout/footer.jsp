<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>



<!-- 通用工具函数 -->
<script>
    // 显示消息提示
    function showAlert(message, type = 'info') {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;

        // 添加到页面顶部
        document.querySelector('.container-fluid').prepend(alertDiv);

        // 5秒后自动消失
        setTimeout(() => {
            alertDiv.remove();
        }, 5000);
    }

    // 格式化金额
    function formatCurrency(amount) {
        return '¥ ' + parseFloat(amount).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    }

    // 检查登录状态
    async function checkLoginStatus() {
        try {
            const response = await fetch('/api/auth/current');
            return response.ok;
        } catch (error) {
            return false;
        }
    }
</script>

<footer class="mt-5 py-3 text-center text-muted border-top">
    <div class="container">
        <p class="mb-1">© 2024 个人经济管理系统. 一个帮助您管理财务的简单工具.</p>
        <p class="mb-0">
            <a href="#" class="text-muted me-3">关于我们</a>
            <a href="#" class="text-muted me-3">隐私政策</a>
            <a href="#" class="text-muted">帮助中心</a>
        </p>
    </div>
</footer>