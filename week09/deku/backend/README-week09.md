# MovieLog 백엔드 9주차

8주차 백엔드를 복사해 Swagger/OpenAPI 문서와 회귀 테스트를 추가했습니다.

## 실행

1. `.env.example`을 `.env`로 복사하고 로컬 MySQL 정보와 `JWT_SECRET`을 입력합니다. `.env`는 Git에 포함되지 않습니다.
2. `./gradlew bootRun`으로 실행합니다.
3. [Swagger UI](http://localhost:8080/swagger-ui) 또는 `http://localhost:8080/swagger-ui.html`을 엽니다. 원시 문서는 `http://localhost:8080/v3/api-docs`입니다.
4. `POST /members`로 회원을 만들고 `POST /auth/login`으로 로그인합니다. Swagger의 **Authorize**에 응답의 `accessToken`만 입력합니다.
5. `POST /favorites`에 `{"movieId":550}`을 보내면 `201 COMMON201`, 같은 회원·영화로 다시 보내면 `409 FAVORITE409_1`입니다. `POST /ratings`는 토큰 없이 `401 AUTH401_2`, 토큰과 유효한 본문으로 `201 COMMON201`입니다.

Postman에서는 [`postman/week09-movielog-mandatory.postman_collection.json`](postman/week09-movielog-mandatory.postman_collection.json)을 가져와 01~12번을 순서대로 실행합니다. 01번이 테스트용 회원을 만들고 02번이 컬렉션 변수 `tokenA`를 저장합니다. 05~06번은 즐겨찾기 201/409, 07~09번은 평점 401/201/409, 10~12번은 영화 기록 실패 후 평점이 남지 않았는지를 확인합니다. 컬렉션 기본 주소는 `http://localhost:8080`입니다.

## 검증

```sh
./gradlew test --console=plain
```

`Week09ApiIntegrationTest`는 테스트 전용 H2 DB를 사용합니다. 공개 API와 인증 API의 OpenAPI 표시, 즐겨찾기 API의 401/201/409/해제, 평점 API의 401/201, 영화 기록 저장 실패 시 평점 롤백을 검증합니다. `RatingServiceTest`는 중복 평점의 `409 RATING409_1`과 타인 평점 수정의 `403 RATING403_1`을 가짜 Repository로 검증합니다. `FavoriteServiceTest`는 등록과 중복 검사를 가짜 Repository로 검증합니다.

## 노션 실습 인증 화면

- Swagger 전체 API 목록과 `POST /favorites`의 요청·성공·409 응답 설명
- Authorize 후 `POST /favorites`의 201 응답과 같은 요청의 409 응답
- `./gradlew test --console=plain`의 `BUILD SUCCESSFUL` 결과
- 중복 검사 코드를 임시로 제거했을 때 `FavoriteServiceTest`가 실패한 결과와 복구 후 통과한 결과

민감한 토큰, 비밀번호, `.env` 값은 캡처 전에 가립니다.
