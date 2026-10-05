package com.umc.study.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "book")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "book_id")
    private Long bookId;

    // 도서 여러 권은 하나의 카테고리에 속한다 (category 1 : N book)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    // MySQL BOOLEAN은 TINYINT(1)로 만들어지므로 validate가 통과하도록 TINYINT로 맞춘다
    @Column(name = "is_available", nullable = false, columnDefinition = "TINYINT")
    private Boolean isAvailable = true;

    protected Book() {
    }

    public Book(Category category, String title, String description) {
        this.category = category;
        this.title = title;
        this.description = description;
    }

    public Long getBookId() {
        return bookId;
    }

    public Category getCategory() {
        return category;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public Boolean getIsAvailable() {
        return isAvailable;
    }
}
