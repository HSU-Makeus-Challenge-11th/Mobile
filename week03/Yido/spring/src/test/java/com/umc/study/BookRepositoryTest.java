package com.umc.study;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import com.umc.study.repository.BookRepository;
import java.util.List;
import java.util.Map;
import javax.sql.DataSource;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

class BookRepositoryTest {
    private BookRepository bookRepository;

    @BeforeEach
    void setUp() {
        DataSource dataSource = new DriverManagerDataSource(
                "jdbc:h2:mem:book_repository;MODE=MySQL;DB_CLOSE_DELAY=-1", "sa", "");
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.execute("DROP TABLE IF EXISTS book");
        jdbcTemplate.execute("CREATE TABLE book (book_id BIGINT AUTO_INCREMENT PRIMARY KEY, category_id BIGINT NOT NULL, title VARCHAR(100) NOT NULL, description TEXT, is_available BOOLEAN NOT NULL)");
        bookRepository = new BookRepository(jdbcTemplate);
    }

    @Test
    void savesQuotedTitleAndNullableDescriptionThenFindsByCategory() {
        bookRepository.save(1L, "O'Reilly 클린 코드", null);
        bookRepository.save(2L, "다른 카테고리", "설명");

        List<Map<String, Object>> books = bookRepository.findByCategoryId(1L);

        assertEquals(1, books.size());
        assertEquals("O'Reilly 클린 코드", books.get(0).get("TITLE"));
        assertNull(books.get(0).get("DESCRIPTION"));
        assertEquals(1L, ((Number) books.get(0).get("CATEGORY_ID")).longValue());
    }
}
