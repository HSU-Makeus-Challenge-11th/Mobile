package com.umc.backend.book;

import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class BookRepository {

    private final JdbcTemplate jdbcTemplate;

    public List<Map<String, Object>> findAll() {
        String sql = "SELECT * FROM book ORDER BY book_id";
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> findByCategoryId(long categoryId) {
        String sql = "SELECT * FROM book WHERE category_id = ? ORDER BY book_id";
        return jdbcTemplate.queryForList(sql, categoryId);
    }

    public int create(long categoryId, String title, String description, boolean isAvailable) {
        String sql = """
                INSERT INTO book (category_id, title, description, is_available)
                VALUES (?, ?, ?, ?)
                """;
        return jdbcTemplate.update(sql, categoryId, title, description, isAvailable);
    }
}
