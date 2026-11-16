package com.umc.backend.member;

import com.umc.backend.common.ApiException;
import com.umc.backend.member.dto.AvailabilityResponse;
import com.umc.backend.member.dto.MemberCreateRequest;
import com.umc.backend.member.dto.MemberCreateResponse;
import com.umc.backend.member.dto.MemberMeResponse;
import com.umc.backend.member.dto.MemberUpdateRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public MemberCreateResponse createMember(MemberCreateRequest request) {
        if (memberRepository.existsByEmail(request.email())) {
            throw new ApiException(HttpStatus.CONFLICT, "MEMBER4091", "이미 사용 중인 이메일입니다.");
        }
        if (memberRepository.existsByNickname(request.nickname())) {
            throw new ApiException(HttpStatus.CONFLICT, "MEMBER4092", "이미 사용 중인 닉네임입니다.");
        }

        Member member = new Member(
                request.email(),
                passwordEncoder.encode(request.password()),
                request.nickname()
        );
        return MemberCreateResponse.from(memberRepository.saveAndFlush(member));
    }

    @Transactional(readOnly = true)
    public AvailabilityResponse checkNickname(String nickname) {
        return new AvailabilityResponse(!memberRepository.existsByNickname(nickname));
    }

    @Transactional(readOnly = true)
    public AvailabilityResponse checkEmail(String email) {
        return new AvailabilityResponse(!memberRepository.existsByEmail(email));
    }

    @Transactional(readOnly = true)
    public MemberMeResponse getMe(Long memberId) {
        return MemberMeResponse.from(findMember(memberId));
    }

    @Transactional
    public MemberMeResponse updateMe(Long memberId, MemberUpdateRequest request) {
        Member member = findMember(memberId);
        if (!member.getNickname().equals(request.nickname())) {
            if (memberRepository.existsByNickname(request.nickname())) {
                throw new ApiException(HttpStatus.CONFLICT, "MEMBER409_1", "이미 사용 중인 닉네임입니다.");
            }
            member.changeNickname(request.nickname());
            memberRepository.flush();
        }
        return MemberMeResponse.from(member);
    }

    private Member findMember(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND,
                        "MEMBER404_1", "해당 회원을 찾을 수 없습니다."));
    }
}
