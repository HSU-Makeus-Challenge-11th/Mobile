package com.umc.backend.rating;

import com.umc.backend.common.PageResponse;
import com.umc.backend.member.Member;
import com.umc.backend.rating.dto.RatingResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RatingServiceTest {

    @Mock
    private RatingRepository ratingRepository;

    @InjectMocks
    private RatingService ratingService;

    @Test
    void 회원의_평점을_최신순_목록으로_변환한다() {
        Member member = new Member("noco@umc.com", "dummy", "수현");
        Rating newest = rating(member, 2L, 155L, 4, "다시 봐도 명작", LocalDateTime.of(2026, 8, 27, 10, 0));
        Rating older = rating(member, 1L, 550L, 5, "최고의 영화!", LocalDateTime.of(2026, 8, 26, 10, 0));
        when(ratingRepository.findAllByMemberMemberIdOrderByCreatedAtDescRatingIdDesc(1L))
                .thenReturn(List.of(newest, older));

        List<RatingResponse> responses = ratingService.getRatings(1L);

        assertThat(responses).extracting(RatingResponse::ratingId).containsExactly(2L, 1L);
        assertThat(responses.getFirst().movieId()).isEqualTo(155L);
    }

    @Test
    void 페이지_정보와_함께_평점을_응답한다() {
        Member member = new Member("noco@umc.com", "dummy", "수현");
        Rating rating = rating(member, 1L, 550L, 5, "최고의 영화!", LocalDateTime.of(2026, 8, 26, 10, 0));
        Pageable pageable = PageRequest.of(0, 10);
        when(ratingRepository.findAllByMemberMemberId(1L, pageable))
                .thenReturn(new PageImpl<>(List.of(rating), pageable, 1));

        PageResponse<RatingResponse> response = ratingService.getRatings(1L, pageable);

        assertThat(response.content()).hasSize(1);
        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.page()).isZero();
    }

    private Rating rating(
            Member member,
            Long ratingId,
            Long movieId,
            int score,
            String comment,
            LocalDateTime createdAt
    ) {
        Rating rating = new Rating(member, movieId, score, comment);
        ReflectionTestUtils.setField(rating, "ratingId", ratingId);
        ReflectionTestUtils.setField(rating, "createdAt", createdAt);
        ReflectionTestUtils.setField(rating, "updatedAt", createdAt);
        return rating;
    }
}
