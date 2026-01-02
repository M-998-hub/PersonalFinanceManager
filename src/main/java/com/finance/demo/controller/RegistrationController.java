package demo.controller;

import demo.dto.RegisterRequest;
import demo.dto.LoginResponse;
import demo.dto.LoginRequest;
import demo.entity.User;
import demo.repository.UserRepository;
import demo.service.AuthService;
import demo.entity.UserRole;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
// 移除 @RequiredArgsConstructor，使用自定义构造器
public class RegistrationController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;

    @Autowired
    public RegistrationController(UserRepository userRepository,
                                  PasswordEncoder passwordEncoder,
                                  AuthService authService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authService = authService;
    }

    /**
     * 用户注册接口
     */
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody RegisterRequest request) {

        // 1. 检查用户名是否存在
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(LoginResponse.builder()
                            .success(false)
                            .message("用户名已存在")
                            .build());
        }

        // 2. 创建新用户（只创建，不登录）
        User newUser = new User();
        newUser.setUsername(request.getUsername());
        newUser.setPassword(passwordEncoder.encode(request.getPassword()));
        newUser.setRole(UserRole.USER);  // 普通用户
        newUser.setEnabled(true);

        // 设置其他信息
        newUser.setEmail(request.getEmail());
        newUser.setPhone(request.getPhone());

        // 3. 保存用户
        userRepository.save(newUser);



        // 4. 返回注册成功响应（不要返回Token！）
        return ResponseEntity.ok()
                .body(LoginResponse.builder()
                        .success(true)
                        .message("注册成功，请登录")
                        .username(newUser.getUsername())
                        .role(newUser.getRole().name())
                        .build());
    }

    /**
     * 检查用户名是否可用 (前端注册时实时验证)
     */
    @GetMapping("/check-username")
    public ResponseEntity<?> checkUsername(@RequestParam String username) {
        boolean exists = userRepository.findByUsername(username).isPresent();
        return ResponseEntity.ok().body(
                new UsernameCheckResponse(!exists, exists ? "用户名已存在" : "用户名可用")
        );
    }

    // 内部类，用于返回用户名检查结果
    private record UsernameCheckResponse(boolean available, String message) {}

    /**
     * 检查邮箱是否可用 (前端注册时实时验证)
     */
    @GetMapping("/check-email")
    public ResponseEntity<?> checkEmail(@RequestParam String email) {
        boolean exists = userRepository.findByEmail(email).isPresent();
        return ResponseEntity.ok().body(
                new EmailCheckResponse(!exists, exists ? "邮箱已被注册" : "邮箱可用")
        );
    }

    // 内部类，用于返回邮箱检查结果
    private record EmailCheckResponse(boolean available, String message) {}
}