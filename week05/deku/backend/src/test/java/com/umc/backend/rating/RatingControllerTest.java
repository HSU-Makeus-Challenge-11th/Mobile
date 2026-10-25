package com.umc.backend.rating;

import com.umc.backend.common.ApiExceptionHandler;
import com.umc.backend.common.PageResponse;
import com.umc.backend.rating.dto.RatingResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Pageable;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class RatingControllerTest {

    @Mock
    private RatingService ratingService;

    private MockMvc mockMvc;
    private RatingResponse rating;

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
                .andExpect(jsonPath("$[0].ratingId").value(1))
                .andExpect(jsonPath("$[0].movieId").value(550))
                .andExpect(jsonPath("$[0].score").value(5));
    }

    @Test
    void page와_size가_있으면_페이지_응답을_반환한다() throws Exception {
        PageResponse<RatingResponse> response = new PageResponse<>(List.of(rating), 0, 10, 1, 1);
        when(ratingService.getRatings(eq(1L), any(Pageable.class))).thenReturn(response);

        mockMvc.perform(get("/members/{memberId}/ratings", 1)
                        .queryParam("page", "0")
                        .queryParam("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].movieId").value(550))
                .andExpect(jsonPath("$.page").value(0))
                .andExpect(jsonPath("$.totalElements").value(1));
    }

    @Test
    void page와_size는_함께_입력해야_한다() throws Exception {
        mockMvc.perform(get("/members/{memberId}/ratings", 1)
                        .queryParam("page", "0"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("page와 size는 함께 입력해야 합니다."));
    }
}
