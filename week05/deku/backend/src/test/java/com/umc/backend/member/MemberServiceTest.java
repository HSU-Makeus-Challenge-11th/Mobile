package com.umc.backend.member;

import com.umc.backend.member.dto.AvailabilityResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MemberServiceTest {

    @Mock
    private MemberRepository memberRepository;

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
}
