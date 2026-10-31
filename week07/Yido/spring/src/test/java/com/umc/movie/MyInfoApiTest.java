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
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
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

    private ResultActions updateNickname(String nickname) throws Exception {
        return mockMvc.perform(patch("/members/me")
                .header("Authorization", bearer(memberA))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"nickname\": \"%s\"}".formatted(nickname)));
    }

    @Test
    void updateChangesNicknameOfTheTokenOwnerOnly() throws Exception {
        updateNickname("새닉네임")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("회원 정보를 수정했습니다."))
                .andExpect(jsonPath("$.result.nickname").value("새닉네임"))
                .andExpect(jsonPath("$.result.email").value("a@umc.com"))
                .andExpect(jsonPath("$.result.createdAt").isNotEmpty());

        assertThat(memberRepository.findById(memberA).orElseThrow().getNickname()).isEqualTo("새닉네임");
        assertThat(memberRepository.existsByNickname("영화광B")).isTrue();
    }

    @Test
    void keepingMyOwnNicknameIsNotADuplicate() throws Exception {
        updateNickname("영화광A").andExpect(status().isOk());
    }

    @Test
    void nicknameOfAnotherMemberIs409() throws Exception {
        updateNickname("영화광B")
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("MEMBER409_1"))
                .andExpect(jsonPath("$.message").value("이미 사용 중인 닉네임입니다."));

        assertThat(memberRepository.findById(memberA).orElseThrow().getNickname()).isEqualTo("영화광A");
    }

    @Test
    void invalidNicknameIs400() throws Exception {
        updateNickname("가").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON4001"))
                .andExpect(jsonPath("$.message").value("닉네임은 2자 이상 12자 이하여야 합니다."));
        updateNickname("가".repeat(13)).andExpect(status().isBadRequest());
        updateNickname("  ").andExpect(status().isBadRequest());
    }

    @Test
    void updateWithoutTokenIs401() throws Exception {
        mockMvc.perform(patch("/members/me")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"nickname\": \"새닉네임\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH401_2"));
    }
}
