package com.umc.movie;

import com.umc.movie.entity.Member;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import com.umc.movie.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week07myinfo;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=" + AuthApiTest.SECRET,
        "jwt.access-expiration=3600"
})
class MyInfoApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private Long memberA;

    @BeforeEach
    void setUp() {
        ratingRepository.deleteAll();
        memberRepository.deleteAll();
        memberA = memberRepository.save(new Member("a@umc.com", "dummy", "영화광A")).getMemberId();
        memberRepository.save(new Member("b@umc.com", "dummy", "영화광B"));
    }

    private String bearer(Long memberId) {
        return "Bearer " + jwtUtil.createAccessToken(memberId, "member@umc.com");
    }

    @Test
    void getMyInfoFollowsTheTokenAndHidesPassword() throws Exception {
        mockMvc.perform(get("/members/me").header("Authorization", bearer(memberA)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("회원 정보를 조회했습니다."))
                .andExpect(jsonPath("$.result.email").value("a@umc.com"))
                .andExpect(jsonPath("$.result.nickname").value("영화광A"))
                .andExpect(jsonPath("$.result.createdAt").isNotEmpty())
                .andExpect(jsonPath("$.result.password").doesNotExist())
                .andExpect(jsonPath("$.result.memberId").doesNotExist());
    }

    @Test
    void getMyInfoWithoutTokenIs401() throws Exception {
        mockMvc.perform(get("/members/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH401_2"));
    }

    @Test
    void tokenOfDeletedMemberIs404() throws Exception {
        mockMvc.perform(get("/members/me").header("Authorization", bearer(999999L)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("MEMBER404_1"))
                .andExpect(jsonPath("$.message").value("해당 회원을 찾을 수 없습니다."));
    }
}
