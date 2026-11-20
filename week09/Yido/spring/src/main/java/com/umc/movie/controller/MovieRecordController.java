package com.umc.movie.controller;

import com.umc.movie.config.SwaggerConfig;
import com.umc.movie.config.SwaggerExamples;
import com.umc.movie.dto.ApiResponse;
import com.umc.movie.dto.CreateMovieRecordRequest;
import com.umc.movie.dto.MovieRecordResponse;
import com.umc.movie.interceptor.AuthInterceptor;
import com.umc.movie.service.MovieRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "영화 기록", description = "평점과 즐겨찾기를 한 번에 저장하는 API")
@SecurityRequirement(name = SwaggerConfig.BEARER_AUTH)
public class MovieRecordController {

    private final MovieRecordService movieRecordService;

    @Operation(
            summary = "영화 기록 저장",
            description = "평점을 남기고, addToFavorites가 true면 즐겨찾기까지 한 트랜잭션으로 저장합니다. 둘 중 하나라도 실패하면 아무것도 남지 않습니다. addToFavorites가 false면 favorite는 null입니다."
    )
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "201", description = "저장 성공",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.MOVIE_RECORD_CREATED))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(
                    responseCode = "400", description = "영화 ID·별점 규칙 위반 또는 addToFavorites 누락 (COMMON4001)",
                    content = @Content(mediaType = "application/json", examples = @ExampleObject(value = SwaggerExamples.ADD_TO_FAVORITES_400))),
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
                    responseCode = "409", description = "이미 평점을 남겼거나 (RATING409_1) 이미 즐겨찾기한 영화 (FAVORITE409_1)",
                    content = @Content(mediaType = "application/json", examples = {
                            @ExampleObject(name = "RATING409_1", value = SwaggerExamples.RATING409_1),
                            @ExampleObject(name = "FAVORITE409_1", value = SwaggerExamples.FAVORITE409_1)}))
    })
    @PostMapping("/movie-records")
    public ResponseEntity<ApiResponse<MovieRecordResponse>> create(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody CreateMovieRecordRequest request
    ) {
        MovieRecordResponse response = movieRecordService.create(memberId, request);
        return ResponseEntity.status(201).body(ApiResponse.created("영화 기록을 저장했습니다.", response));
    }
}
