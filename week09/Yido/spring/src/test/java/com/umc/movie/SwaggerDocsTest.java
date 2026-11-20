package com.umc.movie;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasKey;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week09-swagger;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=test-secret-key-for-week09-at-least-32-bytes",
        "jwt.access-expiration=3600"
})
class SwaggerDocsTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("Swagger 문서 JSON은 토큰 없이도 200으로 열린다")
    void apiDocsIsPublic() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.info.title").value("영화 평점 서비스 API"));
    }

    @Test
    @DisplayName("Swagger UI 주소는 토큰 없이 들어가도 401이 아니라 문서 화면으로 보낸다")
    void swaggerUiIsPublic() throws Exception {
        mockMvc.perform(get("/swagger-ui.html"))
                .andExpect(status().is3xxRedirection());
        mockMvc.perform(get("/swagger-ui/index.html"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("토큰이 필요한 API에만 bearerAuth 자물쇠가 붙는다")
    void onlyProtectedApisHaveLock() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(jsonPath("$.components.securitySchemes.bearerAuth.scheme").value("bearer"))
                // 토큰이 필요한 API
                .andExpect(jsonPath("$.paths['/favorites'].post.security[0]", hasKey("bearerAuth")))
                .andExpect(jsonPath("$.paths['/ratings'].post.security[0]", hasKey("bearerAuth")))
                .andExpect(jsonPath("$.paths['/ratings/{ratingId}'].patch.security[0]", hasKey("bearerAuth")))
                .andExpect(jsonPath("$.paths['/members/me'].get.security[0]", hasKey("bearerAuth")))
                .andExpect(jsonPath("$.paths['/movie-records'].post.security[0]", hasKey("bearerAuth")))
                // 공개 API
                .andExpect(jsonPath("$.paths['/members'].post", not(hasKey("security"))))
                .andExpect(jsonPath("$.paths['/auth/login'].post", not(hasKey("security"))))
                .andExpect(jsonPath("$.paths['/members/{memberId}/ratings'].get", not(hasKey("security"))))
                .andExpect(jsonPath("$.paths['/members/nickname/{nickname}'].get", not(hasKey("security"))));
    }

    @Test
    @DisplayName("즐겨찾기 등록 문서에 201, 401, 409 응답과 요청 예시가 적혀 있다")
    void favoriteCreateDocumentsFailures() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(jsonPath("$.paths['/favorites'].post.responses", hasKey("201")))
                .andExpect(jsonPath("$.paths['/favorites'].post.responses", hasKey("401")))
                .andExpect(jsonPath("$.paths['/favorites'].post.responses", hasKey("409")))
                .andExpect(jsonPath("$.components.schemas.CreateFavoriteRequest.properties.movieId.example").value(550));
    }

    @Test
    @DisplayName("회원가입 요청 문서에는 검증용 메서드가 필드로 나오지 않는다")
    void signUpSchemaHasOnlyThreeFields() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(jsonPath("$.components.schemas.SignUpRequest.properties", hasKey("email")))
                .andExpect(jsonPath("$.components.schemas.SignUpRequest.properties", not(hasKey("passwordWithinBcryptLimit"))));
    }
}
