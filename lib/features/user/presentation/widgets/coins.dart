import 'package:flutter/material.dart';
import 'package:pilipala/models/member/coin.dart';

/// CoinsWidget displays the user's recent coins.
class CoinsWidget extends StatelessWidget {
  final List<MemberCoinsDataModel> coins;

  const CoinsWidget({
    super.key,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '最近投币',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: coins.length,
          itemBuilder: (context, index) {
            final coin = coins[index];
            return ListTile(
              title: Text(coin.title ?? ''),
              subtitle: Text(coin.owner?.name ?? ''),
              leading: coin.pic != null
                  ? Image.network(
                      coin.pic!,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }
}
