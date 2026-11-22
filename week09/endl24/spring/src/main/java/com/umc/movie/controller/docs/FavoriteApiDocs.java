package com.umc.movie.controller.docs;

import com.umc.movie.config.OpenApiConfig;
import com.umc.movie.dto.CreateFavoriteRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

/**
 * 즐겨찾기 API의 Swagger 문서입니다. FavoriteController가 이 인터페이스를 구현합니다.
 * 문서용 애너테이션을 여기로 빼 두면 컨트롤러에는 실제 동작 코드만 남습니다.
 * 반환 타입을 ResponseEntity<?>로 둔 것은, Swagger의 @ApiResponse와
 * 우리 응답 DTO인 ApiResponse의 이름이 같아 한 파일에서 함께 import할 수 없기 때문입니다.
 * 응답 모양은 각 @ApiResponse의 예시 JSON으로 보여 줍니다.
 */
@Tag(name = "즐겨찾기", description = "로그인한 회원의 즐겨찾기를 등록·조회·해제합니다. 모든 API에 토큰이 필요합니다.")
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@ApiResponse(responseCode = "401", description = "토큰 없음(AUTH401_2) · 유효하지 않은 토큰(AUTH401_3) · 만료된 토큰(AUTH401_4)",
        content = @Content(mediaType = "application/json", examples = {
                @ExampleObject(name = "AUTH401_2 토큰 없음", value = DocsExamples.AUTH401_2),
                @ExampleObject(name = "AUTH401_3 유효하지 않은 토큰", value = DocsExamples.AUTH401_3),
                @ExampleObject(name = "AUTH401_4 만료된 토큰", value = DocsExamples.AUTH401_4)
        }))
public interface FavoriteApiDocs {

    @Operation(summary = "즐겨찾기 등록",
            description = "토큰의 회원이 영화를 즐겨찾기에 추가합니다. movieId는 TMDB 영화 ID입니다.")
    @ApiResponse(responseCode = "201", description = "등록 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON201",
                      "message": "즐겨찾기를 등록했습니다.",
                      "result": {
                        "favoriteId": 1,
                        "movieId": 550,
                        "createdAt": "2026-11-14T22:30:00"
                      }
                    }
                    """)))
    @ApiResponse(responseCode = "400", description = "movieId가 없거나 양수가 아님(COMMON4001)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.COMMON4001_MOVIE_ID)))
    @ApiResponse(responseCode = "404", description = "토큰의 회원이 더 이상 존재하지 않음(MEMBER404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.MEMBER404_1)))
    @ApiResponse(responseCode = "409", description = "이미 같은 영화를 즐겨찾기함(FAVORITE409_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.FAVORITE409_1)))
    ResponseEntity<?> create(Long memberId, CreateFavoriteRequest request);

    @Operation(summary = "내 즐겨찾기 조회",
            description = "토큰의 회원이 즐겨찾기한 영화를 최근에 등록한 순서로 돌려줍니다. 하나도 없으면 빈 배열입니다.")
    @ApiResponse(responseCode = "200", description = "조회 성공 (즐겨찾기가 없으면 result는 빈 배열)",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "내 즐겨찾기 목록을 조회했습니다.",
                      "result": [
                        {
                          "favoriteId": 2,
                          "movieId": 238,
                          "createdAt": "2026-11-14T22:40:00"
                        },
                        {
                          "favoriteId": 1,
                          "movieId": 550,
                          "createdAt": "2026-11-14T22:30:00"
                        }
                      ]
                    }
                    """)))
    ResponseEntity<?> getMyFavorites(Long memberId);

    @Operation(summary = "특정 영화 즐겨찾기 여부 조회",
            description = "토큰의 회원이 이 영화를 즐겨찾기했는지 알려줍니다. 즐겨찾기하지 않았어도 오류가 아니라 isFavorite: false입니다.")
    @ApiResponse(responseCode = "200", description = "조회 성공 (즐겨찾기하지 않았으면 isFavorite: false)",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "즐겨찾기 여부를 조회했습니다.",
                      "result": {
                        "isFavorite": true
                      }
                    }
                    """)))
    ResponseEntity<?> getStatus(
            Long memberId,
            @Parameter(description = "TMDB 영화 ID", example = "550") Long movieId
    );

    @Operation(summary = "즐겨찾기 해제",
            description = "토큰의 회원이 즐겨찾기한 영화를 목록에서 뺍니다. 공통 응답 형식을 유지하려고 200과 result: null을 돌려줍니다.")
    @ApiResponse(responseCode = "200", description = "해제 성공",
            content = @Content(mediaType = "application/json", examples = @ExampleObject(value = """
                    {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "즐겨찾기를 해제했습니다.",
                      "result": null
                    }
                    """)))
    @ApiResponse(responseCode = "404", description = "즐겨찾기하지 않은 영화를 해제하려 함(FAVORITE404_1)",
            content = @Content(mediaType = "application/json",
                    examples = @ExampleObject(value = DocsExamples.FAVORITE404_1)))
    ResponseEntity<?> delete(
            Long memberId,
            @Parameter(description = "TMDB 영화 ID", example = "550") Long movieId
    );
}
