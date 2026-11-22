package com.umc.backend.auth;

import com.umc.backend.auth.dto.LoginRequest;
import com.umc.backend.auth.dto.LoginResponse;
import com.umc.backend.common.ApiException;
import com.umc.backend.member.Member;
import com.umc.backend.member.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {
        Member member = memberRepository.findByEmail(request.email())
                .orElseThrow(AuthService::invalidCredentials);
        if (!passwordEncoder.matches(request.password(), member.getPassword())) {
            throw invalidCredentials();
        }
        return new LoginResponse(member.getNickname(),
                jwtUtil.createToken(member.getMemberId(), member.getEmail()));
    }

    private static ApiException invalidCredentials() {
        return new ApiException(HttpStatus.UNAUTHORIZED, "AUTH401_1",
                "이메일 또는 비밀번호가 올바르지 않습니다.");
    }
}
