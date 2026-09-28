import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                children: [
                  Text(
                    'FLUTTER 1주차',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xff494551),
                      height: 16/11,
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 60),
                    child: SvgPicture.asset(
                      'assets/logos/movielog_Icon.svg',
                      width: 60,
                      height: 48,
                      semanticsLabel: 'MovieLog 로고',
                    )   
                  ),
                  Text(
                    '영화의 순간을\n기록하세요',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14)

                  ),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
              child: ElevatedButton(
                onPressed: (){
                  debugPrint('시작하기 버튼을 눌렀습니다.');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  backgroundColor: Color(0xff4F378A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  )
                ),
                child: Text(
                  '시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}