package com.umc.movie;

import com.umc.movie.entity.Favorite;
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
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.reset;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// 테스트 메서드에 @Transactional을 두지 않는다. 요청마다 실제로 commit/rollback되는지 보기 위해서다
@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week08-record;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=test-secret-key-for-week08-at-least-32-bytes",
        "jwt.access-expiration=3600"
})
class MovieRecordApiTest {

    private static final String RECORD = """
            {"movieId": %d, "score": 5, "comment": "다시 보고 싶은 영화입니다.", "addToFavorites": %s}""";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RatingRepository ratingRepository;

    @MockitoSpyBean
    private FavoriteRepository favoriteRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private Long owner;

    @BeforeEach
    void setUp() {
        reset(favoriteRepository);
        favoriteRepository.deleteAll();
        ratingRepository.deleteAll();
        memberRepository.deleteAll();
        owner = memberRepository.save(new Member("owner@umc.com", "dummy", "주인")).getMemberId();
    }

    private ResultActions record(String body) throws Exception {
        return mockMvc.perform(post("/movie-records")
                .header("Authorization", "Bearer " + jwtUtil.createAccessToken(owner, "owner@umc.com"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body));
    }

    @Test
    void 즐겨찾기_추가를_선택하면_평점과_즐겨찾기를_함께_저장한다() throws Exception {
        record(RECORD.formatted(238, true))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.message").value("영화 기록을 저장했습니다."))
                .andExpect(jsonPath("$.result.rating.movieId").value(238))
                .andExpect(jsonPath("$.result.rating.score").value(5))
                .andExpect(jsonPath("$.result.favorite.movieId").value(238))
                .andExpect(jsonPath("$.result.favorite.favoriteId").isNumber());

        assertThat(ratingRepository.count()).isEqualTo(1);
        assertThat(favoriteRepository.count()).isEqualTo(1);
    }

    @Test
    void 즐겨찾기_추가를_선택하지_않으면_평점만_저장한다() throws Exception {
        record(RECORD.formatted(238, false))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.result.rating.movieId").value(238))
                .andExpect(jsonPath("$.result.favorite").value(nullValue()));

        assertThat(ratingRepository.count()).isEqualTo(1);
        assertThat(favoriteRepository.count()).isZero();
    }

    @Test
    void 같은_기록을_다시_보내면_RATING409_1이고_행이_늘지_않는다() throws Exception {
        record(RECORD.formatted(238, true)).andExpect(status().isCreated());

        record(RECORD.formatted(238, true))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("RATING409_1"));

        assertThat(ratingRepository.count()).isEqualTo(1);
        assertThat(favoriteRepository.count()).isEqualTo(1);
    }

    @Test
    void 이미_즐겨찾기한_영화면_FAVORITE409_1이고_평점도_저장하지_않는다() throws Exception {
        favoriteRepository.save(Favorite.builder()
                .member(memberRepository.findById(owner).orElseThrow())
                .movieId(238L)
                .build());

        record(RECORD.formatted(238, true))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("FAVORITE409_1"));

        assertThat(ratingRepository.count()).isZero();
    }

    @Test
    void 즐겨찾기_저장이_실패하면_먼저_저장한_평점도_rollback된다() throws Exception {
        // 평점 저장 뒤 즐겨찾기 저장에서 DB 오류가 났다고 가정한다
        doThrow(new DataIntegrityViolationException("favorite insert failed"))
                .when(favoriteRepository).save(any(Favorite.class));

        record(RECORD.formatted(238, true))
                .andExpect(status().isConflict());

        assertThat(ratingRepository.count()).isZero();
        assertThat(favoriteRepository.count()).isZero();
    }

    @Test
    void 토큰_없이_보내면_401() throws Exception {
        mockMvc.perform(post("/movie-records")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(RECORD.formatted(238, true)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH401_2"));
    }

    @Test
    void 즐겨찾기_추가_여부가_없으면_400() throws Exception {
        record("{\"movieId\": 238, \"score\": 5}")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("즐겨찾기 추가 여부는 필수입니다."));
    }
}
