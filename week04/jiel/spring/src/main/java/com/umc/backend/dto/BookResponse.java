package com.umc.backend.dto;
import com.umc.backend.entity.Book;

public record BookResponse(
        Long bookId,
        String title,
        String description,
        String categoryName,
        Boolean isAvailable
) {
    public static BookResponse from(Book book) {
        return new BookResponse(
                book.getBookId(),
                book.getTitle(),
                book.getDescription(),
                book.getCategory().getName(),
                book.getIsAvailable()
        );
    }
}
