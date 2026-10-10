package com.umc.study;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.umc.study.domain.Book;
import com.umc.study.domain.Category;
import com.umc.study.repository.BookRepository;
import com.umc.study.repository.CategoryRepository;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

@DataJpaTest
@TestPropertySource(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class BookRepositoryTest {
    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Test
    void savesBookWithCategoryAndFindsLatestFirst() {
        Category literature = categoryRepository.save(new Category("문학"));
        Category science = categoryRepository.save(new Category("과학"));
        Book first = bookRepository.save(new Book(literature, "O'Reilly 클린 코드", null));
        Book second = bookRepository.save(new Book(science, "우주를 읽는 법", "과학 교양"));

        List<Book> books = bookRepository.findAllByOrderByBookIdDesc();

        assertEquals(List.of(second.getBookId(), first.getBookId()),
                books.stream().map(Book::getBookId).toList());
        assertEquals("과학", books.get(0).getCategory().getName());
        assertTrue(books.get(1).getIsAvailable());
        assertEquals(1, bookRepository.findByCategory_CategoryIdOrderByBookIdDesc(literature.getCategoryId()).size());
    }
}
