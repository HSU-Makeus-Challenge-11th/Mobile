package com.umc.movie.dto;

// addToFavorites가 false였다면 favorite은 null로 나갑니다
public record MovieRecordResponse(
        RatingResponse rating,
        FavoriteResponse favorite
) {}
