package com.umc.movie.repository;

import com.umc.movie.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    // 내 즐겨찾기 목록: 최근에 등록한 것부터
    List<Favorite> findByMember_MemberIdOrderByFavoriteIdDesc(Long memberId);

    // 해제할 때: 이 회원이 이 영화를 즐겨찾기한 행을 찾습니다
    Optional<Favorite> findByMember_MemberIdAndMovieId(Long memberId, Long movieId);

    // 등록 전 중복 검사와 즐겨찾기 여부 조회에 씁니다
    boolean existsByMember_MemberIdAndMovieId(Long memberId, Long movieId);
}
