package com.umc.backend.rating;

import com.umc.backend.common.PageResponse;
import com.umc.backend.rating.dto.RatingResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;

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
}
