package com.umc.movie.controller.docs;

import com.umc.movie.config.OpenApiConfig;
import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.dto.UpdateRatingRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.http.ResponseEntity;

import java.util.List;

/**
 * 평점 API의 Swagger 문서입니다. RatingController가 이 인터페이스를 구현합니다.
 * 유저별 평점 조회는 공개 API라서, 즐겨찾기 문서처럼 인터페이스 맨 위에 자물쇠와 401을 한 번에 달지 않고
 * 토큰이 필요한 메서드에만 하나씩 붙입니다.
 */
public interface RatingApiDocs {

    @Operation(summary = "유저별 평점 조회",
            description = "회원 한 명이 남긴 평점을 최근 순서로 돌려줍니다. 토큰 없이 누구나 호출할 수 있습니다. "
                    + "다른 API와 달리 공통 응답 형식 없이 배열을 그대로 돌려줍니다.")
    @ApiResponse(responseCode = "200", description = "조회 성공 (평점이 없으면 빈 배열)",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    [
                      {
                        "ratingId": 9,
                        "movieId": 238,
                        "score": 5,
                        "comment": "다시 보고 싶은 영화입니다.",
                        "createdAt": "2026-11-22T14:00:00",
                        "updatedAt": "2026-11-22T14:00:00"
                      }
                    ]
                    """)))
    @ApiResponse(responseCode = "404", description = "없는 회원(MEMBER404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER404_1)))
    List<RatingResponse> getMemberRatings(
            @Parameter(description = "평점을 볼 회원의 ID", example = "9") Long memberId
    );

    @Operation(summary = "평점 등록",
            description = "토큰의 회원이 영화 한 편에 별점(1~5)과 후기를 남깁니다. 같은 영화에는 한 번만 남길 수 있습니다.")
    @SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
    @ApiResponse(responseCode = "201", description = "등록 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON201",
                      "message": "평점을 등록했습니다.",
                      "result": {
                        "ratingId": 9,
                        "movieId": 238,
                        "score": 5,
                        "comment": "다시 보고 싶은 영화입니다.",
                        "createdAt": "2026-11-22T14:00:00",
                        "updatedAt": "2026-11-22T14:00:00"
                      }
                    }
                    """)))
    @ApiResponse(responseCode = "400", description = "입력 규칙 위반(COMMON4001): 영화 ID·별점 누락, 별점 1~5 밖, 후기 500자 초과",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.COMMON4001_SCORE)))
    @ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.AUTH401_2)))
    @ApiResponse(responseCode = "404", description = "토큰의 회원이 더 이상 존재하지 않음(MEMBER404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER404_1)))
    @ApiResponse(responseCode = "409", description = "이미 이 영화에 평점을 남김(RATING409_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.RATING409_1)))
    ResponseEntity<?> create(Long memberId, CreateRatingRequest request);

    @Operation(summary = "평점 수정",
            description = "토큰의 회원이 자기가 남긴 평점의 별점과 후기를 바꿉니다. 남의 평점은 수정할 수 없습니다.")
    @SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
    @ApiResponse(responseCode = "200", description = "수정 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "평점을 수정했습니다.",
                      "result": {
                        "ratingId": 9,
                        "movieId": 238,
                        "score": 4,
                        "comment": "두 번째 보니 조금 길게 느껴졌습니다.",
                        "createdAt": "2026-11-22T14:00:00",
                        "updatedAt": "2026-11-22T14:30:00"
                      }
                    }
                    """)))
    @ApiResponse(responseCode = "400", description = "입력 규칙 위반(COMMON4001): 별점 누락, 별점 1~5 밖, 후기 500자 초과",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.COMMON4001_SCORE)))
    @ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.AUTH401_2)))
    @ApiResponse(responseCode = "403", description = "남의 평점을 수정하려 함(RATING403_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.RATING403_1)))
    @ApiResponse(responseCode = "404", description = "없는 평점(RATING404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.RATING404_1)))
    ResponseEntity<?> update(
            Long memberId,
            @Parameter(description = "수정할 평점의 ID", example = "9") Long ratingId,
            UpdateRatingRequest request
    );

    @Operation(summary = "평점 삭제",
            description = "토큰의 회원이 자기가 남긴 평점을 지웁니다. 공통 응답 형식을 유지하려고 200과 result: null을 돌려줍니다.")
    @SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
    @ApiResponse(responseCode = "200", description = "삭제 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "평점을 삭제했습니다.",
                      "result": null
                    }
                    """)))
    @ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.AUTH401_2)))
    @ApiResponse(responseCode = "403", description = "남의 평점을 삭제하려 함(RATING403_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.RATING403_1)))
    @ApiResponse(responseCode = "404", description = "없는 평점(RATING404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.RATING404_1)))
    ResponseEntity<?> delete(
            Long memberId,
            @Parameter(description = "삭제할 평점의 ID", example = "9") Long ratingId
    );
}
