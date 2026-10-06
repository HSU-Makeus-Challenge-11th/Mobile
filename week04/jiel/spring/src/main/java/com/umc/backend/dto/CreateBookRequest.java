package com.umc.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateBookRequest(
        @NotNull(message = "없는 카테고리입니다.") Long categoryId,
        @NotBlank(message = "제목은 필수입니다.") @Size(max = 100) String title,
        String description
) {}

