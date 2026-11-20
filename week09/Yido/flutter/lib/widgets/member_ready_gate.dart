import 'package:flutter/material.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 내 정보(GET me)가 준비되고 SessionGuard가 같은 계정을 가리킬 때만 child를 만든다.
/// 계정이 바뀌면 key가 달라져 사용자별 ViewModel을 새로 만든다
class MemberReadyGate extends StatefulWidget {
  const MemberReadyGate({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    MemberInfo member,
    SessionGuard guard,
    Key sessionKey,
  )
  builder;

  @override
  State<MemberReadyGate> createState() => _MemberReadyGateState();
}

class _MemberReadyGateState extends State<MemberReadyGate> {
  @override
  void initState() {
    super.initState();
    // 내 정보 없이 바로 들어온 경우에만 한 번 불러온다. build에서는 요청하지 않는다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().loadMember();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;
    final guard = context.read<SessionGuard>();
    if (member == null || guard.accountId != member.email) {
      return Scaffold(
        body: Center(
          child: auth.memberStatus == MemberLoadStatus.error
              ? MovieLogButton(
                  label: '다시 시도',
                  onPressed: () => auth.loadMember(force: true),
                )
              : const CircularProgressIndicator(),
        ),
      );
    }
    return widget.builder(
      context,
      member,
      guard,
      ValueKey('${member.email}:${guard.generation}'),
    );
  }
}
