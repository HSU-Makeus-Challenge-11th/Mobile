package com.umc.movie.controller.docs;

import com.umc.movie.config.OpenApiConfig;
import com.umc.movie.dto.CreateMovieRecordRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

/**
 * 영화 기록 API의 Swagger 문서입니다. MovieRecordController가 이 인터페이스를 구현합니다.
 */
@Tag(name = "영화 기록", description = "평점과 즐겨찾기를 한 번에 저장합니다. 토큰이 필요합니다.")
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
        content = @Content(mediaType = "application/json", examples = {
                @ExampleObject(name = "AUTH401_2 토큰 없음", value = DocsExamples.AUTH401_2),
                @ExampleObject(name = "AUTH401_3 유효하지 않은 토큰", value = DocsExamples.AUTH401_3),
                @ExampleObject(name = "AUTH401_4 만료된 토큰", value = DocsExamples.AUTH401_4)
        }))
public interface MovieRecordApiDocs {

    @Operation(summary = "영화 기록 저장",
            description = "평점을 저장하고, addToFavorites가 true면 즐겨찾기도 같은 트랜잭션 안에서 함께 저장합니다. "
                    + "둘 중 하나라도 실패하면 아무것도 저장되지 않습니다.")
    @ApiResponse(responseCode = "201", description = "저장 성공 (addToFavorites가 false면 favorite은 null)",
            content = @Content(mediaType = "application/json", examples = {
                    @ExampleObject(name = "평점과 즐겨찾기를 함께 저장", value = """
                            {
                              "isSuccess": true,
                              "code": "COMMON201",
                              "message": "영화 기록을 저장했습니다.",
                              "result": {
                                "rating": {
                                  "ratingId": 9,
                                  "movieId": 238,
                                  "score": 5,
                                  "comment": "다시 보고 싶은 영화입니다.",
                                  "createdAt": "2026-11-14T22:40:00",
                                  "updatedAt": "2026-11-14T22:40:00"
                                },
                                "favorite": {
                                  "favoriteId": 2,
                                  "movieId": 238,
                                  "createdAt": "2026-11-14T22:40:00"
                                }
                              }
                            }
                            """),
                    @ExampleObject(name = "평점만 저장 (addToFavorites: false)", value = """
                            {
                              "isSuccess": true,
                              "code": "COMMON201",
                              "message": "영화 기록을 저장했습니다.",
                              "result": {
                                "rating": {
                                  "ratingId": 10,
                                  "movieId": 155,
                                  "score": 4,
                                  "comment": null,
                                  "createdAt": "2026-11-14T22:45:00",
                                  "updatedAt": "2026-11-14T22:45:00"
                                },
                                "favorite": null
                              }
                            }
                            """)
            }))
    @ApiResponse(responseCode = "400", description = "입력 규칙 위반(COMMON4001): 필수 값 누락, 별점 1~5 밖, 후기 500자 초과 등",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.COMMON4001_SCORE)))
    @ApiResponse(responseCode = "404", description = "토큰의 회원이 더 이상 존재하지 않음(MEMBER404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER404_1)))
    @ApiResponse(responseCode = "409", description = "이미 평점을 남긴 영화(RATING409_1) · 이미 즐겨찾기한 영화(FAVORITE409_1)",
            content = @Content(mediaType = "application/json", examples = {
                    @ExampleObject(name = "RATING409_1 이미 평점을 남김", value = DocsExamples.RATING409_1),
                    @ExampleObject(name = "FAVORITE409_1 이미 즐겨찾기함", value = DocsExamples.FAVORITE409_1)
            }))
    ResponseEntity<?> create(Long memberId, CreateMovieRecordRequest request);
}
