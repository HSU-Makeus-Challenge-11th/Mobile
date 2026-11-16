package com.umc.backend.favorite;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    boolean existsByMemberMemberIdAndMovieId(Long memberId, Long movieId);

    Optional<Favorite> findByMemberMemberIdAndMovieId(Long memberId, Long movieId);

    List<Favorite> findAllByMemberMemberIdOrderByCreatedAtDescFavoriteIdDesc(Long memberId);
}
