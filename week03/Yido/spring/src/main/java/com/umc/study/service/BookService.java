package com.umc.study.service;

import com.umc.study.repository.BookRepository;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class BookService {
    private final BookRepository bookRepository;

    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    public List<Map<String, Object>> getBooks() {
        return bookRepository.findAll();
    }

    public List<Map<String, Object>> getBooksByCategory(Long categoryId) {
        return bookRepository.findByCategoryId(categoryId);
    }

    public void createBook(Map<String, Object> request) {
        bookRepository.save(
                ((Number) request.get("categoryId")).longValue(),
                (String) request.get("title"),
                (String) request.get("description"));
    }
}
