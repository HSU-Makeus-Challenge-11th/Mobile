// src/test/java/com/umc/movie/service/RatingServiceTest.java
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

/**
 * 9주차 미션: 평점 서비스의 판단을 검증하는 단위 테스트입니다.
 * DB 없이 Repository 자리에 가짜(Mock)를 끼워 넣고 RatingService의 if 문만 확인합니다.
 */
@ExtendWith(MockitoExtension.class) // @Mock이 붙은 가짜 객체를 만들어주는 확장입니다
class RatingServiceTest {

    @Mock
    private RatingRepository ratingRepository; // 진짜 DB 대신 들어가는 가짜 Repository

    @Mock
    private MemberRepository memberRepository;

    @InjectMocks
    private RatingService ratingService; // 위의 가짜 두 개를 주입받은 진짜 Service

    @Test
    @DisplayName("같은 영화에 평점을 중복 등록하면 409 RATING409_1 예외를 던지고 저장하지 않는다")
    void createRatingWhenDuplicated() {
        // given: 회원은 존재하고, 이 영화(550)에 이미 평점을 남겨 둔 상황
        Member member = memberWithId(1L, "challenger@umc.com", "영화조아");
        given(memberRepository.findById(1L)).willReturn(Optional.of(member));
        given(ratingRepository.existsByMember_MemberIdAndMovieId(1L, 550L)).willReturn(true);

        // when & then: 같은 영화에 다시 등록하면 상태 코드 409와 code RATING409_1로 실패한다
        assertThatThrownBy(() -> ratingService.create(1L, new CreateRatingRequest(550L, 5, "또 남겨요")))
                .isInstanceOfSatisfying(ApiException.class, exception -> {
                    assertThat(exception.getStatus()).isEqualTo(HttpStatus.CONFLICT);
                    assertThat(exception.getCode()).isEqualTo("RATING409_1");
                });

        // 예외에서 멈추지 않고, 저장을 시도조차 하지 않았는지까지 확인한다
        verify(ratingRepository, never()).save(any(Rating.class));
    }

    @Test
    @DisplayName("남의 평점을 수정하려 하면 403 RATING403_1 예외를 던지고 평점을 바꾸지 않는다")
    void updateRatingOwnedByAnotherMember() {
        // given: 2번 회원이 남긴 평점(별점 3)이 있고, 1번 회원이 그 평점을 수정하려는 상황
        Member owner = memberWithId(2L, "owner@umc.com", "평점주인");
        Rating othersRating = Rating.builder()
                .member(owner)
                .movieId(550L)
                .score(3)
                .comment("원래 후기")
                .build();
        given(ratingRepository.findById(10L)).willReturn(Optional.of(othersRating));

        // when & then: 상태 코드 403과 code RATING403_1로 실패한다
        assertThatThrownBy(() -> ratingService.update(1L, 10L, new UpdateRatingRequest(5, "남이 바꾼 후기")))
                .isInstanceOfSatisfying(ApiException.class, exception -> {
                    assertThat(exception.getStatus()).isEqualTo(HttpStatus.FORBIDDEN);
                    assertThat(exception.getCode()).isEqualTo("RATING403_1");
                });

        // 예외에서 멈추지 않고, 원래 별점·후기가 그대로이고 저장도 호출되지 않았는지까지 확인한다
        assertThat(othersRating.getScore()).isEqualTo(3);
        assertThat(othersRating.getComment()).isEqualTo("원래 후기");
        verify(ratingRepository, never()).save(any(Rating.class));
    }

    /**
     * memberId는 DB가 채워주는 값(IDENTITY)이라 Builder로 넣을 수 없습니다.
     * 단위 테스트에는 DB가 없으므로, "저장된 뒤의 회원"을 흉내 내기 위해 ID만 직접 채워 줍니다.
     */
    private Member memberWithId(Long memberId, String email, String nickname) {
        Member member = Member.builder()
                .email(email)
                .password("암호화된비밀번호")
                .nickname(nickname)
                .build();
        ReflectionTestUtils.setField(member, "memberId", memberId);
        return member;
    }
}
