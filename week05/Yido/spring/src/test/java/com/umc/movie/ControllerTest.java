package com.umc.movie;

import com.umc.movie.config.WebConfig;
import com.umc.movie.controller.MemberController;
import com.umc.movie.controller.RatingController;
import com.umc.movie.dto.EmailCheckResponse;
import com.umc.movie.dto.NicknameCheckResponse;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.service.MemberService;
import com.umc.movie.service.RatingService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest({MemberController.class, RatingController.class})
@Import(WebConfig.class)
class ControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private MemberService memberService;

    @MockitoBean
    private RatingService ratingService;

    @Test
    void nicknameAndEmailCheckReturnAvailable() throws Exception {
        when(memberService.checkNickname("수현")).thenReturn(new NicknameCheckResponse(false));
        when(memberService.checkEmail("new@umc.com")).thenReturn(new EmailCheckResponse(true));

        mockMvc.perform(get("/members/nickname/{nickname}", "수현"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(false));
        mockMvc.perform(get("/members/email/{email}", "new@umc.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(true));
    }

    @Test
    void ratingsReturnDtoAndUnknownMemberIs404() throws Exception {
        LocalDateTime now = LocalDateTime.of(2026, 8, 26, 10, 0);
        when(ratingService.getRatingsByMember(1L)).thenReturn(List.of(
                new RatingResponse(2L, 155L, 4, "다시 봐도 명작", now, now)));
        when(ratingService.getRatingsByMember(999L))
                .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 유저입니다."));

        mockMvc.perform(get("/members/1/ratings"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].ratingId").value(2))
                .andExpect(jsonPath("$[0].movieId").value(155))
                .andExpect(jsonPath("$[0].createdAt").value("2026-08-26T10:00:00"))
                .andExpect(jsonPath("$[0].member").doesNotExist());
        mockMvc.perform(get("/members/999/ratings"))
                .andExpect(status().isNotFound());
    }

    @Test
    void corsAllowsOnlyFrontendOrigin() throws Exception {
        when(memberService.checkNickname("noco")).thenReturn(new NicknameCheckResponse(true));

        mockMvc.perform(get("/members/nickname/noco").header("Origin", "http://localhost:5173"))
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));
        mockMvc.perform(get("/members/nickname/noco").header("Origin", "http://evil.com"))
                .andExpect(status().isForbidden());
    }
}
