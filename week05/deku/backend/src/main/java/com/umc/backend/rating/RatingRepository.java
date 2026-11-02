package com.umc.backend.rating;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    List<Rating> findAllByMemberMemberIdOrderByCreatedAtDescRatingIdDesc(Long memberId);

    Page<Rating> findAllByMemberMemberId(Long memberId, Pageable pageable);
}
