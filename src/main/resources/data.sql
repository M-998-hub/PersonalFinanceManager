-- 先删除可能存在的旧数据（避免重复）
DELETE FROM users WHERE username IN ('admin', 'user1');

-- 插入管理员和普通用户（使用明文密码，仅开发用）
INSERT INTO users (username, password, role) VALUES
                                                 ('admin', '$2a$10$Cog9EYy2yE8CIFMmovG.fu6Z4Xm2eT1gTpJUbwi4qFYPpYvH/m3Ia', 'ADMIN'),
                                                 ('user1', '$2a$10$Ua34IRfQkY8HF0zJwNR9HO2.vxSLBPpgdmqYyB2/s7ZqfEXfFFPqW', 'USER');