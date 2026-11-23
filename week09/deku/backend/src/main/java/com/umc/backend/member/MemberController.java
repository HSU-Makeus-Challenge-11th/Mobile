package com.umc.backend.member;

import com.umc.backend.common.ApiResponse;
import com.umc.backend.member.dto.AvailabilityResponse;
import com.umc.backend.member.dto.MemberCreateRequest;
import com.umc.backend.member.dto.MemberCreateResponse;
import com.umc.backend.member.dto.MemberMeResponse;
import com.umc.backend.member.dto.MemberUpdateRequest;
import com.umc.backend.auth.AuthInterceptor;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
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

@Tag(name = "회원")
@Validated
@RestController
@RequestMapping("/members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @PostMapping
    @Operation(summary = "회원가입", description = "공개 API. 이메일, 비밀번호, 닉네임으로 회원을 등록합니다.")
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "201", description = "COMMON201: 회원가입 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "COMMON400: 입력 값 오류"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "409", description = "MEMBER4091: 이메일 중복, MEMBER4092: 닉네임 중복")
    })
    public ResponseEntity<ApiResponse<MemberCreateResponse>> createMember(
            @Valid @RequestBody MemberCreateRequest request
    ) {
        MemberCreateResponse response = memberService.createMember(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("COMMON201", "회원가입에 성공했습니다.", response));
    }

    @GetMapping("/nickname/{nickname}")
    @Operation(summary = "닉네임 사용 가능 여부", description = "공개 API. 닉네임 중복 여부를 확인합니다.")
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
    @Operation(summary = "이메일 사용 가능 여부", description = "공개 API. 이메일 중복 여부를 확인합니다.")
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
    @Operation(summary = "내 정보 조회", description = "인증 필요. JWT의 회원 정보를 조회합니다.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "COMMON200: 조회 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "AUTH401_2/3/4: 토큰 누락, 무효 또는 만료"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "MEMBER404_1: 회원 없음")
    })
    public ApiResponse<MemberMeResponse> getMe(@Parameter(hidden = true) @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId) {
        return ApiResponse.success("COMMON200", "내 정보 조회에 성공했습니다.", memberService.getMe(memberId));
    }

    @PatchMapping("/me")
    @Operation(summary = "내 정보 수정", description = "인증 필요. JWT의 회원 닉네임을 수정합니다.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "COMMON200: 수정 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "COMMON400: 입력 값 오류"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "AUTH401_2/3/4: 토큰 누락, 무효 또는 만료"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "409", description = "MEMBER409_1: 닉네임 중복")
    })
    public ApiResponse<MemberMeResponse> updateMe(
            @Parameter(hidden = true) @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody MemberUpdateRequest request
    ) {
        return ApiResponse.success("COMMON200", "내 정보 수정에 성공했습니다.",
                memberService.updateMe(memberId, request));
    }
}
