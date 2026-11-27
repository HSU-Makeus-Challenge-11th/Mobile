package com.umc.backend.rating;

import com.umc.backend.common.ApiException;
import com.umc.backend.common.PageResponse;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
import com.umc.backend.rating.dto.RatingCreateRequest;
import com.umc.backend.rating.dto.RatingResponse;
import com.umc.backend.rating.dto.RatingUpdateRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public RatingResponse createRating(Long memberId, RatingCreateRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND,
                        "MEMBER404_1",
                        "해당 회원을 찾을 수 없습니다."
                ));

        if (ratingRepository.existsByMemberMemberIdAndMovieId(memberId, request.movieId())) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "RATING409_1",
                    "이미 이 영화에 평점을 남기셨습니다."
            );
        }

        Rating rating = new Rating(member, request.movieId(), request.score(), request.comment());
        return RatingResponse.from(ratingRepository.saveAndFlush(rating));
    }

    @Transactional
    public RatingResponse updateRating(Long memberId, Long ratingId, RatingUpdateRequest request) {
        Rating rating = findRating(ratingId);
        validateOwner(rating, memberId);
        rating.update(request.score(), request.comment());
        return RatingResponse.from(rating);
    }

    @Transactional
    public void deleteRating(Long memberId, Long ratingId) {
        Rating rating = findRating(ratingId);
        validateOwner(rating, memberId);
        ratingRepository.delete(rating);
    }

    @Transactional(readOnly = true)
    public List<RatingResponse> getRatings(Long memberId) {
        return ratingRepository.findAllByMemberMemberIdOrderByCreatedAtDescRatingIdDesc(memberId).stream()
                .map(RatingResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public PageResponse<RatingResponse> getRatings(Long memberId, Pageable pageable) {
        Page<RatingResponse> result = ratingRepository.findAllByMemberMemberId(memberId, pageable)
                .map(RatingResponse::from);
        return PageResponse.from(result);
    }

    private Rating findRating(Long ratingId) {
        return ratingRepository.findById(ratingId)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND,
                        "RATING404_1",
                        "해당 평점을 찾을 수 없습니다."
                ));
    }

    private void validateOwner(Rating rating, Long memberId) {
        if (!rating.getMember().getMemberId().equals(memberId)) {
            throw new ApiException(
                    HttpStatus.FORBIDDEN,
                    "RATING403_1",
                    "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다."
            );
        }
    }
}
