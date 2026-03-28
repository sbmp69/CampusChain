import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

/// Student identity provider
final studentProvider = Provider<StudentIdentity>((ref) => MockData.student);

/// Token balances provider
final tokenBalancesProvider = Provider<List<TokenBalance>>(
  (ref) => MockData.tokenBalances,
);

/// Total balance provider
final totalBalanceProvider = Provider<double>((ref) => MockData.totalBalance);

/// Transactions provider
final transactionsProvider = Provider<List<Transaction>>(
  (ref) => MockData.transactions,
);

/// Activity feed provider
final activityFeedProvider = Provider<List<ActivityItem>>(
  (ref) => MockData.activities,
);

/// Smart contracts provider
final smartContractsProvider = Provider<List<SmartContractCondition>>(
  (ref) => MockData.smartContracts,
);

/// Missions provider
final missionsProvider = Provider<List<Mission>>(
  (ref) => MockData.missions,
);

/// Proposals provider
final proposalsProvider = Provider<List<Proposal>>(
  (ref) => MockData.proposals,
);

/// Market listings provider
final marketListingsProvider = Provider<List<MarketListing>>(
  (ref) => MockData.marketListings,
);

/// Leaderboard provider
final leaderboardProvider = Provider<List<LeaderboardEntry>>(
  (ref) => MockData.leaderboard,
);

/// Chart data provider
final chartDataProvider = Provider<List<double>>(
  (ref) => MockData.chartData,
);

/// AI chat messages provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  (ref) => ChatMessagesNotifier(),
);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier()
      : super([
          ChatMessage(
            id: 'welcome',
            content:
                'Hello Meet! 👋 I\'m your CampusChain AI assistant. I can help you understand your tokens, rewards, and campus economy. What would you like to know?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  void addMessage(String content, {bool isUser = true}) {
    state = [
      ...state,
      ChatMessage(
        id: 'msg-${state.length}',
        content: content,
        isUser: isUser,
        timestamp: DateTime.now(),
      ),
    ];

    if (isUser) {
      // Simulate AI response
      Future.delayed(const Duration(milliseconds: 1200), () {
        state = [
          ...state,
          ChatMessage(
            id: 'msg-${state.length}',
            content: _generateResponse(content),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      });
    }
  }

  String _generateResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('fewer tokens') || q.contains('less tokens')) {
      return 'Your token earning dropped by 12% today because you missed the morning lecture (CS201). Each attended class earns 20 Academic Tokens. Tip: Maintain 90%+ attendance for the 1.3x multiplier bonus! 📊';
    }
    if (q.contains('increase') || q.contains('more rewards')) {
      return 'Great question! Here are 3 ways to boost your rewards:\n\n1. 🎯 Complete the "Knowledge Seeker" mission (2 more lectures needed) — +50 tokens\n2. ♻️ Recycle 6 more items for "Eco Warrior" — +100 tokens\n3. 👥 Your tutoring reputation is high! Each session earns 50+ tokens\n\nYour current multiplier is 1.3x — keep it up! 🚀';
    }
    if (q.contains('scholarship')) {
      return 'Your next scholarship release is tracked by the "Semester Scholarship" smart contract. Current progress: 85%.\n\n✅ GPA ≥ 3.8 — Met (3.92)\n✅ Attendance ≥ 90% — Met (94%)\n⏳ No disciplinary issues — On track\n\nEstimated release: End of this month. Reward: 500 Academic Tokens 🎓';
    }
    if (q.contains('mission')) {
      return 'Based on your activity patterns, I recommend focusing on:\n\n1. 🌟 "Mentor Star" — Already complete! Claim your 75 tokens now!\n2. 📚 "Knowledge Seeker" — Just 2 more lectures (high ROI)\n3. 🌱 "Eco Warrior" — You\'re at 70%, easy to finish\n\nThese would earn you 225 tokens total! 💰';
    }
    if (q.contains('reputation') || q.contains('discount')) {
      return 'Your reputation score is 87.5/100 (Top 5%)! Here\'s how it helps:\n\n🍽 Cafeteria: 15% discount (>80 reputation)\n📚 Library: Extended borrowing (>85)\n🎫 Events: Priority access (>90 — almost there!)\n🏛 Governance: 1.3x voting weight\n\nTip: Tutoring and sustainability actions boost reputation fastest! ⭐';
    }
    return 'I can help you with token balances, rewards optimization, scholarship tracking, and campus economy insights. Try asking about your missions, reputation benefits, or how to earn more tokens! 🎓';
  }
}

/// Navigation state
final currentTabProvider = StateProvider<int>((ref) => 0);
