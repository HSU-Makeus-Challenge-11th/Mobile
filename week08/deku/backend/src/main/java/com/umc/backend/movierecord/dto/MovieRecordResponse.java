package com.umc.backend.movierecord.dto;

import com.umc.backend.favorite.dto.FavoriteResponse;
import com.umc.backend.rating.dto.RatingResponse;

public record MovieRecordResponse(
        RatingResponse rating,
        FavoriteResponse favorite
) {
}
