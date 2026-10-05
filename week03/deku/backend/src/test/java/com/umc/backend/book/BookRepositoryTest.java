package com.umc.backend.book;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;

@ExtendWith(MockitoExtension.class)
class BookRepositoryTest {

    @Mock
    private JdbcTemplate jdbcTemplate;

    @InjectMocks
    private BookRepository bookRepository;

    @Test
    void categoryId를_바인딩해_도서_목록을_조회한다() {
        List<Map<String, Object>> expected = List.of(Map.of("book_id", 1L, "category_id", 2L));
        when(jdbcTemplate.queryForList(contains("WHERE category_id = ?"), eq(2L)))
                .thenReturn(expected);

        List<Map<String, Object>> result = bookRepository.findByCategoryId(2L);

        assertThat(result).isEqualTo(expected);
        verify(jdbcTemplate).queryForList(contains("WHERE category_id = ?"), eq(2L));
    }
}
