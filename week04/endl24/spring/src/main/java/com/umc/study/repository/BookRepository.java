package com.umc.study.repository;

import com.umc.study.entity.Book;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookRepository extends JpaRepository<Book, Long> {
    List<Book> findAllByOrderByBookIdDesc();
    List<Book> findByCategory_CategoryIdOrderByBookIdDesc(Long categoryId);
    List<Book> findByTitleContainingOrderByBookIdDesc(String keyword);
}