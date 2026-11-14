package com.umc.movie.service;

import com.umc.movie.dto.CreateMovieRecordRequest;
import com.umc.movie.dto.FavoriteResponse;
import com.umc.movie.dto.MovieRecordResponse;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.entity.Favorite;
import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.exception.ApiException;
import com.umc.movie.repository.FavoriteRepository;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
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

    /**
     * 평점 저장과 즐겨찾기 저장을 하나의 트랜잭션으로 묶습니다.
     * 메서드가 정상적으로 끝나면 둘 다 commit되고,
     * 중간에 런타임 예외가 밖으로 나가면 먼저 저장한 것까지 rollback됩니다.
     * RatingService.create()와 FavoriteService.create()를 연달아 부르지 않고
     * Repository를 직접 쓰는 이유도, 두 저장이 이 메서드의 트랜잭션 하나 안에서 일어나게 하기 위해서입니다.
     */
    @Transactional
    public MovieRecordResponse create(Long memberId, CreateMovieRecordRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1",
                        "해당 회원을 찾을 수 없습니다."));

        // 저장을 시작하기 전에 실패할 조건을 먼저 모두 확인합니다
        if (ratingRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "RATING409_1",
                    "이미 이 영화에 평점을 남기셨습니다.");
        }

        if (request.addToFavorites()
                && favoriteRepository.existsByMember_MemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "FAVORITE409_1",
                    "이미 이 영화를 즐겨찾기하셨습니다.");
        }

        Rating rating = Rating.builder()
                .member(member)
                .movieId(request.movieId())
                .score(request.score())
                .comment(request.comment())
                .build();
        Rating savedRating = ratingRepository.save(rating);

        // addToFavorites가 false면 평점만 저장하고 favorite은 null로 응답합니다
        FavoriteResponse favoriteResponse = null;
        if (request.addToFavorites()) {
            Favorite favorite = Favorite.builder()
                    .member(member)
                    .movieId(request.movieId())
                    .build();
            Favorite savedFavorite = favoriteRepository.save(favorite);
            favoriteResponse = FavoriteResponse.from(savedFavorite);
        }

        return new MovieRecordResponse(RatingResponse.from(savedRating), favoriteResponse);
    }
}
