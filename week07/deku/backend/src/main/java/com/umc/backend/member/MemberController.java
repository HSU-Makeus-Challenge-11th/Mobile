package com.umc.backend.member;

import com.umc.backend.common.ApiResponse;
import com.umc.backend.member.dto.AvailabilityResponse;
import com.umc.backend.member.dto.MemberCreateRequest;
import com.umc.backend.member.dto.MemberCreateResponse;
import com.umc.backend.member.dto.MemberMeResponse;
import com.umc.backend.member.dto.MemberUpdateRequest;
import com.umc.backend.auth.AuthInterceptor;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @PostMapping
    public ResponseEntity<ApiResponse<MemberCreateResponse>> createMember(
            @Valid @RequestBody MemberCreateRequest request
    ) {
        MemberCreateResponse response = memberService.createMember(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("COMMON201", "회원가입에 성공했습니다.", response));
    }

    @GetMapping("/nickname/{nickname}")
    public ApiResponse<AvailabilityResponse> checkNickname(
            @PathVariable
            @Size(min = 2, max = 12, message = "닉네임은 2자 이상 12자 이하여야 합니다.")
            String nickname
    ) {
        return ApiResponse.success(
                "COMMON200",
                "닉네임 중복 확인에 성공했습니다.",
                memberService.checkNickname(nickname)
        );
    }

    @GetMapping("/email/{email}")
    public ApiResponse<AvailabilityResponse> checkEmail(
            @PathVariable
            @Email(message = "올바른 이메일 형식이 아닙니다.")
            @Size(max = 254, message = "이메일은 254자를 넘을 수 없습니다.")
            String email
    ) {
        return ApiResponse.success(
                "COMMON200",
                "이메일 중복 확인에 성공했습니다.",
                memberService.checkEmail(email)
        );
    }

    @GetMapping("/me")
    public ApiResponse<MemberMeResponse> getMe(@RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId) {
        return ApiResponse.success("COMMON200", "내 정보 조회에 성공했습니다.", memberService.getMe(memberId));
    }

    @PatchMapping("/me")
    public ApiResponse<MemberMeResponse> updateMe(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody MemberUpdateRequest request
    ) {
        return ApiResponse.success("COMMON200", "내 정보 수정에 성공했습니다.",
                memberService.updateMe(memberId, request));
    }
}
