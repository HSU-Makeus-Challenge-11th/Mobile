CREATE TABLE `member` (
	`member_id`	BIGINT	NOT NULL	COMMENT '회원 번호',
	`name`	VARCHAR(20)	NOT NULL	COMMENT '이름',
	`nickname`	VARCHAR(20)	NOT NULL	COMMENT '닉네임',
	`gender`	ENUM('MALE', 'FEMALE', 'NONE')	NOT NULL	COMMENT '성별',
	`birth`	DATE	NOT NULL	COMMENT '생년월일',
	`address`	VARCHAR(50)	NOT NULL	COMMENT '주소',
	`address_detail`	VARCHAR(50)	NULL	COMMENT '상세 주소',
	`email`	VARCHAR(50)	NULL	COMMENT '이메일',
	`phone_number`	VARCHAR(15)	NULL	COMMENT '휴대폰 번호',
	`is_phone_verified`	BOOLEAN	NOT NULL	DEFAULT FALSE	COMMENT '휴대폰 인증 여부',
	`point`	INT	NOT NULL	DEFAULT 0	COMMENT '포인트',
	`social_type`	ENUM('KAKAO', 'NAVER', 'APPLE', 'GOOGLE')	NOT NULL	COMMENT '소셜 종류',
	`social_id`	VARCHAR(100)	NOT NULL	COMMENT '소셜 고유 번호',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각',
	`deleted_at`	DATETIME	NULL	COMMENT '탈퇴 시각'
);

CREATE TABLE `terms` (
	`terms_id`	BIGINT	NOT NULL	COMMENT '약관 번호',
	`title`	VARCHAR(50)	NOT NULL	COMMENT '약관 이름',
	`content`	TEXT	NOT NULL	COMMENT '약관 내용',
	`is_required`	BOOLEAN	NOT NULL	COMMENT '필수 여부',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `member_terms` (
	`member_terms_id`	BIGINT	NOT NULL	COMMENT '약관 동의 번호',
	`member_id`	BIGINT	NOT NULL	COMMENT '회원 번호',
	`terms_id`	BIGINT	NOT NULL	COMMENT '약관 번호',
	`is_agreed`	BOOLEAN	NOT NULL	COMMENT '동의 여부',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `food_category` (
	`food_category_id`	BIGINT	NOT NULL	COMMENT '음식 종류 번호',
	`name`	VARCHAR(20)	NOT NULL	COMMENT '음식 종류 이름',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `member_prefer` (
	`member_prefer_id`	BIGINT	NOT NULL	COMMENT '선호 음식 번호',
	`member_id`	BIGINT	NOT NULL	COMMENT '회원 번호',
	`food_category_id`	BIGINT	NOT NULL	COMMENT '음식 종류 번호',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `region` (
	`region_id`	BIGINT	NOT NULL	COMMENT '지역 번호',
	`name`	VARCHAR(20)	NOT NULL	COMMENT '지역 이름',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `store` (
	`store_id`	BIGINT	NOT NULL	COMMENT '가게 번호',
	`region_id`	BIGINT	NOT NULL	COMMENT '지역 번호',
	`food_category_id`	BIGINT	NOT NULL	COMMENT '음식 종류 번호',
	`name`	VARCHAR(50)	NOT NULL	COMMENT '가게 이름',
	`address`	VARCHAR(100)	NOT NULL	COMMENT '가게 주소',
	`score`	DECIMAL(2, 1)	NOT NULL	DEFAULT 0.0	COMMENT '평점',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `mission` (
	`mission_id`	BIGINT	NOT NULL	COMMENT '미션 번호',
	`store_id`	BIGINT	NOT NULL	COMMENT '가게 번호',
	`min_price`	INT	NOT NULL	COMMENT '최소 결제 금액',
	`reward`	INT	NOT NULL	COMMENT '보상 포인트',
	`deadline`	DATETIME	NOT NULL	COMMENT '마감 시각',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

CREATE TABLE `member_mission` (
	`member_mission_id`	BIGINT	NOT NULL	COMMENT '회원 미션 번호',
	`member_id`	BIGINT	NOT NULL	COMMENT '회원 번호',
	`mission_id`	BIGINT	NOT NULL	COMMENT '미션 번호',
	`status`	ENUM('CHALLENGING', 'COMPLETE')	NOT NULL	COMMENT '진행 상태',
	`verification_code`	VARCHAR(20)	NULL	COMMENT '사장님 구분 번호',
	`created_at`	DATETIME	NOT NULL	COMMENT '생성 시각',
	`updated_at`	DATETIME	NOT NULL	COMMENT '수정 시각'
);

ALTER TABLE `member` ADD CONSTRAINT `PK_MEMBER` PRIMARY KEY (
	`member_id`
);

ALTER TABLE `terms` ADD CONSTRAINT `PK_TERMS` PRIMARY KEY (
	`terms_id`
);

ALTER TABLE `member_terms` ADD CONSTRAINT `PK_MEMBER_TERMS` PRIMARY KEY (
	`member_terms_id`
);

ALTER TABLE `food_category` ADD CONSTRAINT `PK_FOOD_CATEGORY` PRIMARY KEY (
	`food_category_id`
);

ALTER TABLE `member_prefer` ADD CONSTRAINT `PK_MEMBER_PREFER` PRIMARY KEY (
	`member_prefer_id`
);

ALTER TABLE `region` ADD CONSTRAINT `PK_REGION` PRIMARY KEY (
	`region_id`
);

ALTER TABLE `store` ADD CONSTRAINT `PK_STORE` PRIMARY KEY (
	`store_id`
);

ALTER TABLE `mission` ADD CONSTRAINT `PK_MISSION` PRIMARY KEY (
	`mission_id`
);

ALTER TABLE `member_mission` ADD CONSTRAINT `PK_MEMBER_MISSION` PRIMARY KEY (
	`member_mission_id`
);

ALTER TABLE `member_terms` ADD CONSTRAINT `FK_member_TO_member_terms_1` FOREIGN KEY (
	`member_id`
)
REFERENCES `member` (
	`member_id`
);

ALTER TABLE `member_terms` ADD CONSTRAINT `FK_terms_TO_member_terms_1` FOREIGN KEY (
	`terms_id`
)
REFERENCES `terms` (
	`terms_id`
);

ALTER TABLE `member_prefer` ADD CONSTRAINT `FK_member_TO_member_prefer_1` FOREIGN KEY (
	`member_id`
)
REFERENCES `member` (
	`member_id`
);

ALTER TABLE `member_prefer` ADD CONSTRAINT `FK_food_category_TO_member_prefer_1` FOREIGN KEY (
	`food_category_id`
)
REFERENCES `food_category` (
	`food_category_id`
);

ALTER TABLE `store` ADD CONSTRAINT `FK_region_TO_store_1` FOREIGN KEY (
	`region_id`
)
REFERENCES `region` (
	`region_id`
);

ALTER TABLE `store` ADD CONSTRAINT `FK_food_category_TO_store_1` FOREIGN KEY (
	`food_category_id`
)
REFERENCES `food_category` (
	`food_category_id`
);

ALTER TABLE `mission` ADD CONSTRAINT `FK_store_TO_mission_1` FOREIGN KEY (
	`store_id`
)
REFERENCES `store` (
	`store_id`
);

ALTER TABLE `member_mission` ADD CONSTRAINT `FK_member_TO_member_mission_1` FOREIGN KEY (
	`member_id`
)
REFERENCES `member` (
	`member_id`
);

ALTER TABLE `member_mission` ADD CONSTRAINT `FK_mission_TO_member_mission_1` FOREIGN KEY (
	`mission_id`
)
REFERENCES `mission` (
	`mission_id`
);

