package com.umc.backend.book;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import com.umc.backend.book.dto.BookResponse;
import com.umc.backend.book.dto.CreateBookRequest;
import com.umc.backend.category.Category;
import com.umc.backend.category.CategoryRepository;
import com.umc.backend.common.CategoryNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class BookServiceTest {

    @Mock
    private BookRepository bookRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private BookService bookService;

    @Test
    void 도서를_최신순으로_조회하고_응답_DTO로_변환한다() {
        Category category = org.mockito.Mockito.mock(Category.class);
        Book book = org.mockito.Mockito.mock(Book.class);
        when(category.getName()).thenReturn("과학");
        when(book.getBookId()).thenReturn(3L);
        when(book.getTitle()).thenReturn("코스모스");
        when(book.getDescription()).thenReturn("우주를 이해하는 과학 교양서");
        when(book.getCategory()).thenReturn(category);
        when(book.getIsAvailable()).thenReturn(true);
        when(bookRepository.findAllByOrderByBookIdDesc()).thenReturn(List.of(book));

        List<BookResponse> result = bookService.getBooks();

        assertThat(result).containsExactly(
                new BookResponse(3L, "코스모스", "우주를 이해하는 과학 교양서", "과학", true)
        );
        verify(bookRepository).findAllByOrderByBookIdDesc();
    }

    @Test
    void 존재하는_카테고리로_도서를_등록한다() {
        Category category = org.mockito.Mockito.mock(Category.class);
        when(category.getName()).thenReturn("과학");
        when(categoryRepository.findById(2L)).thenReturn(Optional.of(category));
        when(bookRepository.save(any(Book.class))).thenAnswer(invocation -> invocation.getArgument(0));

        BookResponse result = bookService.createBook(
                new CreateBookRequest(2L, "  스프링 입문  ", "ORM 실습 도서")
        );

        assertThat(result.title()).isEqualTo("스프링 입문");
        assertThat(result.categoryName()).isEqualTo("과학");
        assertThat(result.isAvailable()).isTrue();
        verify(bookRepository).save(any(Book.class));
    }

    @Test
    void 존재하지_않는_카테고리면_예외를_발생시킨다() {
        when(categoryRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> bookService.createBook(
                new CreateBookRequest(999L, "스프링 입문", null)
        ))
                .isInstanceOf(CategoryNotFoundException.class)
                .hasMessageContaining("categoryId=999");
    }
}
