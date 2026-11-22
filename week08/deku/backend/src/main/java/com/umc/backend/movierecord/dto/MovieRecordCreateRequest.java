package com.umc.backend.movierecord.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record MovieRecordCreateRequest(
        @NotNull(message = "movieId는 필수입니다.")
        @Positive(message = "movieId는 양수여야 합니다.")
        Long movieId,

        @NotNull(message = "score는 필수입니다.")
        @Min(value = 1, message = "score는 1점 이상이어야 합니다.")
        @Max(value = 5, message = "score는 5점 이하여야 합니다.")
        Integer score,

        @Size(max = 500, message = "comment는 500자를 넘을 수 없습니다.")
        String comment,

        @NotNull(message = "addToFavorites는 필수입니다.")
        Boolean addToFavorites
) {
}
