package com.umc.movie.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger UI 맨 위에 보이는 문서 정보와, "Authorize" 버튼이 쓸 인증 방식을 등록합니다.
 * 여기서는 방식만 등록하고, 어떤 API가 토큰을 요구하는지는
 * 각 API에 @SecurityRequirement(name = BEARER_AUTH)를 붙여서 표시합니다.
 */
@Configuration
@OpenAPIDefinition(info = @Info(
        title = "UMC Movie API",
        version = "v1",
        description = "영화 평점·즐겨찾기 서비스 API 문서입니다. "
                + "자물쇠가 붙은 API는 POST /auth/login으로 받은 accessToken이 필요합니다. "
                + "오른쪽 Authorize 버튼에 토큰만 넣으면 Authorization: Bearer {token} 헤더로 전송됩니다."
))
@SecurityScheme(
        name = OpenApiConfig.BEARER_AUTH,
        type = SecuritySchemeType.HTTP, // Authorization 헤더를 쓰는 HTTP 인증
        scheme = "bearer", // 값 앞에 "Bearer "를 붙이는 방식
        bearerFormat = "JWT"
)
public class OpenApiConfig {
    public static final String BEARER_AUTH = "bearerAuth";
}
