package com.umc.backend.exception;

import com.fasterxml.jackson.databind.exc.InvalidFormatException;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice // 모든 컨트롤러의 예외를 여기서 처리
public class GlobalExceptionHandler {

    // DTO 검증(@Valid) 실패 → 400 + 필드별 메시지
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidation(MethodArgumentNotValidException e) {
        Map<String, String> errors = new HashMap<>();
        e.getBindingResult().getFieldErrors()
                .forEach(err -> errors.put(err.getField(), err.getDefaultMessage()));
        return ResponseEntity.badRequest().body(errors);
    }

    // 서비스에서 던진 IllegalArgumentException (예: 존재하지 않는 카테고리) → 400 + 메시지
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArgument(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
    }

    // JSON → DTO 변환 실패 (예: categoryId에 "abc") → 400 + 메시지
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, String>> handleNotReadable(HttpMessageNotReadableException e) {
        // 타입이 안 맞는 경우: 어느 필드인지 꺼내서 알려줌
        if (e.getCause() instanceof InvalidFormatException ife && !ife.getPath().isEmpty()) {
            String field = ife.getPath().get(ife.getPath().size() - 1).getFieldName();
            return ResponseEntity.badRequest()
                    .body(Map.of(field, "타입이 올바르지 않습니다. (입력값: " + ife.getValue() + ")"));
        }
        // 그 외: 중괄호 누락 등 JSON 문법 자체가 깨진 경우
        return ResponseEntity.badRequest()
                .body(Map.of("message", "요청 본문(JSON) 형식이 올바르지 않습니다."));
    }
}