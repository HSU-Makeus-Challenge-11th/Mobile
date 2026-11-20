package com.umc.movie.config;

/**
 * Swagger 문서에 보여 줄 응답 예시.
 * 애노테이션 값은 상수여야 하므로 여러 API가 같이 쓰는 실패 응답을 여기 모은다.
 */
public final class SwaggerExamples {

    private SwaggerExamples() {
    }

    public static final String AUTH401_2 = """
            {
              "isSuccess": false,
              "code": "AUTH401_2",
              "message": "로그인이 필요한 요청입니다.",
              "result": null
            }
            """;

    public static final String AUTH401_3 = """
            {
              "isSuccess": false,
              "code": "AUTH401_3",
              "message": "유효하지 않은 토큰입니다.",
              "result": null
            }
            """;

    public static final String AUTH401_4 = """
            {
              "isSuccess": false,
              "code": "AUTH401_4",
              "message": "토큰이 만료되었습니다. 다시 로그인해주세요.",
              "result": null
            }
            """;

    public static final String MOVIE_ID_400 = """
            {
              "isSuccess": false,
              "code": "COMMON4001",
              "message": "영화 ID는 양수여야 합니다.",
              "result": null
            }
            """;

    public static final String FAVORITE_CREATED = """
            {
              "isSuccess": true,
              "code": "COMMON201",
              "message": "즐겨찾기를 등록했습니다.",
              "result": { "favoriteId": 1, "movieId": 550, "createdAt": "2026-11-20T21:00:00" }
            }
            """;

    public static final String FAVORITE409_1 = """
            {
              "isSuccess": false,
              "code": "FAVORITE409_1",
              "message": "이미 이 영화를 즐겨찾기하셨습니다.",
              "result": null
            }
            """;

    public static final String FAVORITE_LIST = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "내 즐겨찾기 목록을 조회했습니다.",
              "result": [
                { "favoriteId": 2, "movieId": 680, "createdAt": "2026-11-20T21:05:00" },
                { "favoriteId": 1, "movieId": 550, "createdAt": "2026-11-20T21:00:00" }
              ]
            }
            """;

    public static final String FAVORITE_STATUS = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "즐겨찾기 여부를 조회했습니다.",
              "result": { "isFavorite": false }
            }
            """;

    public static final String FAVORITE_DELETED = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "즐겨찾기를 해제했습니다.",
              "result": null
            }
            """;

    public static final String FAVORITE404_1 = """
            {
              "isSuccess": false,
              "code": "FAVORITE404_1",
              "message": "즐겨찾기한 영화를 찾을 수 없습니다.",
              "result": null
            }
            """;

    public static final String PATH_400 = """
            {
              "isSuccess": false,
              "code": "COMMON4001",
              "message": "경로 값의 형식이 올바르지 않습니다.",
              "result": null
            }
            """;

    public static final String MEMBER_RATINGS = """
            [
              { "ratingId": 3, "movieId": 550, "score": 5, "comment": "다시 봐도 명작", "createdAt": "2026-11-20T21:00:00", "updatedAt": "2026-11-20T21:00:00" }
            ]
            """;

    public static final String MEMBER404_1 = """
            {
              "isSuccess": false,
              "code": "MEMBER404_1",
              "message": "해당 회원을 찾을 수 없습니다.",
              "result": null
            }
            """;

    public static final String RATING_CREATED = """
            {
              "isSuccess": true,
              "code": "COMMON201",
              "message": "평점을 등록했습니다.",
              "result": { "ratingId": 3, "movieId": 550, "score": 5, "comment": "다시 봐도 명작", "createdAt": "2026-11-20T21:00:00", "updatedAt": "2026-11-20T21:00:00" }
            }
            """;

    public static final String RATING_UPDATED = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "평점을 수정했습니다.",
              "result": { "ratingId": 3, "movieId": 550, "score": 4, "comment": "두 번째 보니 조금 아쉬움", "createdAt": "2026-11-20T21:00:00", "updatedAt": "2026-11-20T21:10:00" }
            }
            """;

    public static final String RATING_DELETED = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "평점을 삭제했습니다.",
              "result": null
            }
            """;

    public static final String SCORE_400 = """
            {
              "isSuccess": false,
              "code": "COMMON4001",
              "message": "별점은 5점 이하여야 합니다.",
              "result": null
            }
            """;

    public static final String RATING403_1 = """
            {
              "isSuccess": false,
              "code": "RATING403_1",
              "message": "본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.",
              "result": null
            }
            """;

    public static final String RATING404_1 = """
            {
              "isSuccess": false,
              "code": "RATING404_1",
              "message": "해당 평점을 찾을 수 없습니다.",
              "result": null
            }
            """;

    public static final String RATING409_1 = """
            {
              "isSuccess": false,
              "code": "RATING409_1",
              "message": "이미 이 영화에 평점을 남기셨습니다.",
              "result": null
            }
            """;
}
