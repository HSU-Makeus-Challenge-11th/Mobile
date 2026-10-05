package com.umc.study.repository;

import com.umc.study.domain.Book;
import java.util.List;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookRepository extends JpaRepository<Book, Long> {
    // 카테고리 이름을 함께 쓰므로 category를 한 번에 가져와 N+1을 피한다
    @EntityGraph(attributePaths = "category")
    List<Book> findAllByOrderByBookIdDesc();

    @EntityGraph(attributePaths = "category")
    List<Book> findByCategory_CategoryIdOrderByBookIdDesc(Long categoryId);
}
