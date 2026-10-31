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

    private ResultActions patchRating(Long memberId, Object ratingId, String body) throws Exception {
        return mockMvc.perform(patch("/members/{m}/ratings/{r}", memberId, ratingId)
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
        String body = post("/members/" + memberId + "/ratings",
                "{\"movieId\": %d, \"score\": 5, \"comment\": \"최고\"}".formatted(movieId))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.result");
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
        expectFailure(post("/members/abc/ratings", "{\"movieId\": 1, \"score\": 5}"), 400, "COMMON4001",
                "경로 값의 형식이 올바르지 않습니다.");
        expectFailure(mockMvc.perform(get("/members/abc/ratings")), 400, "COMMON4001", null);
    }

    @Test
    void createRatingAndDuplicateIs409() throws Exception {
        post("/members/" + owner + "/ratings", "{\"movieId\": 680, \"score\": 5, \"comment\": \"명작\"}")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.result").isNumber());

        expectFailure(post("/members/" + owner + "/ratings", "{\"movieId\": 680, \"score\": 4}"),
                409, "COMMON4092", "이미 이 영화에 평점을 남기셨습니다.");
        assertThat(ratingRepository.count()).isEqualTo(1);

        // 같은 영화라도 다른 회원은 등록할 수 있다
        createRating(other, 680);
    }

    @Test
    void ratingValidationIs400() throws Exception {
        String url = "/members/" + owner + "/ratings";
        expectFailure(post(url, "{\"movieId\": 1, \"score\": 6}"), 400, "COMMON4001", "별점은 5점 이하여야 합니다.");
        expectFailure(post(url, "{\"movieId\": 1, \"score\": 0}"), 400, "COMMON4001", "별점은 1점 이상이어야 합니다.");
        expectFailure(post(url, "{\"movieId\": -1, \"score\": 3}"), 400, "COMMON4001", "영화 ID는 양수여야 합니다.");
        expectFailure(post(url, "{\"score\": 3}"), 400, "COMMON4001", "영화 ID를 입력해주세요.");
        expectFailure(post(url, "{\"movieId\": 1, \"score\": 3, \"comment\": \"%s\"}".formatted("가".repeat(501))),
                400, "COMMON4001", "후기는 500자 이하로 입력해주세요.");
        post(url, "{\"movieId\": 1, \"score\": 3, \"comment\": \"%s\"}".formatted("가".repeat(500)))
                .andExpect(status().isCreated());
    }

    @Test
    void createForUnknownMemberIs404() throws Exception {
        expectFailure(post("/members/999999/ratings", "{\"movieId\": 1, \"score\": 3}"),
                404, "COMMON404", "존재하지 않는 유저입니다.");
    }

    @Test
    void updateChangesScoreAndCommentAndShowsInList() throws Exception {
        int ratingId = createRating(owner, 680);

        patchRating(owner, ratingId, "{\"score\": 3, \"comment\": \"다시 보니 보통\"}")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.code").value("COMMON200"))
                .andExpect(jsonPath("$.message").value("평점 수정에 성공했습니다."));

        mockMvc.perform(get("/members/{m}/ratings", owner))
                .andExpect(jsonPath("$[0].score").value(3))
                .andExpect(jsonPath("$[0].comment").value("다시 보니 보통"));

        expectFailure(patchRating(owner, ratingId, "{\"score\": 9}"), 400, "COMMON4001", "별점은 5점 이하여야 합니다.");
    }

    @Test
    void otherMembersRatingIs403AndUnknownRatingIs404() throws Exception {
        int ratingId = createRating(owner, 680);
        String forbidden = "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.";

        expectFailure(patchRating(other, ratingId, "{\"score\": 1}"), 403, "COMMON403", forbidden);
        expectFailure(mockMvcDelete(other, ratingId), 403, "COMMON403", forbidden);
        assertThat(ratingRepository.count()).isEqualTo(1);

        expectFailure(patchRating(owner, 999999, "{\"score\": 1}"), 404, "COMMON404", "존재하지 않는 평점입니다.");
        expectFailure(mockMvcDelete(owner, 999999), 404, "COMMON404", "존재하지 않는 평점입니다.");
    }

    @Test
    void deleteReturns204WithEmptyBodyAndRemovesFromList() throws Exception {
        int ratingId = createRating(owner, 680);

        mockMvcDelete(owner, ratingId)
                .andExpect(status().isNoContent())
                .andExpect(result -> assertThat(result.getResponse().getContentAsString()).isEmpty());

        mockMvc.perform(get("/members/{m}/ratings", owner))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    private ResultActions mockMvcDelete(Long memberId, Object ratingId) throws Exception {
        return mockMvc.perform(delete("/members/{m}/ratings/{r}", memberId, ratingId)
                .header("Authorization", bearer(memberId)));
    }
}
