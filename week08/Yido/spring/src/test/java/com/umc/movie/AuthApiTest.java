package com.umc.movie;

import com.jayway.jsonpath.JsonPath;
import com.umc.movie.entity.Member;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import com.umc.movie.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week07auth;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=" + AuthApiTest.SECRET,
        "jwt.access-expiration=3600"
})
class AuthApiTest {

    static final String SECRET = "test-secret-key-for-week07-at-least-32-bytes";
    private static final String BAD_LOGIN = "이메일 또는 비밀번호가 올바르지 않습니다.";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    private Long memberId;

    @BeforeEach
    void setUp() {
        ratingRepository.deleteAll();
        memberRepository.deleteAll();
        memberId = memberRepository.save(new Member("a@umc.com", passwordEncoder.encode("Umc1234!"), "영화광A")).getMemberId();
    }

    private ResultActions login(String email, String password) throws Exception {
        return mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\": \"%s\", \"password\": \"%s\"}".formatted(email, password)));
    }

    private void expectFailure(ResultActions result, int status, String code, String message) throws Exception {
        result.andExpect(status().is(status))
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value(code))
                .andExpect(jsonPath("$.message").value(message))
                .andExpect(jsonPath("$.result").doesNotExist());
    }

    @Test
    void loginReturnsNicknameAndTokenCarryingMemberId() throws Exception {
        String body = login("a@umc.com", "Umc1234!")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("로그인에 성공했습니다."))
                .andExpect(jsonPath("$.result.nickname").value("영화광A"))
                .andExpect(jsonPath("$.result.password").doesNotExist())
                .andReturn().getResponse().getContentAsString();

        String token = JsonPath.read(body, "$.result.accessToken");
        assertThat(token.split("\\.")).hasSize(3);
        assertThat(jwtUtil.getMemberId(token)).isEqualTo(memberId);
    }

    @Test
    void wrongPasswordAndUnknownEmailGiveTheSameResponse() throws Exception {
        String wrongPassword = login("a@umc.com", "Wrong123!").andReturn().getResponse().getContentAsString();
        String unknownEmail = login("nobody@umc.com", "Umc1234!").andReturn().getResponse().getContentAsString();

        assertThat(wrongPassword).isEqualTo(unknownEmail);
        expectFailure(login("a@umc.com", "Wrong123!"), 401, "AUTH401_1", BAD_LOGIN);
    }

    @Test
    void passwordOver72BytesAtLoginIs401Not409() throws Exception {
        // 회원가입에서 겪은 BCrypt 72바이트 예외가 로그인에서 409로 새지 않는지 확인한다
        expectFailure(login("a@umc.com", "x".repeat(100)), 401, "AUTH401_1", BAD_LOGIN);
    }

    @Test
    void memberWithSeedDummyPasswordIs401Not500() throws Exception {
        memberRepository.save(new Member("noco@umc.com", "$2a$10$dummyEncodedPasswordValue", "수현"));

        expectFailure(login("noco@umc.com", "Umc1234!"), 401, "AUTH401_1", BAD_LOGIN);
    }

    @Test
    void blankOrMalformedLoginIs400() throws Exception {
        expectFailure(login("", "Umc1234!"), 400, "COMMON4001", "이메일을 입력해주세요.");
        expectFailure(login("not-email", "Umc1234!"), 400, "COMMON4001", "이메일 형식이 올바르지 않습니다.");
        expectFailure(login("a@umc.com", ""), 400, "COMMON4001", "비밀번호를 입력해주세요.");
    }
}
