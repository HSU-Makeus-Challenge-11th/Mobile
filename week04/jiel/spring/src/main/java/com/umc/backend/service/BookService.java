// src/main/java/.../service/BookService.java
package com.umc.backend.service;

import com.umc.backend.repository.BookRepository;
import com.umc.backend.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import com.umc.backend.dto.BookResponse;
import com.umc.backend.dto.CreateBookRequest;
import com.umc.backend.entity.Book;
import com.umc.backend.entity.Category;

@Service // 비즈니스 로직을 수행하는 메인 셰프 계층
@RequiredArgsConstructor
public class BookService {

    // 창고지기(Repository)를 생성자 주입으로 데려옵니다.
    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;

    // ORM기반 구조로 리팩토링
    @Transactional
    public List<BookResponse> getBooks() {
        return bookRepository.findAllByOrderByBookIdDesc()
                .stream().map(BookResponse::from).toList();
    }

    // Post /books
    @Transactional
    public BookResponse createBook(CreateBookRequest request) {
        Category category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 카테고리입니다."));

        Book book = new Book(category, request.title(), request.description());
        return BookResponse.from(bookRepository.save(book));
    }
}



    // 기존 Raw SQL 코드
//import java.util.Map;
//@Service // 비즈니스 로직을 수행하는 메인 셰프 계층
//@RequiredArgsConstructor
//public class BookService {
//
//    // 창고지기(Repository)를 생성자 주입으로 데려옵니다.
//    private final BookRepository bookRepository;
//    private final CategoryRepository categoryRepository;
//
//    // 모든 도서 조회
//    public List<Map<String, Object>> getAllBooks() {
//        // 지금은 별도 가공 없이 창고지기가 가져온 도서 목록을 그대로 반환합니다.
//        return bookRepository.findAll();
//    }
    // 경로 변수로 categoryId를 받아 해당 카테고리 도서 목록 조회
//    public List<Map<String, Object>> getBooksByCategoryId(Long categoryId){
//        return bookRepository.findBooksByCategoryId(categoryId);
//    }
//
//
//    public void createBook(Map<String, Object> body){
//        bookRepository.save(body);
//    }
//
//    public void rentBook(Map<String, Object> body){
//        bookRepository.insertRental(body);
//    }
//
//    public void returnRental(Long rentalId){
//        bookRepository.returnRental(rentalId);
//    }
//}