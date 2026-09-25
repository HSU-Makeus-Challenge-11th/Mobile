// src/main/java/.../service/BookService.java
package com.umc.backend.service;

import com.umc.backend.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service // 비즈니스 로직을 수행하는 메인 셰프 계층
@RequiredArgsConstructor
public class BookService {

    // 창고지기(Repository)를 생성자 주입으로 데려옵니다.
    private final BookRepository bookRepository;

    // 모든 도서 조회
    public List<Map<String, Object>> getAllBooks() {
        // 지금은 별도 가공 없이 창고지기가 가져온 도서 목록을 그대로 반환합니다.
        return bookRepository.findAll();
    }

    // 경로 변수로 categoryId를 받아 해당 카테고리 도서 목록 조회
    public List<Map<String, Object>> getBooksByCategoryId(Long categoryId){
        return bookRepository.findBooksByCategoryId(categoryId);
    }


    public void createBook(Map<String, Object> body){
        bookRepository.save(body);
    }
}