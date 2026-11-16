package com.umc.movie.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

// boolean 필드 isFavorite는 Jackson이 "favorite"로 줄일 수 있어 이름을 고정한다
public record FavoriteStatusResponse(
        @JsonProperty("isFavorite") boolean isFavorite
) {
}
