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

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:week06;MODE=MySQL",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=test-secret-key-for-week07-at-least-32-bytes",
        "jwt.access-expiration=3600"
})
class WriteApiTest {

    private static final String SIGN_UP = """
            {"email": "%s", "password": "%s", "nickname": "%s"}""";

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

    private Long owner;
    private Long other;

    @BeforeEach
    void setUp() {
        ratingRepository.deleteAll();
        memberRepository.deleteAll();
        owner = memberRepository.save(new Member("owner@umc.com", "dummy", "주인")).getMemberId();
        other = memberRepository.save(new Member("other@umc.com", "dummy", "다른사람")).getMemberId();
    }

    private ResultActions post(String url, String body) throws Exception {
        return mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post(url)
                .contentType(MediaType.APPLICATION_JSON).content(body));
    }

    private ResultActions postRating(Long memberId, String body) throws Exception {
        return mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/ratings")
                .header("Authorization", bearer(memberId))
                .contentType(MediaType.APPLICATION_JSON).content(body));
    }

    private ResultActions patchRating(Long memberId, Object ratingId, String body) throws Exception {
        return mockMvc.perform(patch("/ratings/{r}", ratingId)
                .header("Authorization", bearer(memberId))
                .contentType(MediaType.APPLICATION_JSON).content(body));
    }

    private String bearer(Long memberId) {
        return "Bearer " + jwtUtil.createAccessToken(memberId, "member@umc.com");
    }

    private ResultActions signUp(String email, String password, String nickname) throws Exception {
        return post("/members", SIGN_UP.formatted(email, password, nickname));
    }

    private void expectFailure(ResultActions result, int status, String code, String message) throws Exception {
        result.andExpect(status().is(status))
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value(code))
                .andExpect(jsonPath("$.result").doesNotExist());
        if (message != null) {
            result.andExpect(jsonPath("$.message").value(message));
        }
    }

    private int createRating(Long memberId, long movieId) throws Exception {
        String body = postRating(memberId, "{\"movieId\": %d, \"score\": 5, \"comment\": \"최고\"}".formatted(movieId))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.result.ratingId");
    }

    @Test
    void signUpReturns201WithoutPasswordAndStoresBcryptHash() throws Exception {
        signUp("umc@example.com", "Umc!1234", "moviefan")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.message").value("회원가입에 성공했습니다."))
                .andExpect(jsonPath("$.result.email").value("umc@example.com"))
                .andExpect(jsonPath("$.result.nickname").value("moviefan"))
                .andExpect(jsonPath("$.result.memberId").isNumber())
                .andExpect(jsonPath("$.result.password").doesNotExist());

        String stored = memberRepository.findAll().stream()
                .filter(member -> member.getEmail().equals("umc@example.com"))
                .findFirst().orElseThrow().getPassword();
        assertThat(stored).hasSize(60).startsWith("$2a$");
        assertThat(passwordEncoder.matches("Umc!1234", stored)).isTrue();
    }

    @Test
    void duplicateEmailOrNicknameIs409() throws Exception {
        expectFailure(signUp("owner@umc.com", "Umc!1234", "새닉네임"), 409, "COMMON4092", "이미 사용 중인 이메일입니다.");
        expectFailure(signUp("new@umc.com", "Umc!1234", "주인"), 409, "COMMON4092", "이미 사용 중인 닉네임입니다.");
    }

    @Test
    void invalidSignUpIs400() throws Exception {
        expectFailure(signUp("not-email", "Umc!1234", "무비"), 400, "COMMON4001", "올바른 이메일 형식이 아닙니다.");
        expectFailure(signUp("a@umc.com", "weakpass1", "무비"), 400, "COMMON4001",
                "비밀번호는 대문자/소문자/숫자/특수문자를 포함한 8자 이상이어야 합니다.");
        expectFailure(signUp("a@umc.com", "Umc!1234", "가"), 400, "COMMON4001", "닉네임은 2자 이상 12자 이하로 입력해주세요.");
        expectFailure(signUp("a@umc.com", "Umc!1234", "가".repeat(13)), 400, "COMMON4001", "닉네임은 2자 이상 12자 이하로 입력해주세요.");
    }

    @Test
    void passwordOver72BytesIsRejectedAs400() throws Exception {
        String message = "비밀번호는 72바이트 이하로 입력해주세요.";
        expectFailure(signUp("long@umc.com", "Aa1!" + "a".repeat(80), "무비"), 400, "COMMON4001", message);
        // 글자 수는 34자여도 한글이라 72바이트를 넘는다
        expectFailure(signUp("long@umc.com", "Aa1!" + "가".repeat(30), "무비"), 400, "COMMON4001", message);
        signUp("ok@umc.com", "Aa1!" + "a".repeat(68), "무비").andExpect(status().isCreated());
    }

    @Test
    void malformedBodyAndPathAre400InTheSameShape() throws Exception {
        expectFailure(post("/members", "{not json"), 400, "COMMON4001", "요청 본문 형식이 올바르지 않습니다.");
        expectFailure(patchRating(owner, "abc", "{\"score\": 5}"), 400, "COMMON4001", "경로 값의 형식이 올바르지 않습니다.");
        expectFailure(mockMvc.perform(get("/members/abc/ratings")), 400, "COMMON4001", null);
    }

    @Test
    void createRatingReturnsRatingResponseAndDuplicateIs409() throws Exception {
        postRating(owner, "{\"movieId\": 680, \"score\": 5, \"comment\": \"명작\"}")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.message").value("평점을 등록했습니다."))
                .andExpect(jsonPath("$.result.ratingId").isNumber())
                .andExpect(jsonPath("$.result.movieId").value(680))
                .andExpect(jsonPath("$.result.score").value(5))
                .andExpect(jsonPath("$.result.comment").value("명작"))
                .andExpect(jsonPath("$.result.createdAt").isNotEmpty())
                .andExpect(jsonPath("$.result.member").doesNotExist());

        expectFailure(postRating(owner, "{\"movieId\": 680, \"score\": 4}"),
                409, "RATING409_1", "이미 이 영화에 평점을 남기셨습니다.");
        assertThat(ratingRepository.count()).isEqualTo(1);

        // 같은 영화라도 다른 회원은 등록할 수 있다
        createRating(other, 680);
    }

    @Test
    void memberIdInTheBodyCannotChangeWhoOwnsTheRating() throws Exception {
        postRating(owner, "{\"memberId\": %d, \"movieId\": 680, \"score\": 5}".formatted(other))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/members/{m}/ratings", other)).andExpect(jsonPath("$.length()").value(0));
        mockMvc.perform(get("/members/{m}/ratings", owner)).andExpect(jsonPath("$.length()").value(1));
    }

    @Test
    void ratingValidationIs400() throws Exception {
        expectFailure(postRating(owner, "{\"movieId\": 1, \"score\": 6}"), 400, "COMMON4001", "별점은 5점 이하여야 합니다.");
        expectFailure(postRating(owner, "{\"movieId\": 1, \"score\": 0}"), 400, "COMMON4001", "별점은 1점 이상이어야 합니다.");
        expectFailure(postRating(owner, "{\"movieId\": -1, \"score\": 3}"), 400, "COMMON4001", "영화 ID는 양수여야 합니다.");
        expectFailure(postRating(owner, "{\"score\": 3}"), 400, "COMMON4001", "영화 ID를 입력해주세요.");
        expectFailure(postRating(owner, "{\"movieId\": 1, \"score\": 3, \"comment\": \"%s\"}".formatted("가".repeat(501))),
                400, "COMMON4001", "후기는 500자 이하로 입력해주세요.");
        postRating(owner, "{\"movieId\": 1, \"score\": 3, \"comment\": \"%s\"}".formatted("가".repeat(500)))
                .andExpect(status().isCreated());
    }

    @Test
    void createWithTokenOfDeletedMemberIs404() throws Exception {
        expectFailure(postRating(999999L, "{\"movieId\": 1, \"score\": 3}"),
                404, "MEMBER404_1", "해당 회원을 찾을 수 없습니다.");
    }

    @Test
    void updateChangesScoreAndCommentAndReturnsFreshRatingResponse() throws Exception {
        int ratingId = createRating(owner, 680);
        LocalDateTime before = ratingRepository.findById((long) ratingId).orElseThrow().getUpdatedAt();
        Thread.sleep(5);

        String body = patchRating(owner, ratingId, "{\"score\": 3, \"comment\": \"다시 보니 보통\"}")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("평점을 수정했습니다."))
                .andExpect(jsonPath("$.result.ratingId").value(ratingId))
                .andExpect(jsonPath("$.result.score").value(3))
                .andExpect(jsonPath("$.result.comment").value("다시 보니 보통"))
                .andReturn().getResponse().getContentAsString();

        // 응답의 수정 시각이 수정 전 값에 머물지 않아야 한다
        LocalDateTime answered = LocalDateTime.parse(JsonPath.read(body, "$.result.updatedAt"));
        assertThat(answered).isAfter(before);

        mockMvc.perform(get("/members/{m}/ratings", owner))
                .andExpect(jsonPath("$[0].score").value(3))
                .andExpect(jsonPath("$[0].comment").value("다시 보니 보통"));

        expectFailure(patchRating(owner, ratingId, "{\"score\": 9}"), 400, "COMMON4001", "별점은 5점 이하여야 합니다.");
    }

    @Test
    void otherMembersRatingIs403AndUnknownRatingIs404() throws Exception {
        int ratingId = createRating(owner, 680);
        String forbidden = "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.";

        expectFailure(patchRating(other, ratingId, "{\"score\": 1}"), 403, "RATING403_1", forbidden);
        expectFailure(deleteRating(other, ratingId), 403, "RATING403_1", forbidden);
        assertThat(ratingRepository.count()).isEqualTo(1);
        mockMvc.perform(get("/members/{m}/ratings", owner)).andExpect(jsonPath("$[0].score").value(5));

        expectFailure(patchRating(owner, 999999, "{\"score\": 1}"), 404, "RATING404_1", "해당 평점을 찾을 수 없습니다.");
        expectFailure(deleteRating(owner, 999999), 404, "RATING404_1", "해당 평점을 찾을 수 없습니다.");
    }

    @Test
    void writesWithoutTokenAre401AndChangeNothing() throws Exception {
        int ratingId = createRating(owner, 680);
        var json = MediaType.APPLICATION_JSON;

        expectFailure(mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/ratings")
                .contentType(json).content("{\"movieId\": 1, \"score\": 3}")), 401, "AUTH401_2", "로그인이 필요한 요청입니다.");
        expectFailure(mockMvc.perform(patch("/ratings/{r}", ratingId)
                .contentType(json).content("{\"score\": 1}")), 401, "AUTH401_2", "로그인이 필요한 요청입니다.");
        expectFailure(mockMvc.perform(delete("/ratings/{r}", ratingId)), 401, "AUTH401_2", "로그인이 필요한 요청입니다.");

        assertThat(ratingRepository.count()).isEqualTo(1);
    }

    @Test
    void week06UrlsWithMemberIdNoLongerWork() throws Exception {
        int ratingId = createRating(owner, 680);
        var json = MediaType.APPLICATION_JSON;

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/members/{m}/ratings", owner)
                        .contentType(json).content("{\"movieId\": 2, \"score\": 3}"))
                .andExpect(status().isMethodNotAllowed());
        mockMvc.perform(delete("/members/{m}/ratings/{r}", owner, ratingId).header("Authorization", bearer(owner)))
                .andExpect(status().is4xxClientError());

        assertThat(ratingRepository.count()).isEqualTo(1);
    }

    @Test
    void deleteReturns200WithNullResultAndRemovesFromList() throws Exception {
        int ratingId = createRating(owner, 680);

        deleteRating(owner, ratingId)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("평점을 삭제했습니다."))
                .andExpect(jsonPath("$.result").value(nullValue()));

        mockMvc.perform(get("/members/{m}/ratings", owner))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    private ResultActions deleteRating(Long memberId, Object ratingId) throws Exception {
        return mockMvc.perform(delete("/ratings/{r}", ratingId).header("Authorization", bearer(memberId)));
    }
}
