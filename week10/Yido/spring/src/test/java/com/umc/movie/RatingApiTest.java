package com.umc.movie;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.entity.Member;
import com.umc.movie.repository.FavoriteRepository;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import com.umc.movie.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest        // 모든 Bean을 올려 인터셉터, 검증, 서비스, DB까지 진짜로 돈다
@AutoConfigureMockMvc  // HTTP 요청을 흉내 내는 MockMvc를 준비한다
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week09-rating;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=test-secret-key-for-week09-at-least-32-bytes",
        "jwt.access-expiration=3600"
})
class RatingApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private FavoriteRepository favoriteRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private Member member;

    @BeforeEach
    void setUp() {
        favoriteRepository.deleteAll();
        ratingRepository.deleteAll();
        memberRepository.deleteAll();
        // 로그인 API를 거치지 않고 회원을 저장한 뒤 토큰을 직접 발급한다
        member = memberRepository.save(Member.builder()
                .email("challenger@umc.com")
                .password("dummy")
                .nickname("영화조아")
                .build());
    }

    private String body() throws Exception {
        return objectMapper.writeValueAsString(new CreateRatingRequest(550L, 5, "다시 봐도 명작"));
    }

    @Test
    @DisplayName("토큰 없이 평점을 등록하면 401과 AUTH401_2를 응답하고 평점은 저장되지 않는다")
    void createRatingWithoutToken() throws Exception {
        mockMvc.perform(post("/ratings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("AUTH401_2"))
                .andExpect(jsonPath("$.message").value("로그인이 필요한 요청입니다."));

        assertThat(ratingRepository.count()).isZero();
    }

    @Test
    @DisplayName("토큰을 담아 평점을 등록하면 201과 저장한 평점을 응답한다")
    void createRating() throws Exception {
        String authorization = "Bearer " + jwtUtil.createAccessToken(member.getMemberId(), member.getEmail());

        mockMvc.perform(post("/ratings")
                        .header(HttpHeaders.AUTHORIZATION, authorization)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.result.movieId").value(550))
                .andExpect(jsonPath("$.result.score").value(5));

        // 평점의 주인은 요청 본문이 아니라 토큰의 회원이다
        assertThat(ratingRepository.findByMember_MemberIdOrderByRatingIdDesc(member.getMemberId())).hasSize(1);
    }
}
