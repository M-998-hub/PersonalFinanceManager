package demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AuthViewController {

    /**
     * 首页重定向到登录页面
     */
    @GetMapping("/")
    public String home() {
        return "redirect:/login-page"; // 改为不同路径
    }

    /**
     * 显示登录页面（与LoginController的API登录路径区分开）
     */
    @GetMapping("/login-page")
    public String showLoginPage() {
        return "pages/user_login"; // 只返回视图，不处理逻辑
    }

    /**
     * 显示注册页面
     */
    @GetMapping("/register-page")
    public String showRegisterPage() {
        return "pages/user_register"; // 只返回视图
    }

    /**
     * 显示Dashboard页面（需要认证）
     */
/*
    @GetMapping("/dashboard-page")
    public String showDashboardPage() {
        return "pages/dashboard"; // 对应你的dashboard.jsp
    }
*/
}