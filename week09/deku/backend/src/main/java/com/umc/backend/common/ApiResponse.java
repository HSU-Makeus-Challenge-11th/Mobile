package com.umc.backend.common;

public record ApiResponse<T>(
        boolean isSuccess,
        String code,
        String message,
        T result
) {
    public static <T> ApiResponse<T> success(String code, String message, T result) {
        return new ApiResponse<>(true, code, message, result);
    }

    public static ApiResponse<Void> failure(String code, String message) {
        return new ApiResponse<>(false, code, message, null);
    }
}
