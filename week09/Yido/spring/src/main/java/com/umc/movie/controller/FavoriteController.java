package com.umc.movie.controller;

import com.umc.movie.config.SwaggerConfig;
import com.umc.movie.config.SwaggerExamples;
import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.CreateFavoriteRequest;
import com.umc.movie.dto.FavoriteResponse;
import com.umc.movie.dto.FavoriteStatusResponse;
import com.umc.movie.interceptor.AuthInterceptor;
import com.umc.movie.service.FavoriteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// /favorites는 WebConfig의 공개 경로 목록에 없으므로 모두 토큰이 필요하다
@RestController
@RequiredArgsConstructor
@Tag(name = "즐겨찾기", description = "로그인한 회원의 영화 즐겨찾기 API")
@SecurityRequirement(name = SwaggerConfig.BEARER_AUTH) // 이 컨트롤러의 모든 API에 자물쇠가 붙는다
public class FavoriteController {

    private final FavoriteService favoriteService;

    @Operation(
            summary = "즐겨찾기 등록",
            description = "토큰의 주인인 회원이 TMDB 영화 ID 하나를 즐겨찾기에 추가합니다."
    )
    // 공통 응답 DTO 이름도 ApiResponse라서 Swagger 애노테이션은 풀네임으로 적는다
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "201", description = "즐겨찾기 등록 성공",
                    content = @Content(mediaType = "application/json",
                            examples = @ExampleObject(value = SwaggerExamples.FAVORITE_CREATED))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "400", description = "영화 ID가 없거나 양수가 아님 (COMMON4001)",
                    content = @Content(mediaType = "application/json",
                            examples = @ExampleObject(value = SwaggerExamples.MOVIE_ID_400))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "401", description = "토큰 없음 (AUTH401_2), 잘못된 토큰 (AUTH401_3), 만료된 토큰 (AUTH401_4)",
                    content = @Content(mediaType = "application/json", examples = {
                            @ExampleObject(name = "AUTH401_2", value = SwaggerExamples.AUTH401_2),
                            @ExampleObject(name = "AUTH401_3", value = SwaggerExamples.AUTH401_3),
                            @ExampleObject(name = "AUTH401_4", value = SwaggerExamples.AUTH401_4)})),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "409", description = "이미 즐겨찾기한 영화 (FAVORITE409_1)",
                    content = @Content(mediaType = "application/json",
                            examples = @ExampleObject(value = SwaggerExamples.FAVORITE409_1)))
    })
    @PostMapping("/favorites")
    public ResponseEntity<ApiResponse<FavoriteResponse>> create(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody CreateFavoriteRequest request
    ) {
        FavoriteResponse response = favoriteService.create(memberId, request);
        return ResponseEntity.status(201).body(ApiResponse.created("즐겨찾기를 등록했습니다.", response));
    }

    @GetMapping("/favorites")
    public ResponseEntity<ApiResponse<List<FavoriteResponse>>> getMyFavorites(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId
    ) {
        List<FavoriteResponse> response = favoriteService.getMyFavorites(memberId);
        return ResponseEntity.ok(ApiResponse.ok("내 즐겨찾기 목록을 조회했습니다.", response));
    }

    @GetMapping("/favorites/{movieId}")
    public ResponseEntity<ApiResponse<FavoriteStatusResponse>> getStatus(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long movieId
    ) {
        FavoriteStatusResponse response = favoriteService.getStatus(memberId, movieId);
        return ResponseEntity.ok(ApiResponse.ok("즐겨찾기 여부를 조회했습니다.", response));
    }

    // 204는 본문을 보낼 수 없어 공통 응답 형식을 지키려고 200으로 응답한다
    @DeleteMapping("/favorites/{movieId}")
    public ResponseEntity<ApiResponse<Void>> delete(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long movieId
    ) {
        favoriteService.delete(memberId, movieId);
        return ResponseEntity.ok(ApiResponse.ok("즐겨찾기를 해제했습니다.", null));
    }
}
