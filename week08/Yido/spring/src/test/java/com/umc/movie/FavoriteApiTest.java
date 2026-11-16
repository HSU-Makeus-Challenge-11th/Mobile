package com.umc.movie;

import com.umc.movie.entity.Member;
import com.umc.movie.repository.FavoriteRepository;
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

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week08-favorite;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=test-secret-key-for-week08-at-least-32-bytes",
        "jwt.access-expiration=3600"
})
class FavoriteApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private FavoriteRepository favoriteRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private Long owner;
    private Long other;

    @BeforeEach
    void setUp() {
        favoriteRepository.deleteAll();
        ratingRepository.deleteAll();
        memberRepository.deleteAll();
        owner = memberRepository.save(new Member("owner@umc.com", "dummy", "주인")).getMemberId();
        other = memberRepository.save(new Member("other@umc.com", "dummy", "다른사람")).getMemberId();
    }

    private String bearer(Long memberId) {
        return "Bearer " + jwtUtil.createAccessToken(memberId, "x@umc.com");
    }

    private ResultActions add(Long memberId, Object movieId) throws Exception {
        return mockMvc.perform(post("/favorites")
                .header("Authorization", bearer(memberId))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"movieId\": " + movieId + "}"));
    }

    @Test
    void 즐겨찾기를_등록하면_201과_결과를_준다() throws Exception {
        add(owner, 550)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.message").value("즐겨찾기를 등록했습니다."))
                .andExpect(jsonPath("$.result.favoriteId").isNumber())
                .andExpect(jsonPath("$.result.movieId").value(550))
                .andExpect(jsonPath("$.result.createdAt").isNotEmpty());
    }

    @Test
    void 같은_영화를_두_번_등록하면_409() throws Exception {
        add(owner, 550).andExpect(status().isCreated());

        add(owner, 550)
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("FAVORITE409_1"));
    }

    @Test
    void 다른_회원은_같은_영화를_즐겨찾기할_수_있다() throws Exception {
        add(owner, 550).andExpect(status().isCreated());
        add(other, 550).andExpect(status().isCreated());
    }

    @Test
    void 토큰_없이_등록하면_401() throws Exception {
        mockMvc.perform(post("/favorites")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"movieId\": 550}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH401_2"));
    }

    @Test
    void 영화_ID가_0이면_400() throws Exception {
        add(owner, 0)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("영화 ID는 양수여야 합니다."));
    }

    @Test
    void 목록은_내_것만_최신_등록_순서로_준다() throws Exception {
        add(owner, 550);
        add(other, 13);
        add(owner, 238);

        mockMvc.perform(get("/favorites").header("Authorization", bearer(owner)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.result", hasSize(2)))
                .andExpect(jsonPath("$.result[0].movieId").value(238))
                .andExpect(jsonPath("$.result[1].movieId").value(550));
    }

    @Test
    void 빈_목록은_200과_빈_배열() throws Exception {
        mockMvc.perform(get("/favorites").header("Authorization", bearer(owner)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result", hasSize(0)));
    }

    @Test
    void 여부_조회는_등록_전후로_false에서_true로_바뀐다() throws Exception {
        mockMvc.perform(get("/favorites/{movieId}", 550).header("Authorization", bearer(owner)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.isFavorite").value(false));

        add(owner, 550);

        mockMvc.perform(get("/favorites/{movieId}", 550).header("Authorization", bearer(owner)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("즐겨찾기 여부를 조회했습니다."))
                .andExpect(jsonPath("$.result.isFavorite").value(true));
    }

    @Test
    void 해제하면_200과_null_결과를_주고_다시_조회하면_false() throws Exception {
        add(owner, 550);

        mockMvc.perform(delete("/favorites/{movieId}", 550).header("Authorization", bearer(owner)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("즐겨찾기를 해제했습니다."))
                .andExpect(jsonPath("$.result").value(nullValue()));

        mockMvc.perform(get("/favorites/{movieId}", 550).header("Authorization", bearer(owner)))
                .andExpect(jsonPath("$.result.isFavorite").value(false));
    }

    @Test
    void 없는_즐겨찾기를_해제하면_404() throws Exception {
        mockMvc.perform(delete("/favorites/{movieId}", 550).header("Authorization", bearer(owner)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("FAVORITE404_1"));
    }

    @Test
    void 다른_회원의_즐겨찾기는_해제할_수_없다() throws Exception {
        add(other, 550);

        mockMvc.perform(delete("/favorites/{movieId}", 550).header("Authorization", bearer(owner)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("FAVORITE404_1"));

        mockMvc.perform(get("/favorites/{movieId}", 550).header("Authorization", bearer(other)))
                .andExpect(jsonPath("$.result.isFavorite").value(true));
    }
}
