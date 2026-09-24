-- =========================================================
-- 우리동네 미션 - 테이블 생성 + 더미 데이터
-- =========================================================

DROP DATABASE IF EXISTS extend_mission;
CREATE DATABASE extend_mission DEFAULT CHARACTER SET utf8mb4;
USE extend_mission;

-- ---------------------------------------------------------
-- 1. 회원 · 온보딩
-- ---------------------------------------------------------
CREATE TABLE member (
    member_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(20)  NOT NULL,
    nickname        VARCHAR(20)  NULL,
    gender          ENUM('NONE','MALE','FEMALE') NOT NULL DEFAULT 'NONE',
    birth_date      DATE         NULL,
    address         VARCHAR(100) NOT NULL,
    email           VARCHAR(50)  NULL,
    phone_num       VARCHAR(20)  NULL,
    phone_verified  BOOLEAN      NOT NULL DEFAULT FALSE,
    social_type     VARCHAR(20)  NULL,
    social_id       VARCHAR(100) NULL,
    point           BIGINT       NOT NULL DEFAULT 0,
    status          VARCHAR(10)  NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at      DATETIME     NULL
);

CREATE TABLE term (
    term_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
    title       VARCHAR(50) NOT NULL,
    body        TEXT        NULL,
    is_required BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE member_agree (
    member_agree_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id       BIGINT   NOT NULL,
    term_id         BIGINT   NOT NULL,
    agreed_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_member_term (member_id, term_id),
    FOREIGN KEY (member_id) REFERENCES member(member_id),
    FOREIGN KEY (term_id)   REFERENCES term(term_id)
);

CREATE TABLE food_category (
    kind_of_food_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    kind            VARCHAR(20) NOT NULL
);

CREATE TABLE member_prefer (
    member_prefer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id        BIGINT NOT NULL,
    kind_of_food_id  BIGINT NOT NULL,
    UNIQUE KEY uk_member_food (member_id, kind_of_food_id),
    FOREIGN KEY (member_id)       REFERENCES member(member_id),
    FOREIGN KEY (kind_of_food_id) REFERENCES food_category(kind_of_food_id)
);

-- ---------------------------------------------------------
-- 2. 가게 · 미션
-- ---------------------------------------------------------
CREATE TABLE region (
    region_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name      VARCHAR(20) NOT NULL
);

CREATE TABLE store (
    store_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    region_id       BIGINT       NOT NULL,
    kind_of_food_id BIGINT       NOT NULL,
    name            VARCHAR(50)  NOT NULL,
    address         VARCHAR(100) NULL,
    status          VARCHAR(10)  NOT NULL DEFAULT 'OPEN',
    score           FLOAT        NOT NULL DEFAULT 0,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id)       REFERENCES region(region_id),
    FOREIGN KEY (kind_of_food_id) REFERENCES food_category(kind_of_food_id)
);

CREATE TABLE mission (
    mission_id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    store_id              BIGINT   NOT NULL,
    minimum_order_amount  BIGINT   NOT NULL,
    point                 BIGINT   NOT NULL,
    deadline              DATE     NULL,
    created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

CREATE TABLE member_mission (
    member_mission_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id         BIGINT      NOT NULL,
    mission_id        BIGINT      NOT NULL,
    status            VARCHAR(15) NOT NULL DEFAULT 'CHALLENGING',  -- CHALLENGING / COMPLETE
    verify_code       VARCHAR(20) NULL,
    complete_date     DATE        NULL,
    created_at        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_member_mission (member_id, mission_id),
    FOREIGN KEY (member_id)  REFERENCES member(member_id),
    FOREIGN KEY (mission_id) REFERENCES mission(mission_id)
);

-- ---------------------------------------------------------
-- 3. 리뷰
-- ---------------------------------------------------------
CREATE TABLE review (
    review_id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id         BIGINT   NOT NULL,
    member_mission_id BIGINT   NULL UNIQUE,
    rating            FLOAT    NOT NULL,
    text              TEXT     NULL,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id)         REFERENCES member(member_id),
    FOREIGN KEY (member_mission_id) REFERENCES member_mission(member_mission_id)
);

CREATE TABLE review_image (
    review_image_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    review_id       BIGINT       NOT NULL,
    image_url       VARCHAR(255) NOT NULL,
    FOREIGN KEY (review_id) REFERENCES review(review_id)
);

-- ---------------------------------------------------------
-- 4. 알림 · 문의
-- ---------------------------------------------------------
CREATE TABLE notification (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id       BIGINT       NOT NULL,
    type            VARCHAR(30)  NOT NULL,   -- NEW_MISSION / REVIEW_REQUEST
    title           VARCHAR(50)  NOT NULL,
    text            VARCHAR(255) NULL,
    is_read         BOOLEAN      NOT NULL DEFAULT FALSE,
    time            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);

CREATE TABLE inquiry (
    inquiry_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id  BIGINT      NOT NULL,
    type       VARCHAR(30) NOT NULL,
    title      VARCHAR(50) NOT NULL,
    text       TEXT        NULL,
    status     VARCHAR(10) NOT NULL DEFAULT 'WAITING',  -- WAITING / ANSWERED
    answer     TEXT        NULL,
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);

CREATE TABLE inquiry_image (
    inquiry_image_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    inquiry_id       BIGINT       NOT NULL,
    image_url        VARCHAR(255) NOT NULL,
    FOREIGN KEY (inquiry_id) REFERENCES inquiry(inquiry_id)
);

-- ---------------------------------------------------------
-- 인덱스
-- ---------------------------------------------------------
CREATE INDEX idx_mission_store_deadline ON mission (store_id, deadline);
CREATE INDEX idx_member_mission_lookup  ON member_mission (member_id, status);
CREATE INDEX idx_store_region           ON store (region_id);


-- =========================================================
-- 더미 데이터
-- =========================================================

INSERT INTO region (name) VALUES ('안암동'), ('성신여대'), ('왕십리');

INSERT INTO food_category (kind) VALUES
('한식'), ('중식'), ('일식'), ('양식'), ('분식'), ('디저트');

INSERT INTO member (name, nickname, gender, birth_date, address, email, phone_num, phone_verified, social_type, social_id, point) VALUES
('김지원', 'nickname012', 'FEMALE', '2002-03-14', '서울시 성북구 안암동5가', 'jiwon@naver.com', '010-1111-2222', TRUE,  'KAKAO',  'kakao_1001', 2500),
('이도현', '도현이',      'MALE',   '2001-07-02', '서울시 성북구 안암동5가', 'dohyun@gmail.com', '010-3333-4444', FALSE, 'GOOGLE', 'google_2002', 500),
('박서연', '서연',        'FEMALE', '2003-11-25', '서울시 성동구 행당동',    'seoyeon@naver.com', NULL,           FALSE, 'KAKAO',  'kakao_3003', 0);

INSERT INTO term (title, body, is_required) VALUES
('만 14세 이상입니다',   '만 14세 이상 확인',      TRUE),
('서비스 이용약관',      '서비스 이용약관 본문',   TRUE),
('개인정보 처리방침',    '개인정보 처리방침 본문', TRUE),
('위치정보 제공',        '위치정보 제공 동의',     FALSE),
('마케팅 수신 동의',     '마케팅 정보 수신 동의',  FALSE);

INSERT INTO member_agree (member_id, term_id) VALUES
(1,1),(1,2),(1,3),(1,4),
(2,1),(2,2),(2,3),
(3,1),(3,2),(3,3),(3,5);

INSERT INTO member_prefer (member_id, kind_of_food_id) VALUES
(1,1),(1,2),(1,6),
(2,2),(2,5),
(3,3),(3,4);

INSERT INTO store (region_id, kind_of_food_id, name, address, status, score) VALUES
(1, 2, '반이학생마라탕',   '서울시 성북구 안암동5가 102-60', 'OPEN',   4.4),
(1, 5, '짱구분식점',       '서울시 성북구 안암동5가 87-3',   'OPEN',   4.1),
(1, 1, '안암백반',         '서울시 성북구 안암동5가 44-2',   'CLOSED', 3.9),
(1, 6, '고대디저트카페',   '서울시 성북구 안암동5가 12-7',   'OPEN',   4.7),
(2, 3, '성신스시',         '서울시 성북구 동선동4가 20-1',   'OPEN',   4.2),
(3, 4, '왕십리파스타',     '서울시 성동구 행당동 15-9',      'OPEN',   4.0);

-- deadline은 오늘 기준 상대 날짜라 실행일에 맞게 채워집니다
INSERT INTO mission (store_id, minimum_order_amount, point, deadline) VALUES
(1, 10000, 500,  DATE_ADD(CURDATE(), INTERVAL 7 DAY)),
(1, 15000, 800,  DATE_ADD(CURDATE(), INTERVAL 3 DAY)),
(2,  8000, 300,  DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
(2, 12000, 500,  DATE_ADD(CURDATE(), INTERVAL 1 DAY)),
(3, 10000, 400,  DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
(4,  6000, 200,  DATE_ADD(CURDATE(), INTERVAL 5 DAY)),
(4,  9000, 350,  DATE_SUB(CURDATE(), INTERVAL 2 DAY)),   -- 마감 지남
(5, 20000, 1000, DATE_ADD(CURDATE(), INTERVAL 9 DAY)),
(6, 18000, 700,  DATE_ADD(CURDATE(), INTERVAL 4 DAY)),
(6, 25000, 1200, NULL);                                   -- 마감 없음

INSERT INTO member_mission (member_id, mission_id, status, verify_code, complete_date) VALUES
(1, 1, 'COMPLETE',    '920394810', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(1, 3, 'CHALLENGING', '118273645', NULL),
(1, 6, 'CHALLENGING', '553412907', NULL),
(2, 1, 'CHALLENGING', '774125839', NULL),
(2, 5, 'COMPLETE',    '330918264', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(3, 8, 'COMPLETE',    '661203948', DATE_SUB(CURDATE(), INTERVAL 3 DAY));

INSERT INTO review (member_id, member_mission_id, rating, text) VALUES
(1, 1, 4.5, '음 너무 맛있어요 포인트도 얻고 맛있는 맛집도 알게 된것 같아 행복한 식사였답니다.'),
(2, 5, 4.0, '양이 푸짐해서 좋았어요. 다음에 또 도전할게요!'),
(3, 6, 5.0, '스시 신선하고 미션 포인트도 커서 만족합니다.');

INSERT INTO review_image (review_id, image_url) VALUES
(1, 'https://example.com/img/review1-1.jpg'),
(1, 'https://example.com/img/review1-2.jpg'),
(3, 'https://example.com/img/review3-1.jpg');

INSERT INTO notification (member_id, type, title, text, is_read) VALUES
(1, 'NEW_MISSION',    '새로운 미션이 도착했습니다.', '고대디저트카페 에서 6,000원 이상의 식사를 해보세요!', FALSE),
(1, 'REVIEW_REQUEST', '리뷰를 남겨주세요.',          '반이학생마라탕 의 음식이 맛있었다면 리뷰를 남겨주세요.', TRUE),
(2, 'NEW_MISSION',    '새로운 미션이 도착했습니다.', '짱구분식점 에서 12,000원 이상의 식사를 해보세요!',   FALSE);

INSERT INTO inquiry (member_id, type, title, text, status, answer) VALUES
(1, '포인트', '포인트가 적립되지 않았어요', '어제 미션을 완료했는데 포인트가 안 들어왔습니다.', 'WAITING',  NULL),
(2, '기타',   '가게 정보가 잘못되었어요',   '영업시간이 실제와 다릅니다.',                      'ANSWERED', '확인 후 수정하였습니다. 감사합니다.');

INSERT INTO inquiry_image (inquiry_id, image_url) VALUES
(1, 'https://example.com/img/inquiry1-1.jpg');


-- =========================================================
-- 확인용 조회: 홈 - 내 동네의 도전 가능한 미션 목록
-- (지역 1번 = 안암동, 사용자 1번 기준)
-- 기준 테이블, JOIN한 이유, WHERE 조건, 정렬·목록 기준을 설명
-- 기준 테이블: mission
-- JOIN한 이유: 미션을 제공한 가게의 이름과 위치, 음식 종류를 함께 검색하기 위해 JOIN
-- WHERE 조건: 내 동네와 사용자를 1로 가정하고, 종료 시간이 지나지 않았으며 도전하지 않은 미션을 확인
-- 정렬 기준: 종료시간이 빠른 순으로 검색하기 위해 deadline을 오름차순으로 정렬
-- =========================================================
SELECT
    s.name AS store_name,
    r.name,
    f.kind AS food_kind,
    m.minimum_order_amount,
    m.point,
    m.deadline
FROM mission m
JOIN store s         ON m.store_id = s.store_id
JOIN food_category f ON s.kind_of_food_id = f.kind_of_food_id
JOIN region r        ON s.region_id = r.region_id
WHERE s.region_id = 1
  AND m.deadline >= CURDATE()
  AND NOT EXISTS (
      SELECT 1 FROM member_mission mm
      WHERE mm.mission_id = m.mission_id
        AND mm.member_id = 1
  )
ORDER BY m.deadline ASC
LIMIT 10;