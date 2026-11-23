package com.umc.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
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
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:week09;MODE=MySQL;DB_CLOSE_DELAY=-1",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=0123456789abcdef0123456789abcdef",
        "jwt.access-expiration=3600000"
})
@AutoConfigureMockMvc
class Week09ApiIntegrationTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;
    @Autowired MemberRepository memberRepository;
    @Autowired RatingRepository ratingRepository;

    @Test
    void Swagger는_로그인_없이_열리고_공개_API와_인증_API를_구분한다() throws Exception {
        MvcResult ui = mvc.perform(get("/swagger-ui")).andReturn();
        assertThat(ui.getResponse().getStatus()).isBetween(300, 399);
        MvcResult index = mvc.perform(get("/swagger-ui/index.html")).andReturn();
        assertThat(index.getResponse().getStatus()).isEqualTo(200);
        assertThat(index.getResponse().getContentAsString()).contains("Swagger UI");

        JsonNode docs = response(get("/v3/api-docs"), 200);
        assertThat(docs.path("components").path("securitySchemes")
                .path("bearerAuth").path("scheme").asText()).isEqualTo("bearer");
        assertThat(docs.path("paths").path("/members").path("post").has("security")).isFalse();
        assertThat(docs.path("paths").path("/auth/login").path("post").has("security")).isFalse();
        assertThat(docs.path("paths").path("/members/{memberId}/ratings")
                .path("get").has("security")).isFalse();
        assertThat(docs.path("paths").path("/favorites").path("post")
                .path("security").get(0).has("bearerAuth")).isTrue();
        assertThat(docs.path("paths").path("/ratings").path("post")
                .path("security").get(0).has("bearerAuth")).isTrue();
        assertThat(docs.path("paths").path("/ratings").path("post")
                .path("responses").path("409").path("description").asText())
                .contains("RATING409_1");
        for (String route : List.of(
                "/ratings:post", "/ratings/{ratingId}:patch", "/ratings/{ratingId}:delete",
                "/members/me:get", "/members/me:patch", "/favorites:get",
                "/favorites:post", "/favorites/{movieId}:get",
                "/favorites/{movieId}:delete")) {
            String[] parts = route.split(":");
            JsonNode operation = docs.path("paths").path(parts[0]).path(parts[1]);
            assertThat(operation.path("summary").asText()).as(route).isNotBlank();
            assertThat(operation.path("security").get(0).has("bearerAuth"))
                    .as(route).isTrue();
        }
        assertThat(docs.path("paths").path("/members/{memberId}/ratings")
                .path("get").path("summary").asText()).isNotBlank();
    }

    @Test
    void 토큰_없이_즐겨찾기를_등록하면_401과_AUTH401_2가_나온다() throws Exception {
        assertCode(post("/favorites").contentType(MediaType.APPLICATION_JSON)
                .content(body(Map.of("movieId", 550))), 401, "AUTH401_2");
    }

    @Test
    void 토큰으로_즐겨찾기를_등록하면_201과_목록의_영화_ID를_확인한다() throws Exception {
        String token = createMemberAndLogin();
        JsonNode created = assertCode(post("/favorites").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(body(Map.of("movieId", 550))),
                201, "COMMON201");
        assertThat(created.path("result").path("movieId").asLong()).isEqualTo(550);
        JsonNode list = assertCode(get("/favorites").header("Authorization", bearer(token)),
                200, "COMMON200");
        assertThat(list.path("result").get(0).path("movieId").asLong()).isEqualTo(550);
    }

    @Test
    void 같은_영화를_두_번_즐겨찾기하면_409와_FAVORITE409_1이_나온다() throws Exception {
        String token = createMemberAndLogin();
        String request = body(Map.of("movieId", 551));
        assertCode(post("/favorites").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(request), 201, "COMMON201");
        assertCode(post("/favorites").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(request), 409, "FAVORITE409_1");
        JsonNode list = assertCode(get("/favorites").header("Authorization", bearer(token)),
                200, "COMMON200");
        assertThat(list.path("result")).hasSize(1);
    }

    @Test
    void 즐겨찾기를_해제하면_목록에서_사라진다() throws Exception {
        String token = createMemberAndLogin();
        assertCode(post("/favorites").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(body(Map.of("movieId", 552))),
                201, "COMMON201");
        assertCode(delete("/favorites/552").header("Authorization", bearer(token)),
                200, "COMMON200");
        JsonNode list = assertCode(get("/favorites").header("Authorization", bearer(token)),
                200, "COMMON200");
        assertThat(list.path("result")).isEmpty();
    }

    @Test
    void 토큰_없이_평점을_등록하면_401과_AUTH401_2가_나온다() throws Exception {
        assertCode(post("/ratings").contentType(MediaType.APPLICATION_JSON)
                .content(body(Map.of("movieId", 560, "score", 5))), 401, "AUTH401_2");
    }

    @Test
    void 토큰으로_평점을_등록하면_201과_평점_정보가_나온다() throws Exception {
        String token = createMemberAndLogin();
        JsonNode created = assertCode(post("/ratings").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body(Map.of("movieId", 561, "score", 4, "comment", "좋아요"))),
                201, "COMMON201");
        assertThat(created.path("result").path("ratingId").asLong()).isPositive();
        assertThat(created.path("result").path("movieId").asLong()).isEqualTo(561);
        assertThat(created.path("result").path("score").asInt()).isEqualTo(4);
    }

    @Test
    void 즐겨찾기_중복으로_영화_기록이_실패하면_평점_개수는_그대로다() throws Exception {
        String email = uniqueEmail();
        String token = createMemberAndLogin(email);
        Long memberId = memberRepository.findByEmail(email).orElseThrow().getMemberId();
        assertCode(post("/favorites").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(body(Map.of("movieId", 570))),
                201, "COMMON201");
        long before = ratingRepository.count();

        assertCode(post("/movie-records").header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body(Map.of("movieId", 570, "score", 5,
                        "comment", "롤백 확인", "addToFavorites", true))),
                409, "FAVORITE409_1");

        assertThat(ratingRepository.count()).isEqualTo(before);
        assertThat(ratingRepository.existsByMemberMemberIdAndMovieId(memberId, 570L)).isFalse();
    }

    private String createMemberAndLogin() throws Exception {
        return createMemberAndLogin(uniqueEmail());
    }

    private String createMemberAndLogin(String email) throws Exception {
        String nickname = "회원" + UUID.randomUUID().toString().substring(0, 8);
        assertCode(post("/members").contentType(MediaType.APPLICATION_JSON)
                .content(body(Map.of("email", email, "password", "Password!1",
                        "nickname", nickname))), 201, "COMMON201");
        JsonNode login = assertCode(post("/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(body(Map.of("email", email, "password", "Password!1"))),
                200, "COMMON200");
        return login.path("result").path("accessToken").asText();
    }

    private String uniqueEmail() {
        return "week09-" + UUID.randomUUID() + "@umc.com";
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private String body(Map<String, ?> data) throws Exception {
        return mapper.writeValueAsString(data);
    }

    private JsonNode assertCode(MockHttpServletRequestBuilder request, int status, String code)
            throws Exception {
        JsonNode json = response(request, status);
        assertThat(json.path("code").asText()).isEqualTo(code);
        return json;
    }

    private JsonNode response(MockHttpServletRequestBuilder request, int status) throws Exception {
        MvcResult result = mvc.perform(request).andReturn();
        assertThat(result.getResponse().getStatus()).isEqualTo(status);
        return mapper.readTree(result.getResponse().getContentAsByteArray());
    }
}
