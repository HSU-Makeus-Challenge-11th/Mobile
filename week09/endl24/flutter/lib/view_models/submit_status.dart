/// 서버에 쓰기 요청(회원가입·평점 등록 등)을 보내는 동안의 상태입니다.
enum SubmitStatus { idle, submitting, success, error }
