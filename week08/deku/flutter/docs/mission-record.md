# 8주차 필수 미션 제출 기록

> 확인한 결과만 완료로 기록한다. 화면 증거와 PR 링크가 준비되면 이 내용을 개인 미션 Notion 페이지의 제출 양식에 옮긴다.

## 제출 양식

**PR 링크:** 준비 중.

**로그인→GET me 증거:** `POST /v7/auth/login`의 `result.accessToken`을 `flutter_secure_storage`에 저장한 뒤 `signedIn`으로 전환한다. `MainScreen`이 최초 진입 후 `GET /v7/members/me`를 호출해 `AuthViewModel.member`에 보관한다. 실제 요청/화면 캡처는 아직 확인 전. [로그인 초기 화면](evidence/login.png)은 캡처했다.

**재시작 복원 / 로그아웃 / 만료 증거:** 재시작 시 저장 토큰을 읽고 GET me 성공 후에만 홈으로 이동하도록 구현했다. 로그아웃은 토큰·회원·이번 세션 평점을 지운다. `AUTH401_2/3/4` 만료 시 로그인 화면에서 한 번만 Snackbar를 띄운다. 실제 재시작·만료 영상은 확인 전.

**닉네임 수정 증거:** `/my/profile/edit`에서 이메일은 읽기 전용, 닉네임은 2~12자로 검증한다. `PATCH /v7/members/me` 성공 결과로 `member`를 교체한다. 위젯 테스트에서 GET me 값과 가입일 표시를 확인했다. 실제 수정 성공/409 화면 캡처는 확인 전.

**평점 v6→v7 변경 표와 동작 영상:**

| 동작 | v6 | v7 |
| --- | --- | --- |
| 등록 | `POST /v6/members/{memberId}/ratings` | `POST /v7/ratings` + Bearer |
| 수정 | `PATCH /v6/members/{memberId}/ratings/{ratingId}` | `PATCH /v7/ratings/{ratingId}` + Bearer |
| 삭제 | `DELETE /v6/members/{memberId}/ratings/{ratingId}` · 204 | `DELETE /v7/ratings/{ratingId}` · 200, `result: null` |
| 등록/수정 결과 | ID 또는 빈 결과 | `Rating` 객체 |

등록·수정·삭제 영상은 확인 전. 수정 시 기존 score·comment를 함께 보내 전체 교체 계약을 따른다.

**TMDB id → MovieLog movieId → 영화 정보 결합 증거:** 등록 요청에는 TMDB `movie.id`를 `movieId`로 보낸다. 응답 `Rating.movieId`로 TMDB 영화를 다시 불러와 현재 세션의 평점 카드에 결합한다. 영화 정보가 없으면 `영화 #id` placeholder를 사용한다. 실제 동작 캡처는 확인 전.

**401/403/409 처리:** 로그인 `AUTH401_1`은 로그인 폼 오류로 안내한다. 보호 API `AUTH401_2/3/4`는 세션을 정리한다. 403은 로그인 상태를 유지하며 해당 작업 오류로 안내한다. 닉네임 `MEMBER409_1`은 입력값을 유지하고 중복 오류를 표시한다. 실제 오류별 화면 캡처는 확인 전.

**보안 저장 검증 플랫폼·결과:** Android Pixel 8 에뮬레이터에서 앱 빌드·실행과 로그인 초기 화면까지 확인했다. 실제 토큰 write/read/delete 및 재시작 복원은 아직 확인 전.

**토큰/비밀번호 비노출 확인:** 소스에는 JWT·비밀번호를 출력하는 로그가 없고, TMDB 요청 로거는 Authorization을 가린다. 제출 이미지와 실제 Network/Console 기록의 비노출 여부는 추가 확인 전.

**트러블슈팅:** 아래 기록 참조.

## 트러블슈팅 기록

### GET me 적용 뒤 마이페이지의 기존 디자인 요소가 사라짐

- **인증 상태와 재현 순서:** 로그인 후 마이페이지 진입. GET me 값을 표시하도록 바꾼 뒤 프로필 사진·통계·장르 영역이 사라진 화면을 확인했다.
- **요청 종류(로그인/공개/보호):** 보호 요청 `GET /v7/members/me`와 연결된 UI 렌더링.
- **status·code(토큰/비밀번호 제거):** 네트워크 오류가 아닌 UI 회귀. 상태 코드와 오류 코드는 해당 없음.
- **예상한 AuthStatus:** `signedIn`, 기존 마이페이지 레이아웃과 회원 정보 표시.
- **실제 AuthStatus/화면:** 회원 정보는 표시됐지만 기존 프로필 사진·통계·장르 영역이 누락됐다.
- **원인:** GET me 응답에 없는 사진·통계·장르를 제거하면서, 노션이 기존 디자인 예시로 유지하라고 안내한 UI까지 함께 제거했다.
- **수정:** 기존 사진·통계 카드·장르 Chip·평점 진입 영역을 복원했다. 닉네임·이메일·가입일은 GET me 값으로 연결하고, 로그아웃은 참조 화면의 텍스트 버튼으로 바꿨다. 사진·통계·장르는 API 값이 아닌 디자인 예시다.
- **재시작·로그아웃·회원 전환 재검증:** 복원된 섹션과 GET me 필드 표시 위젯 테스트 통과. 에뮬레이터에서 수정 후 재시작·로그아웃·회원 전환의 새 화면 캡처는 확인 전.

## API 계약 한계

v7 로그인과 GET me 응답에는 `memberId`가 없고, JWT만으로 내 평점 전체를 조회하는 API도 없다. 현재 화면의 평점 목록은 이번 로그인에서 등록 응답으로 받은 Rating만 보관한다. 앱 재시작 뒤 기존 내 평점 전체 복원은 완료 기능으로 표시하지 않는다. 공개 `GET /v7/members/{memberId}/ratings`는 별도 memberId가 있는 경우에만 호출할 수 있다.

## 검증

- `flutter analyze --no-pub`: 통과, 문제 0건.
- 전체 기존 Flutter 테스트: 32개 통과. 이후 마이페이지 복원 위젯 테스트 6개 통과.
- Android Pixel 8 에뮬레이터: 앱 빌드·실행 및 로그인 초기 화면 캡처 완료.
- 실제 계정 기반 Guided/Required 수동 시나리오: 확인 전.
