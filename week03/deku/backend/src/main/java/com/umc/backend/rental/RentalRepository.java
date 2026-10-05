package com.umc.backend.rental;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class RentalRepository {

    private final JdbcTemplate jdbcTemplate;

    public int create(long userId, long bookId) {
        String sql = """
                INSERT INTO rental (user_id, book_id, rented_at, due_at, returned_at)
                VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NULL)
                """;
        return jdbcTemplate.update(sql, userId, bookId);
    }
}
