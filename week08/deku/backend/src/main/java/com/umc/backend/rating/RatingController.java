package com.umc.backend.rating;

import com.umc.backend.auth.AuthInterceptor;
import com.umc.backend.common.ApiResponse;
import com.umc.backend.rating.dto.RatingCreateRequest;
import com.umc.backend.rating.dto.RatingResponse;
import com.umc.backend.rating.dto.RatingUpdateRequest;
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

@Validated
@RestController
@RequiredArgsConstructor
public class RatingController {

    private final RatingService ratingService;

    @PostMapping("/ratings")
    public ResponseEntity<ApiResponse<RatingResponse>> createRating(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody RatingCreateRequest request
    ) {
        RatingResponse response = ratingService.createRating(memberId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("COMMON201", "평점 등록에 성공했습니다.", response));
    }

    @PatchMapping("/ratings/{ratingId}")
    public ApiResponse<RatingResponse> updateRating(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
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
    public ApiResponse<Void> deleteRating(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable @Positive(message = "ratingId는 양수여야 합니다.") Long ratingId
    ) {
        ratingService.deleteRating(memberId, ratingId);
        return ApiResponse.success("COMMON200", "평점 삭제에 성공했습니다.", null);
    }

    @GetMapping("/members/{memberId}/ratings")
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
