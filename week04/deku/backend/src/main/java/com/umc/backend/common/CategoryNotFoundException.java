package com.umc.backend.common;

public class CategoryNotFoundException extends RuntimeException {

    public CategoryNotFoundException(long categoryId) {
        super("존재하지 않는 카테고리입니다. categoryId=" + categoryId);
    }
}
