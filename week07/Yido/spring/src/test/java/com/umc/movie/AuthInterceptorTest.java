package com.umc.movie;

import com.umc.movie.util.JwtUtil;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week07interceptor;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=" + AuthApiTest.SECRET,
        "jwt.access-expiration=3600"
})
class AuthInterceptorTest {

    @Autowired
    private MockMvc mockMvc;

    private static final String LOCKED = "/locked";

    @Autowired
    private JwtUtil jwtUtil;

    private ResultActions getWith(String authorization) throws Exception {
        return mockMvc.perform(get(LOCKED).header("Authorization", authorization));
    }

    private void expect401(ResultActions result, String code, String message) throws Exception {
        result.andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value(code))
                .andExpect(jsonPath("$.message").value(message));
    }

    private void expectInvalid(String authorization) throws Exception {
        expect401(getWith(authorization), "AUTH401_3", "유효하지 않은 토큰입니다.");
    }

    @Test
    void missingOrNonBearerHeaderIs401Auth2() throws Exception {
        String message = "로그인이 필요한 요청입니다.";
        expect401(mockMvc.perform(get(LOCKED)), "AUTH401_2", message);
        expect401(getWith("Basic abc"), "AUTH401_2", message);
        expect401(getWith(jwtUtil.createAccessToken(1L, "a@umc.com")), "AUTH401_2", message);
    }

    @Test
    void validTokenPassesTheGate() throws Exception {
        // 인터셉터를 통과하면 이 경로에는 처리기가 없어 404가 된다
        getWith("Bearer " + jwtUtil.createAccessToken(1L, "a@umc.com")).andExpect(status().isNotFound());
    }

    @Test
    void tamperedPayloadIs401Auth3() throws Exception {
        String[] parts = jwtUtil.createAccessToken(1L, "a@umc.com").split("\\.");
        int middle = parts[1].length() / 2;
        char replacement = parts[1].charAt(middle) == 'A' ? 'B' : 'A';
        String payload = parts[1].substring(0, middle) + replacement + parts[1].substring(middle + 1);

        expectInvalid("Bearer " + parts[0] + "." + payload + "." + parts[2]);
    }

    @Test
    void garbageEmptyAndOtherKeyTokensAre401Auth3() throws Exception {
        JwtUtil otherKey = new JwtUtil("another-secret-key-for-week07-at-least-32-bytes", 3600L);

        expectInvalid("Bearer not-a-token");
        expectInvalid("Bearer ");
        expectInvalid("Bearer " + otherKey.createAccessToken(1L, "a@umc.com"));
    }

    @Test
    void expiredTokenIs401Auth4() throws Exception {
        // 시계 오차 여유 60초보다 더 지난 토큰을 만든다
        JwtUtil expired = new JwtUtil(AuthApiTest.SECRET, -120L);

        expect401(getWith("Bearer " + expired.createAccessToken(1L, "a@umc.com")),
                "AUTH401_4", "토큰이 만료되었습니다. 다시 로그인해주세요.");
    }

    @Test
    void publicPathsStayOpenWithoutToken() throws Exception {
        mockMvc.perform(get("/members/nickname/아무개")).andExpect(status().isOk());
        mockMvc.perform(get("/members/email/nobody@umc.com")).andExpect(status().isOk());
        mockMvc.perform(get("/members/999999/ratings")).andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("MEMBER404_1"));
    }

    @Test
    void preflightPassesAndUnauthorizedResponseKeepsCorsHeader() throws Exception {
        mockMvc.perform(options(LOCKED)
                        .header("Origin", "http://localhost:5173")
                        .header("Access-Control-Request-Method", "PATCH")
                        .header("Access-Control-Request-Headers", "Authorization"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));

        mockMvc.perform(get(LOCKED).header("Origin", "http://localhost:5173"))
                .andExpect(status().isUnauthorized())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));
    }
}
