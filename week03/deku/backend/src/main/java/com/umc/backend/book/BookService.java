package com.umc.backend.book;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;

    public List<Map<String, Object>> getBooks() {
        return bookRepository.findAll();
    }

    public List<Map<String, Object>> getBooksByCategory(long categoryId) {
        if (categoryId <= 0) {
            throw new IllegalArgumentException("categoryId는 1 이상의 숫자여야 합니다.");
        }
        return bookRepository.findByCategoryId(categoryId);
    }

    public Map<String, Object> createBook(Map<String, Object> body) {
        long categoryId = requiredLong(body, "categoryId");
        String title = requiredText(body, "title");
        String description = body.get("description") == null ? null : body.get("description").toString();
        boolean isAvailable = body.get("isAvailable") == null
                || Boolean.parseBoolean(body.get("isAvailable").toString());

        int affectedRows = bookRepository.create(categoryId, title, description, isAvailable);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("message", "도서가 등록되었습니다.");
        response.put("categoryId", categoryId);
        response.put("title", title);
        response.put("affectedRows", affectedRows);
        return response;
    }

    private long requiredLong(Map<String, Object> body, String key) {
        Object value = body.get(key);
        if (value == null) {
            throw new IllegalArgumentException(key + "는 필수입니다.");
        }
        try {
            long parsedValue = Long.parseLong(value.toString());
            if (parsedValue <= 0) {
                throw new NumberFormatException();
            }
            return parsedValue;
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(key + "는 1 이상의 숫자여야 합니다.");
        }
    }

    private String requiredText(Map<String, Object> body, String key) {
        Object value = body.get(key);
        if (value == null || value.toString().isBlank()) {
            throw new IllegalArgumentException(key + "는 필수입니다.");
        }
        return value.toString().trim();
    }
}
