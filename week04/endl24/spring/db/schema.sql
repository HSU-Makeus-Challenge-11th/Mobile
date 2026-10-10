-- =========================================
-- 0. 데이터베이스 초기화 (몇 번 실행해도 처음 상태로 돌아감)
--    주의: mydb의 기존 데이터가 모두 지워집니다.
-- =========================================
DROP DATABASE IF EXISTS mydb;
CREATE DATABASE mydb DEFAULT CHARACTER SET utf8mb4;
USE mydb;

-- =========================================
-- 1. 테이블 구조 (DDL)
-- =========================================
CREATE TABLE users (
    user_id  BIGINT PRIMARY KEY AUTO_INCREMENT,
    nickname VARCHAR(30) NOT NULL
);

CREATE TABLE category (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL
);

CREATE TABLE book (
    book_id      BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_id  BIGINT NOT NULL,
    title        VARCHAR(100) NOT NULL,
    description  TEXT,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES category (category_id),
    -- 4주차: 같은 제목의 도서 중복 등록 방지
    CONSTRAINT uk_book_title UNIQUE (title)
);

CREATE TABLE rental (
    rental_id   BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id     BIGINT NOT NULL,
    book_id     BIGINT NOT NULL,
    rented_at   DATETIME NOT NULL,
    due_at      DATETIME NOT NULL,
    returned_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (book_id) REFERENCES book (book_id)
);

CREATE TABLE tag (
    tag_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name   VARCHAR(30) NOT NULL
);

CREATE TABLE book_tag (
    book_id BIGINT,
    tag_id  BIGINT,
    PRIMARY KEY (book_id, tag_id),
    FOREIGN KEY (book_id) REFERENCES book (book_id),
    FOREIGN KEY (tag_id)  REFERENCES tag (tag_id)
);

CREATE TABLE book_like (
    user_id BIGINT,
    book_id BIGINT,
    PRIMARY KEY (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (book_id) REFERENCES book (book_id)
);

CREATE TABLE notification (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT NOT NULL,
    type            VARCHAR(30) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);
