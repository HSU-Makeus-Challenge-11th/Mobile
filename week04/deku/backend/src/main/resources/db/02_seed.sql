USE study;

INSERT IGNORE INTO category (category_id, name)
VALUES
    (1, '문학'),
    (2, '과학');

INSERT IGNORE INTO users (user_id, nickname)
VALUES
    (1, '민서'),
    (2, '수현');

INSERT IGNORE INTO book (book_id, category_id, title, description, is_available)
VALUES
    (1, 1, '달빛 도서관', '별빛 아래 펼쳐지는 도서관 이야기', TRUE),
    (2, 1, '작별하지 않는다', '기억과 사랑에 관한 소설', TRUE),
    (3, 2, '코스모스', '우주를 이해하는 과학 교양서', TRUE);
