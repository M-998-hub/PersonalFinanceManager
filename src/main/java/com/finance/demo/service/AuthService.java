package demo.service;

import demo.entity.User;
import demo.repository.UserRepository;
import demo.dto.LoginRequest;
import demo.dto.LoginResponse;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import demo.entity.UserRole;
import javax.crypto.SecretKey;
import java.util.Date;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // JWT密钥和配置 - 应从application.properties读取，此处为示例
    private final SecretKey jwtSecretKey = Keys.hmacShaKeyFor(
            "你的超级安全密钥至少32位字符长度aaaaaaaa".getBytes()
    );
    private final long jwtExpirationMs = 86400000; // 24小时

    /**
     * 用户登录认证
     */
    public LoginResponse authenticate(LoginRequest request) {
        // 1. 查找用户
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("用户名或密码错误"));

        // 2. 验证密码 (核心安全步骤!)
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }

        // 3. 检查用户状态 (可选)
        if (user.getEnabled() != null && !user.getEnabled()) {
            throw new RuntimeException("账户已被禁用");
        }

        // 4. 生成JWT令牌
        String token = generateToken(user);

        // 5. 构建响应 (关键：返回用户类型给前端)
        return LoginResponse.builder()
                .success(true)
                .token(token)
                .tokenType("Bearer")
                .message("登录成功")
                .username(user.getUsername())
                .role(user.getRole().name())
                .build();
    }

    /**
     * 生成JWT令牌
     */
    private String generateToken(User user) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + jwtExpirationMs);

        return Jwts.builder()
                .subject(user.getUsername())
                .issuedAt(now)
                .expiration(expiry)
                .claim("userId", user.getId())
                .claim("userRole", user.getRole().name()) // 将用户类型存入Token
                .signWith(jwtSecretKey)
                .compact();
    }

    /**
     * 从Token中解析用户名 (供后续过滤器使用)
     */
    public String getUsernameFromToken(String token) {
        return Jwts.parser()
                .verifyWith(jwtSecretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }
}