package com.umc.backend.member;

import com.umc.backend.common.ApiException;
import com.umc.backend.member.dto.AvailabilityResponse;
import com.umc.backend.member.dto.MemberCreateRequest;
import com.umc.backend.member.dto.MemberCreateResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MemberServiceTest {

    @Mock
    private MemberRepository memberRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private MemberService memberService;

    @Test
    void 존재하는_닉네임은_사용할_수_없다() {
        when(memberRepository.existsByNickname("수현")).thenReturn(true);

        AvailabilityResponse response = memberService.checkNickname("수현");

        assertThat(response.available()).isFalse();
    }

    @Test
    void 존재하지_않는_이메일은_사용할_수_있다() {
        when(memberRepository.existsByEmail("new@umc.com")).thenReturn(false);

        AvailabilityResponse response = memberService.checkEmail("new@umc.com");

        assertThat(response.available()).isTrue();
    }

    @Test
    void 회원가입_비밀번호는_해시해서_저장하고_응답에서는_제외한다() {
        MemberCreateRequest request = new MemberCreateRequest("umc@example.com", "Umc!1234", "moviefan");
        when(memberRepository.existsByEmail(request.email())).thenReturn(false);
        when(memberRepository.existsByNickname(request.nickname())).thenReturn(false);
        when(passwordEncoder.encode(request.password())).thenReturn("bcrypt-hash");
        when(memberRepository.saveAndFlush(any(Member.class))).thenAnswer(invocation -> {
            Member member = invocation.getArgument(0);
            ReflectionTestUtils.setField(member, "memberId", 1L);
            return member;
        });

        MemberCreateResponse response = memberService.createMember(request);

        assertThat(response.memberId()).isEqualTo(1L);
        assertThat(response.email()).isEqualTo(request.email());
        assertThat(response.nickname()).isEqualTo(request.nickname());
        verify(passwordEncoder).encode("Umc!1234");
        verify(memberRepository).saveAndFlush(any(Member.class));
    }

    @Test
    void 중복_이메일은_409_예외를_발생시킨다() {
        MemberCreateRequest request = new MemberCreateRequest("umc@example.com", "Umc!1234", "moviefan");
        when(memberRepository.existsByEmail(request.email())).thenReturn(true);

        assertThatThrownBy(() -> memberService.createMember(request))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> assertThat(((ApiException) exception).getCode())
                        .isEqualTo("MEMBER4091"));
    }

    @Test
    void 중복_닉네임은_409_예외를_발생시킨다() {
        MemberCreateRequest request = new MemberCreateRequest("umc@example.com", "Umc!1234", "moviefan");
        when(memberRepository.existsByEmail(request.email())).thenReturn(false);
        when(memberRepository.existsByNickname(request.nickname())).thenReturn(true);

        assertThatThrownBy(() -> memberService.createMember(request))
                .isInstanceOf(ApiException.class)
                .satisfies(exception -> assertThat(((ApiException) exception).getCode())
                        .isEqualTo("MEMBER4092"));
    }
}
