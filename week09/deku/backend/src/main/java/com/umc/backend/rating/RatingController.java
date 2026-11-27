package com.umc.backend.rating;

import com.umc.backend.auth.AuthInterceptor;
import com.umc.backend.common.ApiResponse;
import com.umc.backend.rating.dto.RatingCreateRequest;
import com.umc.backend.rating.dto.RatingResponse;
import com.umc.backend.rating.dto.RatingUpdateRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "평점")
@Validated
@RestController
@RequiredArgsConstructor
public class RatingController {

    private final RatingService ratingService;

    @PostMapping("/ratings")
    @Operation(summary = "평점 등록", description = "인증 필요. 영화에 1~5점의 평점을 등록합니다.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "201", description = "COMMON201: 등록 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "COMMON400: 입력 값 오류"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "AUTH401_2/3/4: 토큰 누락, 무효 또는 만료"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "409", description = "RATING409_1: 같은 영화 평점 중복")
    })
    public ResponseEntity<ApiResponse<RatingResponse>> createRating(
            @Parameter(hidden = true) @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody RatingCreateRequest request
    ) {
        RatingResponse response = ratingService.createRating(memberId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("COMMON201", "평점 등록에 성공했습니다.", response));
    }

    @PatchMapping("/ratings/{ratingId}")
    @Operation(summary = "평점 수정", description = "인증 필요. 본인이 작성한 평점만 수정합니다.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "COMMON200: 수정 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "COMMON400: 입력 값 오류"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "AUTH401_2/3/4: 토큰 누락, 무효 또는 만료"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "403", description = "RATING403_1: 다른 회원의 평점"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "RATING404_1: 평점 없음")
    })
    public ApiResponse<RatingResponse> updateRating(
            @Parameter(hidden = true) @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable @Positive(message = "ratingId는 양수여야 합니다.") Long ratingId,
            @Valid @RequestBody RatingUpdateRequest request
    ) {
        return ApiResponse.success(
                "COMMON200",
                "평점 수정에 성공했습니다.",
                ratingService.updateRating(memberId, ratingId, request)
        );
    }

    @DeleteMapping("/ratings/{ratingId}")
    @Operation(summary = "평점 삭제", description = "인증 필요. 본인이 작성한 평점만 삭제합니다.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "COMMON200: 삭제 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "AUTH401_2/3/4: 토큰 누락, 무효 또는 만료"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "403", description = "RATING403_1: 다른 회원의 평점"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "RATING404_1: 평점 없음")
    })
    public ApiResponse<Void> deleteRating(
            @Parameter(hidden = true) @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable @Positive(message = "ratingId는 양수여야 합니다.") Long ratingId
    ) {
        ratingService.deleteRating(memberId, ratingId);
        return ApiResponse.success("COMMON200", "평점 삭제에 성공했습니다.", null);
    }

    @GetMapping("/members/{memberId}/ratings")
    @Operation(summary = "유저별 평점 조회", description = "공개 API. 회원의 평점을 조회합니다. page와 size를 함께 지정하면 페이지 응답을 반환합니다.")
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "COMMON200: 조회 성공"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "COMMON400: page와 size 조합 또는 범위 오류")
    })
    public ApiResponse<?> getRatings(
            @PathVariable @Positive(message = "memberId는 양수여야 합니다.") Long memberId,
            @RequestParam(required = false) @Min(value = 0, message = "page는 0 이상이어야 합니다.") Integer page,
            @RequestParam(required = false)
            @Min(value = 1, message = "size는 1 이상이어야 합니다.")
            @Max(value = 100, message = "size는 100 이하여야 합니다.") Integer size
    ) {
        if ((page == null) != (size == null)) {
            throw new IllegalArgumentException("page와 size는 함께 입력해야 합니다.");
        }

        if (page == null) {
            return ApiResponse.success(
                    "COMMON200",
                    "평점 목록 조회에 성공했습니다.",
                    ratingService.getRatings(memberId)
            );
        }

        PageRequest pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("ratingId"))
        );
        return ApiResponse.success(
                "COMMON200",
                "평점 목록 조회에 성공했습니다.",
                ratingService.getRatings(memberId, pageable)
        );
    }
}
