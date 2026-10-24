import 'package:flutter/material.dart';
import 'package:movielog/models/rating_dto.dart';
import 'package:movielog/service/member_api_service.dart';
import 'package:provider/provider.dart';

class MyRatingsSection extends StatelessWidget {
  const MyRatingsSection({super.key, required this.memberId});

  final int memberId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RatingDto>>(
      future: context.read<MemberApiService>().fetchMemberRatings(memberId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return const Text('평점을 불러오지 못했어요.');
        final ratings = snapshot.data!;
        return ListView.builder(
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];
            return ListTile(
              title: Text('영화 #${rating.movieId}'),
              subtitle: Text(rating.comment ?? ''),
              trailing: Text('★ ${rating.score}'),
            );
          },
        );
      },
    );
  }
}
