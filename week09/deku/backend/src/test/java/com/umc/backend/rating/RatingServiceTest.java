package com.umc.backend.rating;

import com.umc.backend.common.ApiException;
import com.umc.backend.common.PageResponse;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
import com.umc.backend.rating.dto.RatingCreateRequest;
import com.umc.backend.rating.dto.RatingResponse;
import com.umc.backend.rating.dto.RatingUpdateRequest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RatingServiceTest {

    @Mock
    private RatingRepository ratingRepository;

    @Mock
    private MemberRepository memberRepository;

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

    @Test
    void 존재하는_회원은_평점을_등록할_수_있다() {
        Member member = member(1L, "noco@umc.com", "수현");
        RatingCreateRequest request = new RatingCreateRequest(550L, 5, "최고의 영화!");
        when(memberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(ratingRepository.existsByMemberMemberIdAndMovieId(1L, 550L)).thenReturn(false);
        when(ratingRepository.saveAndFlush(any(Rating.class))).thenAnswer(invocation -> {
            Rating saved = invocation.getArgument(0);
            ReflectionTestUtils.setField(saved, "ratingId", 1L);
            return saved;
        });

        RatingResponse response = ratingService.createRating(1L, request);

        assertThat(response.ratingId()).isEqualTo(1L);
        assertThat(response.movieId()).isEqualTo(550L);
        assertThat(response.score()).isEqualTo(5);
    }

    @Test
    void 존재하지_않는_회원은_평점을_등록할_수_없다() {
        RatingCreateRequest request = new RatingCreateRequest(550L, 5, null);
        when(memberRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> ratingService.createRating(99L, request))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> assertThat(((ApiException) exception).getCode())
                        .isEqualTo("MEMBER404_1"));
    }

    @Test
    void 같은_영화에_평점을_중복_등록할_수_없다() {
        Member member = member(1L, "noco@umc.com", "수현");
        RatingCreateRequest request = new RatingCreateRequest(550L, 5, null);
        when(memberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(ratingRepository.existsByMemberMemberIdAndMovieId(1L, 550L)).thenReturn(true);

        assertThatThrownBy(() -> ratingService.createRating(1L, request))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> {
                    ApiException error = (ApiException) exception;
                    assertThat(error.getStatus()).isEqualTo(HttpStatus.CONFLICT);
                    assertThat(error.getCode()).isEqualTo("RATING409_1");
                });
        verify(ratingRepository, never()).saveAndFlush(any(Rating.class));
    }

    @Test
    void 평점_작성자는_평점을_수정할_수_있다() {
        Member member = member(1L, "noco@umc.com", "수현");
        Rating rating = rating(member, 1L, 550L, 5, "최고의 영화!", LocalDateTime.now());
        when(ratingRepository.findById(1L)).thenReturn(Optional.of(rating));

        RatingResponse response = ratingService.updateRating(
                1L,
                1L,
                new RatingUpdateRequest(4, "다시 봐도 명작")
        );

        assertThat(response.score()).isEqualTo(4);
        assertThat(response.comment()).isEqualTo("다시 봐도 명작");
    }

    @Test
    void 다른_회원의_평점은_수정할_수_없다() {
        Member owner = member(2L, "owner@umc.com", "작성자");
        Rating rating = rating(owner, 1L, 550L, 5, null, LocalDateTime.now());
        when(ratingRepository.findById(1L)).thenReturn(Optional.of(rating));

        assertThatThrownBy(() -> ratingService.updateRating(
                1L,
                1L,
                new RatingUpdateRequest(4, null)
        ))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> {
                    ApiException error = (ApiException) exception;
                    assertThat(error.getStatus()).isEqualTo(HttpStatus.FORBIDDEN);
                    assertThat(error.getCode()).isEqualTo("RATING403_1");
                });
        assertThat(rating.getScore().intValue()).isEqualTo(5);
    }

    @Test
    void 존재하지_않는_평점은_수정할_수_없다() {
        when(ratingRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> ratingService.updateRating(
                1L,
                99L,
                new RatingUpdateRequest(4, null)
        ))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> assertThat(((ApiException) exception).getCode())
                        .isEqualTo("RATING404_1"));
    }

    @Test
    void 평점_작성자는_평점을_삭제할_수_있다() {
        Member member = member(1L, "noco@umc.com", "수현");
        Rating rating = rating(member, 1L, 550L, 5, null, LocalDateTime.now());
        when(ratingRepository.findById(1L)).thenReturn(Optional.of(rating));

        ratingService.deleteRating(1L, 1L);

        verify(ratingRepository).delete(rating);
    }

    private Member member(Long memberId, String email, String nickname) {
        Member member = new Member(email, "dummy", nickname);
        ReflectionTestUtils.setField(member, "memberId", memberId);
        return member;
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
