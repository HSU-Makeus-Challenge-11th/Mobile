package com.umc.backend.auth;

import com.umc.backend.auth.dto.LoginRequest;
import com.umc.backend.auth.dto.LoginResponse;
import com.umc.backend.common.ApiException;
import com.umc.backend.common.ApiExceptionHandler;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
import com.umc.backend.rating.RatingController;
import com.umc.backend.rating.RatingService;
import com.umc.backend.rating.dto.RatingUpdateRequest;
import com.umc.backend.rating.dto.RatingResponse;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AuthFlowTest {

    private final JwtUtil jwtUtil = new JwtUtil("0123456789abcdef0123456789abcdef", 3_600_000);

    @Test
    void 로그인은_해시를_검증하고_회원_ID가_담긴_토큰을_발급한다() {
        MemberRepository members = mock(MemberRepository.class);
        PasswordEncoder encoder = mock(PasswordEncoder.class);
        Member member = new Member("a@umc.com", "stored-hash", "회원A");
        ReflectionTestUtils.setField(member, "memberId", 7L);
        when(members.findByEmail("a@umc.com")).thenReturn(Optional.of(member));
        when(encoder.matches("Password!1", "stored-hash")).thenReturn(true);
        AuthService service = new AuthService(members, encoder, jwtUtil);

        LoginResponse response = service.login(new LoginRequest("a@umc.com", "Password!1"));

        assertThat(response.nickname()).isEqualTo("회원A");
        assertThat(jwtUtil.getMemberId(response.accessToken())).isEqualTo(7L);
        assertThatThrownBy(() -> service.login(new LoginRequest("missing@umc.com", "Password!1")))
                .isInstanceOf(ApiException.class)
                .satisfies(error -> assertThat(((ApiException) error).getCode()).isEqualTo("AUTH401_1"));
    }

    @Test
    void 토큰_없음과_위조는_서로_다른_401을_반환한다() throws Exception {
        RatingService ratings = mock(RatingService.class);
        MockMvc mvc = mvc(ratings);
        String body = "{\"score\":4,\"comment\":\"good\"}";

        mvc.perform(patch("/ratings/10").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH401_2"));
        mvc.perform(patch("/ratings/10").header("Authorization", "Bearer forged")
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH401_3"));
    }

    @Test
    void 유효한_토큰의_회원_ID만_평점_수정에_전달하고_타인_평점은_403이다() throws Exception {
        RatingService ratings = mock(RatingService.class);
        RatingUpdateRequest request = new RatingUpdateRequest(4, "good");
        when(ratings.updateRating(eq(8L), eq(10L), any(RatingUpdateRequest.class)))
                .thenThrow(new ApiException(HttpStatus.FORBIDDEN, "RATING403_1",
                        "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다."));
        MockMvc mvc = mvc(ratings);

        mvc.perform(patch("/ratings/10")
                        .header("Authorization", "Bearer " + jwtUtil.createToken(8L, "b@umc.com"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"score\":4,\"comment\":\"good\"}"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("RATING403_1"));
        verify(ratings).updateRating(8L, 10L, request);
    }

    @Test
    void 만료된_토큰은_별도_401이다() {
        JwtUtil expired = new JwtUtil("0123456789abcdef0123456789abcdef", -61_000);
        assertThatThrownBy(() -> jwtUtil.getMemberId(expired.createToken(7L, "a@umc.com")))
                .isInstanceOf(ApiException.class)
                .satisfies(error -> assertThat(((ApiException) error).getCode()).isEqualTo("AUTH401_4"));
    }

    private MockMvc mvc(RatingService ratings) {
        return MockMvcBuilders.standaloneSetup(new RatingController(ratings))
                .addInterceptors(new AuthInterceptor(jwtUtil))
                .setControllerAdvice(new ApiExceptionHandler())
                .build();
    }
}
