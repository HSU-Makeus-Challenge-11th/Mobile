package com.umc.study.controller;

import com.umc.study.service.BookService;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/books")
public class BookController {
    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping
    public List<Map<String, Object>> getBooks() {
        return bookService.getBooks();
    }

    @GetMapping("/category/{categoryId}")
    public List<Map<String, Object>> getBooksByCategory(@PathVariable Long categoryId) {
        return bookService.getBooksByCategory(categoryId);
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> createBook(@RequestBody Map<String, Object> request) {
        bookService.createBook(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "도서 등록에 성공했습니다."));
    }
}
