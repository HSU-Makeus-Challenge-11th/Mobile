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
import org.springframework.http.HttpStatus;
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

    // memberId는 DB가 저장할 때 채워 주는 값이라 builder로는 넣을 수 없습니다.
    // DB 없이 "1번 회원", "2번 회원"을 흉내 내려고 테스트에서만 필드에 직접 값을 넣습니다.
    private Member memberWithId(Long memberId, String email, String nickname) {
        Member member = Member.builder()
                .email(email)
                .password("암호화된비밀번호")
                .nickname(nickname)
                .build();
        ReflectionTestUtils.setField(member, "memberId", memberId);
        return member;
    }

    @Test
    @DisplayName("같은 영화에 평점을 다시 등록하면 RATING409_1 예외를 던지고 저장하지 않는다")
    void createRatingWhenDuplicated() {
        // given: 1번 회원이 550번 영화에 이미 평점을 남긴 상황
        Member me = memberWithId(1L, "challenger@umc.com", "영화조아");
        given(memberRepository.findById(1L)).willReturn(Optional.of(me));
        given(ratingRepository.existsByMember_MemberIdAndMovieId(1L, 550L)).willReturn(true);

        // when & then: 409와 RATING409_1이 담긴 예외가 나고, 저장은 시도조차 하지 않는다
        assertThatThrownBy(() -> ratingService.create(1L, new CreateRatingRequest(550L, 5, "또 남기기")))
                .isInstanceOf(ApiException.class)
                .hasFieldOrPropertyWithValue("status", HttpStatus.CONFLICT)
                .hasFieldOrPropertyWithValue("code", "RATING409_1");

        verify(ratingRepository, never()).save(any(Rating.class));
    }

    @Test
    @DisplayName("남의 평점을 수정하려 하면 RATING403_1 예외를 던지고 평점은 바뀌지 않는다")
    void updateOthersRating() {
        // given: 10번 평점의 주인은 2번 회원이고, 1번 회원이 수정을 시도하는 상황
        Member owner = memberWithId(2L, "owner@umc.com", "주인");
        Rating othersRating = Rating.builder()
                .member(owner)
                .movieId(550L)
                .score(5)
                .comment("주인이 남긴 후기")
                .build();
        given(ratingRepository.findById(10L)).willReturn(Optional.of(othersRating));

        // when & then: 403과 RATING403_1이 담긴 예외가 난다
        assertThatThrownBy(() -> ratingService.update(1L, 10L, new UpdateRatingRequest(1, "몰래 수정")))
                .isInstanceOf(ApiException.class)
                .hasFieldOrPropertyWithValue("status", HttpStatus.FORBIDDEN)
                .hasFieldOrPropertyWithValue("code", "RATING403_1");

        // then: 원래 평점은 그대로이고, DB 반영도 시도하지 않는다
        assertThat(othersRating.getScore()).isEqualTo(5);
        assertThat(othersRating.getComment()).isEqualTo("주인이 남긴 후기");
        verify(ratingRepository, never()).saveAndFlush(any(Rating.class));
    }
}
