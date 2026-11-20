package com.umc.movie.controller;

import com.umc.movie.config.SwaggerConfig;
import com.umc.movie.config.SwaggerExamples;
import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.CreateRatingRequest;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.dto.UpdateRatingRequest;
import com.umc.movie.interceptor.AuthInterceptor;
import com.umc.movie.service.RatingService;
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

@RestController
@RequiredArgsConstructor
@Tag(name = "평점", description = "영화 평점 조회와 등록·수정·삭제 API")
public class RatingController {

    private final RatingService ratingService;

    // 누구나 볼 수 있는 공개 목록이라 토큰을 받지 않는다
    @Operation(
            summary = "유저별 평점 조회",
            description = "회원 한 명이 남긴 평점을 최근 등록 순서로 돌려줍니다. 토큰 없이 누구나 볼 수 있는 공개 API이고, 공통 응답으로 감싸지 않은 배열을 돌려줍니다."
    )
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "200", description = "조회 성공 (없으면 빈 배열)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.MEMBER_RATINGS))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "400", description = "회원 ID가 숫자가 아님 (COMMON4001)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.PATH_400))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "404", description = "없는 회원 (MEMBER404_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.MEMBER404_1)))
    })
    @GetMapping("/members/{memberId}/ratings")
    public List<RatingResponse> getMemberRatings(@PathVariable Long memberId) {
        return ratingService.getRatingsByMember(memberId);
    }

    @Operation(
            summary = "평점 등록",
            description = "토큰의 주인인 회원이 영화에 평점을 남깁니다. 같은 영화에는 한 번만 남길 수 있습니다."
    )
    @SecurityRequirement(name = SwaggerConfig.BEARER_AUTH)
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "201", description = "등록 성공",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING_CREATED))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "400", description = "영화 ID·별점 규칙 위반 (COMMON4001)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.SCORE_400))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "401", description = "토큰 없음 (AUTH401_2), 잘못된 토큰 (AUTH401_3), 만료된 토큰 (AUTH401_4)",
                    content = @Content(mediaType = "application/json", examples = {
                            @ExampleObject(name = "AUTH401_2", value = SwaggerExamples.AUTH401_2),
                            @ExampleObject(name = "AUTH401_3", value = SwaggerExamples.AUTH401_3),
                            @ExampleObject(name = "AUTH401_4", value = SwaggerExamples.AUTH401_4)})),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "404", description = "토큰의 회원이 없음 (MEMBER404_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.MEMBER404_1))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "409", description = "이미 이 영화에 평점을 남김 (RATING409_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING409_1)))
    })
    @PostMapping("/ratings")
    public ResponseEntity<ApiResponse<RatingResponse>> create(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody CreateRatingRequest request
    ) {
        RatingResponse response = ratingService.create(memberId, request);
        return ResponseEntity.status(201).body(ApiResponse.created("평점을 등록했습니다.", response));
    }

    @Operation(
            summary = "평점 수정",
            description = "내가 남긴 평점의 별점과 후기를 바꿉니다. 다른 회원의 평점은 수정할 수 없습니다."
    )
    @SecurityRequirement(name = SwaggerConfig.BEARER_AUTH)
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "200", description = "수정 성공",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING_UPDATED))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "400", description = "별점 규칙 위반 또는 평점 ID가 숫자가 아님 (COMMON4001)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.SCORE_400))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "401", description = "토큰 없음 (AUTH401_2), 잘못된 토큰 (AUTH401_3), 만료된 토큰 (AUTH401_4)",
                    content = @Content(mediaType = "application/json", examples = {
                            @ExampleObject(name = "AUTH401_2", value = SwaggerExamples.AUTH401_2),
                            @ExampleObject(name = "AUTH401_3", value = SwaggerExamples.AUTH401_3),
                            @ExampleObject(name = "AUTH401_4", value = SwaggerExamples.AUTH401_4)})),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "403", description = "남의 평점 (RATING403_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING403_1))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "404", description = "없는 평점 (RATING404_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING404_1)))
    })
    @PatchMapping("/ratings/{ratingId}")
    public ResponseEntity<ApiResponse<RatingResponse>> update(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long ratingId,
            @Valid @RequestBody UpdateRatingRequest request
    ) {
        RatingResponse response = ratingService.update(memberId, ratingId, request);
        return ResponseEntity.ok(ApiResponse.ok("평점을 수정했습니다.", response));
    }

    // 204는 본문을 보낼 수 없어 공통 응답 형식을 지키려고 200으로 응답한다
    @Operation(
            summary = "평점 삭제",
            description = "내가 남긴 평점을 지웁니다. 본문을 보내려고 204 대신 200과 result null로 응답합니다."
    )
    @SecurityRequirement(name = SwaggerConfig.BEARER_AUTH)
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "200", description = "삭제 성공",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING_DELETED))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "400", description = "평점 ID가 숫자가 아님 (COMMON4001)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.PATH_400))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "401", description = "토큰 없음 (AUTH401_2), 잘못된 토큰 (AUTH401_3), 만료된 토큰 (AUTH401_4)",
                    content = @Content(mediaType = "application/json", examples = {
                            @ExampleObject(name = "AUTH401_2", value = SwaggerExamples.AUTH401_2),
                            @ExampleObject(name = "AUTH401_3", value = SwaggerExamples.AUTH401_3),
                            @ExampleObject(name = "AUTH401_4", value = SwaggerExamples.AUTH401_4)})),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "403", description = "남의 평점 (RATING403_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING403_1))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "404", description = "없는 평점 (RATING404_1)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.RATING404_1)))
    })
    @DeleteMapping("/ratings/{ratingId}")
    public ResponseEntity<ApiResponse<Void>> delete(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable Long ratingId
    ) {
        ratingService.delete(memberId, ratingId);
        return ResponseEntity.ok(ApiResponse.ok("평점을 삭제했습니다.", null));
    }
}
