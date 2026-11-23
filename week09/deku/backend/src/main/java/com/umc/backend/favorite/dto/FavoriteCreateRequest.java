package com.umc.backend.favorite.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record FavoriteCreateRequest(
        @NotNull(message = "movieId는 필수입니다.")
        @Positive(message = "movieId는 양수여야 합니다.")
        Long movieId
) {
}
