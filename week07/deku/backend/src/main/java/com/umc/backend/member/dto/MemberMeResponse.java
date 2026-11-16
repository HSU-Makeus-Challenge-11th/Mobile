package com.umc.backend.member.dto;

import com.umc.backend.member.Member;
import java.time.LocalDateTime;

public record MemberMeResponse(String email, String nickname, LocalDateTime createdAt) {
    public static MemberMeResponse from(Member member) {
        return new MemberMeResponse(member.getEmail(), member.getNickname(), member.getCreatedAt());
    }
}
