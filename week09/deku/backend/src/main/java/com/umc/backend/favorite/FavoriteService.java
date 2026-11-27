package com.umc.backend.favorite;

import com.umc.backend.common.ApiException;
import com.umc.backend.favorite.dto.FavoriteCreateRequest;
import com.umc.backend.favorite.dto.FavoriteResponse;
import com.umc.backend.favorite.dto.FavoriteStatusResponse;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public FavoriteResponse create(Long memberId, FavoriteCreateRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "MEMBER404_1", "해당 회원을 찾을 수 없습니다."
                ));
        if (favoriteRepository.existsByMemberMemberIdAndMovieId(memberId, request.movieId())) {
            throw duplicateFavorite();
        }
        return FavoriteResponse.from(
                favoriteRepository.saveAndFlush(new Favorite(member, request.movieId()))
        );
    }

    @Transactional(readOnly = true)
    public List<FavoriteResponse> getAll(Long memberId) {
        return favoriteRepository.findAllByMemberMemberIdOrderByCreatedAtDescFavoriteIdDesc(memberId)
                .stream()
                .map(FavoriteResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public FavoriteStatusResponse getStatus(Long memberId, Long movieId) {
        return new FavoriteStatusResponse(
                favoriteRepository.existsByMemberMemberIdAndMovieId(memberId, movieId)
        );
    }

    @Transactional
    public void delete(Long memberId, Long movieId) {
        Favorite favorite = favoriteRepository.findByMemberMemberIdAndMovieId(memberId, movieId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "FAVORITE404_1", "해제할 즐겨찾기를 찾을 수 없습니다."
                ));
        favoriteRepository.delete(favorite);
    }

    public static ApiException duplicateFavorite() {
        return new ApiException(
                HttpStatus.CONFLICT, "FAVORITE409_1", "이미 즐겨찾기한 영화입니다."
        );
    }
}
