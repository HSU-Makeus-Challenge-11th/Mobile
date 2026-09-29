// src/main/java/.../repository/BookRepository.java
package com.umc.backend.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository // 스프링 컨테이너에 "나 창고지기 부품이야!"라고 등록
@RequiredArgsConstructor
public class BookRepository {

    // 2단계에서 준비된 스프링의 DB 통신 도구(JdbcTemplate) 주입
    private final JdbcTemplate jdbcTemplate;

    public List<Map<String, Object>> findAll() {
        String sql = "SELECT * FROM book";

        // 쿼리를 실행하고 결과를 List<Map> 형태의 날것 데이터로 긁어옵니다.
        // Map의 Key는 '컬럼명(title)', Value는 '실제 데이터(달빛 도서관)'가 됩니다.
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> findBooksByCategoryId(Long categoryId){
        String sql = "SELECT * FROM book b WHERE b.category_id = ?";

        return jdbcTemplate.queryForList(sql, categoryId);
    }

    public void save(Map<String, Object> body){
        // book_id는 AUTO_INCREMENT이므로 생략, is_available은 기본 true로 삽입
        String sql = "INSERT INTO book (category_id, title, description, is_available) VALUES (?, ?, ?, true)";

        // SQL 뒤에 파라미터를 차례대로 넘겨주면 ? 자리에 순서대로 안전하게 바인딩 됩니다.
        jdbcTemplate.update(
                sql,
                body.get("categoryId"),
                body.get("title"),
                body.get("description")
        );
    }

    //userId와 bookId를 전달받아 오늘대여, 일주일뒤 반납 rental행 추가
    public void insertRental(Map<String, Object> body){
        // 책을 빌릴 수 있는 상태인지 확인
        String updateSql = "UPDATE book SET book.is_available = 0 WHERE book.book_id = ? AND book.is_available = 1";
        int update = jdbcTemplate.update(updateSql, body.get("bookId"));
        if (update == 0){
            throw new IllegalStateException("이미 대여 중이거나 존재하지 않는 책입니다.");
        }

        //대여날짜와 반납날짜 기록
        String sql = "INSERT INTO rental(user_id, book_id, rented_at, due_at) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY))";

        jdbcTemplate.update(
                sql,
                body.get("userId"),
                body.get("bookId")
        );


    }

    //rentalId로 대여 기록을 찾아 반납 처리(returned_at 갱신) 및 도서를 대여 가능 상태로 변경
    public void returnRental(Long rentalId) {
        String findBookIdSql = "SELECT book_id FROM rental WHERE rental_id = ?";
        Long bookId;
        try {
            bookId = jdbcTemplate.queryForObject(findBookIdSql, Long.class, rentalId);
        } catch (EmptyResultDataAccessException e) {
            throw new IllegalStateException("존재하지 않는 대여 기록입니다.");
        }

        String updateRentalSql = "UPDATE rental SET returned_at = NOW() WHERE rental_id = ?";
        jdbcTemplate.update(updateRentalSql, rentalId);

        String updateBookSql = "UPDATE book SET is_available = 1 WHERE book_id = ?";
        jdbcTemplate.update(updateBookSql, bookId);
    }

}