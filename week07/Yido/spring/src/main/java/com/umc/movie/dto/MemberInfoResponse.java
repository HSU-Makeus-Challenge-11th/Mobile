package com.umc.movie.dto;

import com.umc.movie.entity.Member;

import java.time.LocalDateTime;

// 엔티티를 그대로 돌려주면 password까지 나가므로 DTO로 옮겨 담는다
public record MemberInfoResponse(
        String email,
        String nickname,
        LocalDateTime createdAt
) {
    public static MemberInfoResponse from(Member member) {
        return new MemberInfoResponse(member.getEmail(), member.getNickname(), member.getCreatedAt());
    }
}
