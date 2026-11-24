package com.umc.movie.controller.docs;

import com.umc.movie.config.OpenApiConfig;
import com.umc.movie.dto.MemberUpdateRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.http.ResponseEntity;

/**
 * 내 정보 API의 Swagger 문서입니다. MemberController가 이 인터페이스를 구현합니다.
 * 같은 컨트롤러의 회원가입과 중복 확인은 공개 API라서, 자물쇠와 401은 메서드마다 붙입니다.
 */
public interface MemberApiDocs {

    @Operation(summary = "내 정보 조회",
            description = "토큰의 회원 정보(이메일, 닉네임, 가입일)를 돌려줍니다. 비밀번호는 응답에 담지 않습니다.")
    @SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
    @ApiResponse(responseCode = "200", description = "조회 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "회원 정보를 조회했습니다.",
                      "result": {
                        "email": "challenger@umc.com",
                        "nickname": "영화조아",
                        "createdAt": "2026-11-22T13:00:00"
                      }
                    }
                    """)))
    @ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.AUTH401_2)))
    @ApiResponse(responseCode = "404", description = "토큰의 회원이 더 이상 존재하지 않음(MEMBER404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER404_1)))
    ResponseEntity<?> getMyInfo(Long memberId);

    @Operation(summary = "내 정보 수정",
            description = "토큰의 회원 닉네임을 바꿉니다. 다른 회원이 쓰는 닉네임으로는 바꿀 수 없습니다.")
    @SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
    @ApiResponse(responseCode = "200", description = "수정 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "회원 정보를 수정했습니다.",
                      "result": {
                        "email": "challenger@umc.com",
                        "nickname": "새닉네임",
                        "createdAt": "2026-11-22T13:00:00"
                      }
                    }
                    """)))
    @ApiResponse(responseCode = "400", description = "닉네임 누락 또는 2~12자 밖(COMMON4001)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.COMMON4001_NICKNAME)))
    @ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.AUTH401_2)))
    @ApiResponse(responseCode = "404", description = "토큰의 회원이 더 이상 존재하지 않음(MEMBER404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER404_1)))
    @ApiResponse(responseCode = "409", description = "다른 회원이 쓰는 닉네임(MEMBER409_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER409_1)))
    ResponseEntity<?> updateMyInfo(Long memberId, MemberUpdateRequest request);
}
