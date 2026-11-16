package com.umc.backend.movierecord;

import com.umc.backend.common.ApiException;
import com.umc.backend.favorite.Favorite;
import com.umc.backend.favorite.FavoriteRepository;
import com.umc.backend.favorite.FavoriteService;
import com.umc.backend.favorite.dto.FavoriteResponse;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
import com.umc.backend.movierecord.dto.MovieRecordCreateRequest;
import com.umc.backend.movierecord.dto.MovieRecordResponse;
import com.umc.backend.rating.Rating;
import com.umc.backend.rating.RatingRepository;
import com.umc.backend.rating.dto.RatingResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MovieRecordService {

    private final MemberRepository memberRepository;
    private final RatingRepository ratingRepository;
    private final FavoriteRepository favoriteRepository;

    @Transactional
    public MovieRecordResponse create(Long memberId, MovieRecordCreateRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND, "MEMBER404_1", "해당 회원을 찾을 수 없습니다."
                ));
        if (ratingRepository.existsByMemberMemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(
                    HttpStatus.CONFLICT, "RATING409_1", "이미 이 영화에 평점을 남기셨습니다."
            );
        }

        Rating rating = ratingRepository.saveAndFlush(
                new Rating(member, request.movieId(), request.score(), request.comment())
        );
        FavoriteResponse favorite = null;
        if (request.addToFavorites()) {
            if (favoriteRepository.existsByMemberMemberIdAndMovieId(memberId, request.movieId())) {
                throw FavoriteService.duplicateFavorite();
            }
            favorite = FavoriteResponse.from(
                    favoriteRepository.saveAndFlush(new Favorite(member, request.movieId()))
            );
        }
        return new MovieRecordResponse(RatingResponse.from(rating), favorite);
    }
}
