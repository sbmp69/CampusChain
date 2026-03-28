/// Represents a student's blockchain-based identity
class StudentIdentity {
  final String id;
  final String name;
  final String email;
  final String department;
  final String year;
  final String avatarUrl;
  final String walletAddress;
  final double reputationScore; // 0-100
  final int academicMilestones;
  final DateTime joinedDate;

  const StudentIdentity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    required this.avatarUrl,
    required this.walletAddress,
    required this.reputationScore,
    required this.academicMilestones,
    required this.joinedDate,
  });
}

/// Types of tokens in the campus economy
enum TokenType {
  academic('Academic', '🎓'),
  utility('Utility', '🍽'),
  impact('Impact', '🌱');

  final String label;
  final String emoji;
  const TokenType(this.label, this.emoji);
}

/// A token balance entry
class TokenBalance {
  final TokenType type;
  final double balance;
  final double changePercent24h;
  final DateTime? expiresAt;
  final double multiplier;

  const TokenBalance({
    required this.type,
    required this.balance,
    required this.changePercent24h,
    this.expiresAt,
    this.multiplier = 1.0,
  });
}

/// A transaction record
class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TokenType tokenType;
  final TransactionType type;
  final DateTime timestamp;
  final bool isAutomatic;

  const Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.tokenType,
    required this.type,
    required this.timestamp,
    this.isAutomatic = false,
  });
}

enum TransactionType { earned, spent, received, sent }

/// A smart contract condition
class SmartContractCondition {
  final String id;
  final String title;
  final String description;
  final double progress; // 0-1
  final String reward;
  final ContractStatus status;
  final List<String> conditions;

  const SmartContractCondition({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.reward,
    required this.status,
    required this.conditions,
  });
}

enum ContractStatus { active, completed, upcoming }

/// A mission / challenge
class Mission {
  final String id;
  final String title;
  final String description;
  final String category;
  final int currentProgress;
  final int targetProgress;
  final int rewardTokens;
  final TokenType rewardType;
  final DateTime? deadline;
  final bool isClaimed;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardTokens,
    required this.rewardType,
    this.deadline,
    this.isClaimed = false,
  });

  double get progressPercent => currentProgress / targetProgress;
  bool get isCompleted => currentProgress >= targetProgress;
}

/// A governance proposal
class Proposal {
  final String id;
  final String title;
  final String description;
  final String author;
  final int votesFor;
  final int votesAgainst;
  final int totalVoters;
  final ProposalStatus status;
  final DateTime endDate;
  final String category;

  const Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.votesFor,
    required this.votesAgainst,
    required this.totalVoters,
    required this.status,
    required this.endDate,
    required this.category,
  });

  double get approvalPercent =>
      (votesFor + votesAgainst) == 0
          ? 0
          : votesFor / (votesFor + votesAgainst);
}

enum ProposalStatus { active, passed, rejected, pending }

/// A marketplace listing
class MarketListing {
  final String id;
  final String title;
  final String description;
  final String seller;
  final String sellerAvatar;
  final double price;
  final TokenType priceTokenType;
  final String category;
  final double sellerReputation;
  final DateTime postedAt;

  const MarketListing({
    required this.id,
    required this.title,
    required this.description,
    required this.seller,
    required this.sellerAvatar,
    required this.price,
    required this.priceTokenType,
    required this.category,
    required this.sellerReputation,
    required this.postedAt,
  });
}

/// AI Assistant message
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

/// Activity feed item
class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final IconType iconType;
  final DateTime timestamp;
  final double? amount;
  final TokenType? tokenType;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconType,
    required this.timestamp,
    this.amount,
    this.tokenType,
  });
}

enum IconType {
  attendance,
  payment,
  reward,
  scholarship,
  governance,
  marketplace,
  transfer,
}

/// Leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String name;
  final String department;
  final double reputationScore;
  final int totalTokens;
  final String avatarUrl;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.department,
    required this.reputationScore,
    required this.totalTokens,
    required this.avatarUrl,
  });
}
