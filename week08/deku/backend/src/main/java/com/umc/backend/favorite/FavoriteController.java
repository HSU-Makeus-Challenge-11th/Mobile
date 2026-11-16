package com.umc.backend.favorite;

import com.umc.backend.auth.AuthInterceptor;
import com.umc.backend.common.ApiResponse;
import com.umc.backend.favorite.dto.FavoriteCreateRequest;
import com.umc.backend.favorite.dto.FavoriteResponse;
import com.umc.backend.favorite.dto.FavoriteStatusResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping("/favorites")
    public ResponseEntity<ApiResponse<FavoriteResponse>> create(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @Valid @RequestBody FavoriteCreateRequest request
    ) {
        FavoriteResponse response = favoriteService.create(memberId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("COMMON201", "즐겨찾기를 등록했습니다.", response));
    }

    @GetMapping("/favorites")
    public ApiResponse<List<FavoriteResponse>> getAll(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId
    ) {
        return ApiResponse.success(
                "COMMON200", "즐겨찾기 목록을 조회했습니다.", favoriteService.getAll(memberId)
        );
    }

    @GetMapping("/favorites/{movieId}")
    public ApiResponse<FavoriteStatusResponse> getStatus(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable @Positive(message = "movieId는 양수여야 합니다.") Long movieId
    ) {
        return ApiResponse.success(
                "COMMON200", "즐겨찾기 여부를 조회했습니다.",
                favoriteService.getStatus(memberId, movieId)
        );
    }

    @DeleteMapping("/favorites/{movieId}")
    public ApiResponse<Void> delete(
            @RequestAttribute(AuthInterceptor.MEMBER_ID) Long memberId,
            @PathVariable @Positive(message = "movieId는 양수여야 합니다.") Long movieId
    ) {
        favoriteService.delete(memberId, movieId);
        return ApiResponse.success("COMMON200", "즐겨찾기를 해제했습니다.", null);
    }
}
