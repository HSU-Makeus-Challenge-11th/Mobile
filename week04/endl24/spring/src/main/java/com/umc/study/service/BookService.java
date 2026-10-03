package com.umc.study.service;

import com.umc.study.dto.BookResponse;
import com.umc.study.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service // 비즈니스 로직을 수행하는 메인 셰프 계층
@RequiredArgsConstructor
public class BookService {

    // 창고지기(Repository)를 생성자 주입으로 데려옵니다.
    private final BookRepository bookRepository;

    @Transactional(readOnly = true)
    public List<BookResponse> getBooks() {
        return bookRepository.findAllByOrderByBookIdDesc()
                .stream()
                .map(BookResponse::from)   // Book 하나하나를 BookResponse로 변환
                .toList();
    }

    @Transactional(readOnly = true)
    public List<BookResponse> getBooksByCategory(Long categoryId) {
        return bookRepository.findByCategory_CategoryIdOrderByBookIdDesc(categoryId)
                .stream()
                .map(BookResponse::from)
                .toList();
    }
//    public void createBook(Map<String, Object> body){
//        bookRepository.save(body);
//    }
}