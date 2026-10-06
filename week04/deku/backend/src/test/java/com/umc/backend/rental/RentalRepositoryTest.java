package com.umc.backend.rental;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;

@ExtendWith(MockitoExtension.class)
class RentalRepositoryTest {

    @Mock
    private JdbcTemplate jdbcTemplate;

    @InjectMocks
    private RentalRepository rentalRepository;

    @Test
    void 현재_시간과_7일_뒤를_계산해_대여를_생성한다() {
        when(jdbcTemplate.update(contains("DATE_ADD(NOW(), INTERVAL 7 DAY)"), eq(1L), eq(3L)))
                .thenReturn(1);

        int affectedRows = rentalRepository.create(1L, 3L);

        assertThat(affectedRows).isEqualTo(1);
        verify(jdbcTemplate).update(contains("DATE_ADD(NOW(), INTERVAL 7 DAY)"), eq(1L), eq(3L));
    }
}
