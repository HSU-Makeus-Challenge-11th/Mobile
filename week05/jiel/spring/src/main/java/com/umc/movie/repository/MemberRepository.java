package com.umc.movie.repository;

import com.umc.movie.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MemberRepository extends JpaRepository<Member, Long>{
    boolean existsByNickname(String nickname);
    boolean existsByEmail(String email);

    List<Member> email(String email);
}
