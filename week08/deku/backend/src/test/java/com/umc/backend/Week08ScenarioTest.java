package com.umc.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.umc.backend.favorite.FavoriteRepository;
import com.umc.backend.member.MemberRepository;
import com.umc.backend.rating.RatingRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:week08;MODE=MySQL;DB_CLOSE_DELAY=-1",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=0123456789abcdef0123456789abcdef",
        "jwt.access-expiration=3600000"
})
@AutoConfigureMockMvc
class Week08ScenarioTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;
    @Autowired MemberRepository memberRepository;
    @Autowired RatingRepository ratingRepository;
    @Autowired FavoriteRepository favoriteRepository;

    @Test
    void 즐겨찾기_API는_토큰_회원별로_동작하고_공통_응답을_사용한다() throws Exception {
        String tokenA = createMemberAndLogin("A");
        String tokenB = createMemberAndLogin("B");
        String favorite = json(Map.of("movieId", 550));

        assertStatus(post("/favorites").contentType(MediaType.APPLICATION_JSON).content(favorite),
                401, "AUTH401_2");
        assertStatus(post("/favorites").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(json(Map.of("movieId", 0))),
                400, "COMMON400");
        assertThat(result(get("/favorites").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result").isEmpty()).isTrue();
        assertThat(result(get("/favorites/550").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result").path("isFavorite").asBoolean()).isFalse();

        JsonNode created = result(post("/favorites").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(favorite), 201, "COMMON201");
        assertThat(created.path("result").path("favoriteId").asLong()).isPositive();
        assertThat(created.path("result").path("movieId").asLong()).isEqualTo(550);
        assertThat(created.path("result").path("createdAt").asText()).isNotBlank();
        assertStatus(post("/favorites").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(favorite), 409, "FAVORITE409_1");

        JsonNode list = result(get("/favorites").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result");
        assertThat(list.size()).isEqualTo(1);
        assertThat(list.get(0).path("movieId").asLong()).isEqualTo(550);
        assertStatus(post("/favorites").header("Authorization", bearer(tokenA))
                .contentType(MediaType.APPLICATION_JSON).content(json(Map.of("movieId", 551))),
                201, "COMMON201");
        JsonNode ordered = result(get("/favorites").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result");
        assertThat(ordered.size()).isEqualTo(2);
        assertThat(ordered.get(0).path("movieId").asLong()).isEqualTo(551);
        assertThat(ordered.get(1).path("movieId").asLong()).isEqualTo(550);
        assertStatus(delete("/favorites/551").header("Authorization", bearer(tokenA)),
                200, "COMMON200");
        assertThat(result(get("/favorites/550").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result").path("isFavorite").asBoolean()).isTrue();
        assertThat(result(get("/favorites/550").header("Authorization", bearer(tokenB)),
                200, "COMMON200").path("result").path("isFavorite").asBoolean()).isFalse();
        assertStatus(post("/favorites").header("Authorization", bearer(tokenB))
                .contentType(MediaType.APPLICATION_JSON).content(favorite), 201, "COMMON201");

        assertStatus(delete("/favorites/999").header("Authorization", bearer(tokenA)),
                404, "FAVORITE404_1");
        JsonNode deleted = result(delete("/favorites/550").header("Authorization", bearer(tokenA)),
                200, "COMMON200");
        assertThat(deleted.path("result").isNull()).isTrue();
        assertThat(result(get("/favorites/550").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result").path("isFavorite").asBoolean()).isFalse();
        assertThat(result(get("/favorites").header("Authorization", bearer(tokenA)),
                200, "COMMON200").path("result").isEmpty()).isTrue();
        assertThat(result(get("/favorites").header("Authorization", bearer(tokenB)),
                200, "COMMON200").path("result").size()).isEqualTo(1);
    }

    @Test
    void 영화_기록은_두_저장을_묶고_즐겨찾기_실패_시_평점도_롤백한다() throws Exception {
        String email = uniqueEmail("record");
        String token = createMemberAndLogin(email, "기록" + shortSuffix());
        Long memberId = memberRepository.findByEmail(email).orElseThrow().getMemberId();

        JsonNode created = result(post("/movie-records").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content(recordBody(238, true)), 201, "COMMON201").path("result");
        assertThat(created.path("rating").path("movieId").asLong()).isEqualTo(238);
        assertThat(created.path("favorite").path("movieId").asLong()).isEqualTo(238);
        assertStatus(post("/movie-records").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(recordBody(238, true)),
                409, "RATING409_1");

        JsonNode ratingOnly = result(post("/movie-records").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content(recordBody(239, false)), 201, "COMMON201").path("result");
        assertThat(ratingOnly.path("rating").path("movieId").asLong()).isEqualTo(239);
        assertThat(ratingOnly.path("favorite").isNull()).isTrue();

        assertStatus(post("/favorites").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(json(Map.of("movieId", 240))),
                201, "COMMON201");
        assertStatus(post("/movie-records").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(recordBody(240, true)),
                409, "FAVORITE409_1");
        assertThat(ratingRepository.existsByMemberMemberIdAndMovieId(memberId, 240L)).isFalse();
        assertThat(favoriteRepository.existsByMemberMemberIdAndMovieId(memberId, 240L)).isTrue();
        assertThat(ratingRepository.findAllByMemberMemberIdOrderByCreatedAtDescRatingIdDesc(memberId))
                .hasSize(2);
    }

    private String createMemberAndLogin(String label) throws Exception {
        return createMemberAndLogin(uniqueEmail(label), "회원" + shortSuffix());
    }

    private String createMemberAndLogin(String email, String nickname) throws Exception {
        String signup = json(Map.of(
                "email", email, "password", "Password!1", "nickname", nickname
        ));
        assertStatus(post("/members").contentType(MediaType.APPLICATION_JSON).content(signup),
                201, "COMMON201");
        String login = json(Map.of("email", email, "password", "Password!1"));
        return result(post("/auth/login").contentType(MediaType.APPLICATION_JSON).content(login),
                200, "COMMON200").path("result").path("accessToken").asText();
    }

    private String uniqueEmail(String label) {
        return label + "-" + System.nanoTime() + "@umc.com";
    }

    private String shortSuffix() {
        return Long.toString(System.nanoTime() % 1_000_000);
    }

    private String recordBody(int movieId, boolean addToFavorites) throws Exception {
        return json(Map.of(
                "movieId", movieId, "score", 5, "comment", "좋아요",
                "addToFavorites", addToFavorites
        ));
    }

    private String json(Map<String, ?> body) throws Exception {
        return mapper.writeValueAsString(body);
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private void assertStatus(MockHttpServletRequestBuilder request, int status, String code)
            throws Exception {
        result(request, status, code);
    }

    private JsonNode result(MockHttpServletRequestBuilder request, int status, String code)
            throws Exception {
        MvcResult response = mvc.perform(request).andReturn();
        assertThat(response.getResponse().getStatus()).isEqualTo(status);
        JsonNode json = mapper.readTree(response.getResponse().getContentAsByteArray());
        assertThat(json.path("code").asText()).isEqualTo(code);
        return json;
    }
}
