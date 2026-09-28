package com.umc.study.repository;

import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class BookRepository {
    private final JdbcTemplate jdbcTemplate;

    public BookRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> findAll() {
        return jdbcTemplate.queryForList("SELECT * FROM book");
    }

    public List<Map<String, Object>> findByCategoryId(Long categoryId) {
        return jdbcTemplate.queryForList("SELECT * FROM book WHERE category_id = ?", categoryId);
    }

    public int save(Long categoryId, String title, String description) {
        return jdbcTemplate.update(
                "INSERT INTO book(category_id, title, description, is_available) VALUES (?, ?, ?, true)",
                categoryId, title, description);
    }
}
