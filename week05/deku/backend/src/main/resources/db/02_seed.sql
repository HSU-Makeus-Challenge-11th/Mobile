INSERT IGNORE INTO member (member_id, email, password, nickname)
VALUES
    (1, 'noco@umc.com', '$2a$10$dummyEncodedPasswordValue', '수현'),
    (2, 'minseo@umc.com', '$2a$10$dummyEncodedPasswordValue', '민서');

INSERT IGNORE INTO rating (rating_id, member_id, movie_id, score, comment)
VALUES
    (1, 1, 550, 5, '최고의 영화!'),
    (2, 1, 155, 4, '다시 봐도 명작'),
    (3, 2, 550, 3, '호불호가 갈릴 것 같아요');
