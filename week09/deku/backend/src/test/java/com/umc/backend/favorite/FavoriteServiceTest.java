package com.umc.backend.favorite;

import com.umc.backend.common.ApiException;
import com.umc.backend.favorite.dto.FavoriteCreateRequest;
import com.umc.backend.favorite.dto.FavoriteResponse;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
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
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FavoriteServiceTest {

    @Mock FavoriteRepository favoriteRepository;
    @Mock MemberRepository memberRepository;
    @InjectMocks FavoriteService favoriteService;

    @Test
    void 즐겨찾기가_없으면_등록하고_영화_ID를_돌려준다() {
        Member member = member();
        when(memberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(favoriteRepository.saveAndFlush(any(Favorite.class))).thenAnswer(invocation -> {
            Favorite favorite = invocation.getArgument(0);
            ReflectionTestUtils.setField(favorite, "favoriteId", 10L);
            return favorite;
        });

        FavoriteResponse response = favoriteService.create(1L, new FavoriteCreateRequest(550L));

        assertThat(response.favoriteId()).isEqualTo(10L);
        assertThat(response.movieId()).isEqualTo(550L);
    }

    @Test
    void 같은_영화를_다시_즐겨찾기하면_409와_FAVORITE409_1을_반환한다() {
        when(memberRepository.findById(1L)).thenReturn(Optional.of(member()));
        when(favoriteRepository.existsByMemberMemberIdAndMovieId(1L, 550L)).thenReturn(true);
        lenient().when(favoriteRepository.saveAndFlush(any(Favorite.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        assertThatThrownBy(() -> favoriteService.create(1L, new FavoriteCreateRequest(550L)))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> {
                    ApiException error = (ApiException) exception;
                    assertThat(error.getStatus()).isEqualTo(HttpStatus.CONFLICT);
                    assertThat(error.getCode()).isEqualTo("FAVORITE409_1");
                });
        verify(favoriteRepository, never()).saveAndFlush(any(Favorite.class));
    }

    private Member member() {
        Member member = new Member("test@umc.com", "dummy", "테스트");
        ReflectionTestUtils.setField(member, "memberId", 1L);
        return member;
    }
}
