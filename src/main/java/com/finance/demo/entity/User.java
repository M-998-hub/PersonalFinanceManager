package demo.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 50)
    private String username;

    @Column(nullable = false, length = 100)
    private String password; // 实际存储应为加密后的密文

    @Enumerated(EnumType.STRING)
    @Column(name = "role",nullable = false, length = 20)
    private UserRole role;

    @Column(nullable = false)
    private Boolean enabled = true;

    private String email;
    private String phone;
}
