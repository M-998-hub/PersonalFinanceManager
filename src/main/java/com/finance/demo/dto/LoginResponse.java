package demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import demo.entity.UserRole;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {
    private boolean success;
    private String token;

    @Builder.Default
    private String tokenType = "Bearer";

    private String message;
    private String username;
    private String role; // 关键：返回用户角色
}