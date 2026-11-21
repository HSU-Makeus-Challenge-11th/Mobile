package com.umc.movie.service;

import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.UpdateRatingRequest;
import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.exception.ApiException;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class RatingServiceTest {

    @Mock
    private RatingRepository ratingRepository;

    @Mock
    private MemberRepository memberRepository;

    @InjectMocks
    private RatingService ratingService;

    // 엔티티 ID는 DB가 채우므로, DB 없는 단위 테스트에서는 직접 넣는다
    private Member memberWithId(Long memberId, String email, String nickname) {
        Member member = Member.builder().email(email).password("암호화된비밀번호").nickname(nickname).build();
        ReflectionTestUtils.setField(member, "memberId", memberId);
        return member;
    }

    @Test
    @DisplayName("같은 영화에 평점을 다시 등록하면 RATING409_1 예외를 던지고 저장하지 않는다")
    void createRatingWhenDuplicated() {
        // given: 1번 회원이 550번 영화에 이미 평점을 남겼다
        given(memberRepository.findById(1L)).willReturn(Optional.of(memberWithId(1L, "challenger@umc.com", "영화조아")));
        given(ratingRepository.existsByMember_MemberIdAndMovieId(1L, 550L)).willReturn(true);

        // when & then: 409 예외가 나고, 저장은 시도하지 않는다
        assertThatThrownBy(() -> ratingService.create(1L, new CreateRatingRequest(550L, 4, "또 보고 싶다")))
                .isInstanceOf(ApiException.class)
                .hasMessage("이미 이 영화에 평점을 남기셨습니다.")
                .extracting("code").isEqualTo("RATING409_1");
        verify(ratingRepository, never()).save(any(Rating.class));
    }

    @Test
    @DisplayName("남이 남긴 평점을 수정하려 하면 RATING403_1 예외를 던지고 평점은 그대로다")
    void updateOthersRating() {
        // given: 10번 평점은 2번 회원의 것이다
        Rating othersRating = Rating.builder()
                .member(memberWithId(2L, "other@umc.com", "다른사람"))
                .movieId(550L)
                .score(5)
                .comment("인생 영화")
                .build();
        given(ratingRepository.findById(10L)).willReturn(Optional.of(othersRating));

        // when & then: 1번 회원이 고치려 하면 403 예외가 나고, 저장도 내용 변경도 없다
        assertThatThrownBy(() -> ratingService.update(1L, 10L, new UpdateRatingRequest(1, "별로")))
                .isInstanceOf(ApiException.class)
                .hasMessage("본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.")
                .extracting("code").isEqualTo("RATING403_1");
        verify(ratingRepository, never()).saveAndFlush(any(Rating.class));
        assertThat(othersRating.getScore()).isEqualTo(5);
        assertThat(othersRating.getComment()).isEqualTo("인생 영화");
    }
}
