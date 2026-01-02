package demo.controller;

import demo.dto.LoginRequest;
import demo.dto.LoginResponse;
import demo.entity.User;
import demo.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class LoginController {

    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;
    private final PasswordEncoder passwordEncoder;

    /**
     * 登录API
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request,
                                               HttpServletRequest servletRequest) {
        LoginResponse response = new LoginResponse();

        try {
            // 1. 使用Spring Security进行认证
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getUsername(),
                            request.getPassword()
                    )
            );

            // 2. 设置SecurityContext
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // 3. 获取用户信息
            User user = userRepository.findByUsername(request.getUsername())
                    .orElseThrow(() -> new RuntimeException("用户不存在"));

            // 4. 存入session
            HttpSession session = servletRequest.getSession(true);
            session.setAttribute("currentUser", user);

            // 5. 构建响应
            response.setSuccess(true);
            response.setMessage("登录成功");
            response.setUsername(user.getUsername());
            response.setRole(user.getRole().name());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage("登录失败: " + e.getMessage());
            return ResponseEntity.status(401).body(response);
        }
    }

    /**
     * 获取当前登录用户信息
     */
    @GetMapping("/current")
    public ResponseEntity<LoginResponse> getCurrentUser(HttpSession session) {
        LoginResponse response = new LoginResponse();

        // 1. 从session获取
        User user = (User) session.getAttribute("currentUser");

        // 2. 如果session中没有，从SecurityContext获取
        if (user == null) {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated() &&
                    !authentication.getPrincipal().equals("anonymousUser")) {

                String username = authentication.getName();
                user = userRepository.findByUsername(username).orElse(null);

                if (user != null) {
                    session.setAttribute("currentUser", user);
                }
            }
        }

        if (user != null) {
            response.setSuccess(true);
            response.setUsername(user.getUsername());
            response.setRole(user.getRole().name());
        } else {
            response.setSuccess(false);
            response.setMessage("未登录");
        }

        return ResponseEntity.ok(response);
    }

    /**
     * 登出
     */
    @PostMapping("/logout")
    public ResponseEntity<LoginResponse> logout(HttpServletRequest request) {
        LoginResponse response = new LoginResponse();

        // 1. 清除session
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // 2. 清除SecurityContext
        SecurityContextHolder.clearContext();

        response.setSuccess(true);
        response.setMessage("登出成功");
        return ResponseEntity.ok(response);
    }

    /**
     * 检查登录状态
     */
    @GetMapping("/check")
    public ResponseEntity<LoginResponse> checkAuth(HttpSession session) {
        return getCurrentUser(session); // 复用当前用户逻辑
    }
}