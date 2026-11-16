package com.umc.backend.rating;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.umc.backend.common.ApiException;
import com.umc.backend.common.ApiExceptionHandler;
import com.umc.backend.common.PageResponse;
import com.umc.backend.rating.dto.RatingCreateRequest;
import com.umc.backend.rating.dto.RatingResponse;
import com.umc.backend.rating.dto.RatingUpdateRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class RatingControllerTest {

    @Mock
    private RatingService ratingService;

    private MockMvc mockMvc;
    private RatingResponse rating;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        LocalValidatorFactoryBean validator = new LocalValidatorFactoryBean();
        validator.afterPropertiesSet();

        mockMvc = MockMvcBuilders.standaloneSetup(new RatingController(ratingService))
                .setControllerAdvice(new ApiExceptionHandler())
                .setValidator(validator)
                .build();

        LocalDateTime timestamp = LocalDateTime.of(2026, 8, 26, 10, 0);
        rating = new RatingResponse(1L, 550L, 5, "최고의 영화!", timestamp, timestamp);
    }

    @Test
    void 쿼리가_없으면_평점_목록을_배열로_응답한다() throws Exception {
        when(ratingService.getRatings(1L)).thenReturn(List.of(rating));

        mockMvc.perform(get("/members/{memberId}/ratings", 1))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isSuccess").value(true))
                .andExpect(jsonPath("$.result[0].ratingId").value(1))
                .andExpect(jsonPath("$.result[0].movieId").value(550))
                .andExpect(jsonPath("$.result[0].score").value(5));
    }

    @Test
    void page와_size가_있으면_페이지_응답을_반환한다() throws Exception {
        PageResponse<RatingResponse> response = new PageResponse<>(List.of(rating), 0, 10, 1, 1);
        when(ratingService.getRatings(eq(1L), any(Pageable.class))).thenReturn(response);

        mockMvc.perform(get("/members/{memberId}/ratings", 1)
                        .queryParam("page", "0")
                        .queryParam("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.content[0].movieId").value(550))
                .andExpect(jsonPath("$.result.page").value(0))
                .andExpect(jsonPath("$.result.totalElements").value(1));
    }

    @Test
    void page와_size는_함께_입력해야_한다() throws Exception {
        mockMvc.perform(get("/members/{memberId}/ratings", 1)
                        .queryParam("page", "0"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.message").value("page와 size는 함께 입력해야 합니다."));
    }

    @Test
    void 평점을_등록하면_201과_ratingId를_응답한다() throws Exception {
        RatingCreateRequest request = new RatingCreateRequest(550L, 5, "최고의 영화!");
        when(ratingService.createRating(1L, request)).thenReturn(rating);

        mockMvc.perform(post("/ratings").requestAttr("memberId", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("COMMON201"))
                .andExpect(jsonPath("$.result.ratingId").value(1));
    }

    @Test
    void 잘못된_별점은_400_공통_오류를_응답한다() throws Exception {
        RatingCreateRequest request = new RatingCreateRequest(550L, 6, "범위를 벗어난 별점");

        mockMvc.perform(post("/ratings").requestAttr("memberId", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("COMMON400"));
    }

    @Test
    void 평점을_수정하면_200을_응답한다() throws Exception {
        RatingUpdateRequest request = new RatingUpdateRequest(4, "다시 봐도 명작");
        RatingResponse updated = new RatingResponse(
                1L,
                550L,
                4,
                "다시 봐도 명작",
                rating.createdAt(),
                rating.updatedAt()
        );
        when(ratingService.updateRating(1L, 1L, request)).thenReturn(updated);

        mockMvc.perform(patch("/ratings/{ratingId}", 1).requestAttr("memberId", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.score").value(4))
                .andExpect(jsonPath("$.result.comment").value("다시 봐도 명작"));
    }

    @Test
    void 평점을_삭제하면_204를_응답한다() throws Exception {
        mockMvc.perform(delete("/ratings/{ratingId}", 1).requestAttr("memberId", 1L))
                .andExpect(status().isOk()).andExpect(jsonPath("$.code").value("COMMON200"));

        verify(ratingService).deleteRating(1L, 1L);
    }

    @Test
    void 다른_회원의_평점을_수정하면_403_공통_오류를_응답한다() throws Exception {
        RatingUpdateRequest request = new RatingUpdateRequest(4, null);
        when(ratingService.updateRating(1L, 1L, request)).thenThrow(new ApiException(
                HttpStatus.FORBIDDEN,
                "RATING403_1",
                "다른 회원의 평점은 수정하거나 삭제할 수 없습니다."
        ));

        mockMvc.perform(patch("/ratings/{ratingId}", 1).requestAttr("memberId", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("RATING403_1"));
    }

    @Test
    void 존재하지_않는_평점을_삭제하면_404_공통_오류를_응답한다() throws Exception {
        org.mockito.Mockito.doThrow(new ApiException(
                        HttpStatus.NOT_FOUND,
                        "RATING404_1",
                        "존재하지 않는 평점입니다."
                ))
                .when(ratingService).deleteRating(1L, 99L);

        mockMvc.perform(delete("/ratings/{ratingId}", 99).requestAttr("memberId", 1L))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.isSuccess").value(false))
                .andExpect(jsonPath("$.code").value("RATING404_1"));
    }
}
