package com.umc.movie;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// FRONTEND_ORIGIN에 쉼표로 넣은 주소가 모두 허용되고, 나머지 출처는 막히는지 확인한다
@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:cors;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=test-secret-key-for-week07-at-least-32-bytes",
        "jwt.access-expiration=3600",
        "cors.allowed-origins=http://localhost:5173,http://front.example.com"
})
class CorsConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void 환경변수로_넣은_프론트_주소는_사전_요청이_허용된다() throws Exception {
        for (String origin : new String[]{"http://localhost:5173", "http://front.example.com"}) {
            mockMvc.perform(options("/members/me")
                            .header("Origin", origin)
                            .header("Access-Control-Request-Method", "GET")
                            .header("Access-Control-Request-Headers", "Authorization"))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Access-Control-Allow-Origin", origin));
        }
    }

    @Test
    void 목록에_없는_출처는_사전_요청이_거절된다() throws Exception {
        mockMvc.perform(options("/members/me")
                        .header("Origin", "http://evil.example.com")
                        .header("Access-Control-Request-Method", "GET"))
                .andExpect(status().isForbidden());
    }
}
