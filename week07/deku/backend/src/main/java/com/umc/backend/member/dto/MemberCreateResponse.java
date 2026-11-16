package com.umc.backend.member.dto;

import com.umc.backend.member.Member;

public record MemberCreateResponse(
        Long memberId,
        String email,
        String nickname
) {
    public static MemberCreateResponse from(Member member) {
        return new MemberCreateResponse(
                member.getMemberId(),
                member.getEmail(),
                member.getNickname()
        );
    }
}
