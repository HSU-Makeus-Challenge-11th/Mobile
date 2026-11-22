/// 쓰기 요청(회원가입 POST, 평점 등록 POST)의 진행 상태.
/// 화면이 버튼 잠금·PopScope·Snackbar를 결정할 때 이 값만 본다.
enum SubmitStatus { idle, submitting, success, error }
