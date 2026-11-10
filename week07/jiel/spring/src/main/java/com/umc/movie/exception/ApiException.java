package com.umc.movie.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class ApiException extends RuntimeException{
    private final HttpStatus status; //응답으로 내보낼 HTTP 상태 코드
    private final String code; // 응답 바디의 code필드에 실릴 문자열

    public ApiException(HttpStatus status, String code, String message){
        super(message);
        this.status = status;
        this.code = code;
    }
}
