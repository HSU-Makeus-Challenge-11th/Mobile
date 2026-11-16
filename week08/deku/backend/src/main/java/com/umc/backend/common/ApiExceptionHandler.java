package com.umc.backend.common;

import jakarta.validation.ConstraintViolationException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ApiResponse<Void>> handleApiException(ApiException exception) {
        return ResponseEntity.status(exception.getStatus())
                .body(ApiResponse.failure(exception.getCode(), exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException exception) {
        String message = exception.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .orElse("요청 값을 확인해주세요.");
        return ResponseEntity.badRequest()
                .body(ApiResponse.failure("COMMON400", message));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleBadRequest(IllegalArgumentException exception) {
        return ResponseEntity.badRequest()
                .body(ApiResponse.failure("COMMON400", exception.getMessage()));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleConstraintViolation(ConstraintViolationException exception) {
        String message = exception.getConstraintViolations().stream()
                .findFirst()
                .map(violation -> violation.getMessage())
                .orElse("요청 값을 확인해주세요.");
        return ResponseEntity.badRequest()
                .body(ApiResponse.failure("COMMON400", message));
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<ApiResponse<Void>> handleUnreadableRequest() {
        return ResponseEntity.badRequest()
                .body(ApiResponse.failure("COMMON400", "요청 값의 형식이 올바르지 않습니다."));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleDataIntegrityViolation(
            DataIntegrityViolationException exception
    ) {
        String detail = String.valueOf(exception.getMostSpecificCause().getMessage()).toLowerCase();

        if (detail.contains("uk_member_email")) {
            return conflict("MEMBER4091", "이미 사용 중인 이메일입니다.");
        }
        if (detail.contains("uk_member_nickname")) {
            return conflict("MEMBER409_1", "이미 사용 중인 닉네임입니다.");
        }
        if (detail.contains("uk_rating_member_movie")) {
            return conflict("RATING409_1", "이미 이 영화에 평점을 남기셨습니다.");
        }
        if (detail.contains("uk_favorite_member_movie")) {
            return conflict("FAVORITE409_1", "이미 즐겨찾기한 영화입니다.");
        }

        return conflict("COMMON409", "중복된 데이터로 인해 요청을 처리할 수 없습니다.");
    }

    private ResponseEntity<ApiResponse<Void>> conflict(String code, String message) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResponse.failure(code, message));
    }
}
