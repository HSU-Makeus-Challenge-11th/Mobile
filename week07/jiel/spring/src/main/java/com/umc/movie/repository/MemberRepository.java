package com.umc.movie.repository;

import com.umc.movie.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long>{
    boolean existsByNickname(String nickname);
    boolean existsByEmail(String email);

    List<Member> email(String email);
    Optional<Member> findByEmail(String email);
    boolean existsByNicknameAndMemberIdNot(String nickname, Long memberId);
}
