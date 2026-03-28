import '../models/models.dart';

/// Mock data provider with rich campus scenario data
class MockData {
  MockData._();

  static final student = StudentIdentity(
    id: 'STU-2026-001',
    name: 'Meet Patel',
    email: 'meet.patel@campus.edu',
    department: 'Computer Science',
    year: '3rd Year',
    avatarUrl: '',
    walletAddress: '0x7a3B...e4F2',
    reputationScore: 87.5,
    academicMilestones: 14,
    joinedDate: DateTime(2024, 8, 15),
  );

  static final tokenBalances = [
    TokenBalance(
      type: TokenType.academic,
      balance: 1245.50,
      changePercent24h: 5.2,
      multiplier: 1.3,
    ),
    TokenBalance(
      type: TokenType.utility,
      balance: 680.00,
      changePercent24h: -2.1,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    ),
    TokenBalance(
      type: TokenType.impact,
      balance: 320.75,
      changePercent24h: 12.8,
      multiplier: 1.5,
    ),
  ];

  static double get totalBalance =>
      tokenBalances.fold(0.0, (sum, t) => sum + t.balance);

  static final transactions = [
    Transaction(
      id: 'tx-001',
      title: 'Class Attendance',
      description: 'CS301 - Advanced Algorithms',
      amount: 20,
      tokenType: TokenType.academic,
      type: TransactionType.earned,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isAutomatic: true,
    ),
    Transaction(
      id: 'tx-002',
      title: 'Cafeteria Payment',
      description: 'Auto-deducted at Main Café',
      amount: -45,
      tokenType: TokenType.utility,
      type: TransactionType.spent,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isAutomatic: true,
    ),
    Transaction(
      id: 'tx-003',
      title: 'Peer Tutoring',
      description: 'Helped 3 students with Data Structures',
      amount: 50,
      tokenType: TokenType.academic,
      type: TransactionType.earned,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Transaction(
      id: 'tx-004',
      title: 'Recycling Reward',
      description: 'Recycled 5 items at Green Hub',
      amount: 15,
      tokenType: TokenType.impact,
      type: TransactionType.earned,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isAutomatic: true,
    ),
    Transaction(
      id: 'tx-005',
      title: 'Library Fine Waived',
      description: 'Smart contract: attendance > 90%',
      amount: 30,
      tokenType: TokenType.utility,
      type: TransactionType.earned,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isAutomatic: true,
    ),
    Transaction(
      id: 'tx-006',
      title: 'Sent to Priya Sharma',
      description: 'For project collaboration',
      amount: -100,
      tokenType: TokenType.academic,
      type: TransactionType.sent,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    Transaction(
      id: 'tx-007',
      title: 'Event Participation',
      description: 'CodeFest 2026 Hackathon',
      amount: 75,
      tokenType: TokenType.academic,
      type: TransactionType.earned,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: 'tx-008',
      title: 'Scholarship Release',
      description: 'Merit-based: GPA ≥ 3.8',
      amount: 500,
      tokenType: TokenType.academic,
      type: TransactionType.earned,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isAutomatic: true,
    ),
  ];

  static final activities = [
    ActivityItem(
      id: 'act-001',
      title: 'Earned 20 tokens for attendance',
      subtitle: 'CS301 — Advanced Algorithms',
      iconType: IconType.attendance,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      amount: 20,
      tokenType: TokenType.academic,
    ),
    ActivityItem(
      id: 'act-002',
      title: 'Cafeteria payment auto-completed',
      subtitle: 'Main Café — Lunch combo',
      iconType: IconType.payment,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      amount: -45,
      tokenType: TokenType.utility,
    ),
    ActivityItem(
      id: 'act-003',
      title: 'Scholarship unlocked!',
      subtitle: 'Merit-based: GPA ≥ 3.8 achieved',
      iconType: IconType.scholarship,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      amount: 500,
      tokenType: TokenType.academic,
    ),
    ActivityItem(
      id: 'act-004',
      title: 'Recycling bonus earned',
      subtitle: '5 items recycled at Green Hub',
      iconType: IconType.reward,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      amount: 15,
      tokenType: TokenType.impact,
    ),
    ActivityItem(
      id: 'act-005',
      title: 'New governance proposal',
      subtitle: 'Vote on: Extend library hours',
      iconType: IconType.governance,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  static final smartContracts = [
    SmartContractCondition(
      id: 'sc-001',
      title: 'Semester Scholarship',
      description: 'Auto-releases tokens when GPA threshold met',
      progress: 0.85,
      reward: '500 Academic Tokens',
      status: ContractStatus.active,
      conditions: ['GPA ≥ 3.8', 'Attendance ≥ 90%', 'No disciplinary issues'],
    ),
    SmartContractCondition(
      id: 'sc-002',
      title: 'Late Fee Waiver',
      description: 'Library late fees waived for high attendance',
      progress: 1.0,
      reward: '30 Utility Tokens saved',
      status: ContractStatus.completed,
      conditions: ['Attendance ≥ 85%'],
    ),
    SmartContractCondition(
      id: 'sc-003',
      title: 'Research Grant Release',
      description: 'Milestone-based research funding',
      progress: 0.4,
      reward: '1000 Academic Tokens',
      status: ContractStatus.active,
      conditions: [
        'Literature review complete',
        'Data collection 50%',
        'Advisor approval',
        'Ethics clearance'
      ],
    ),
    SmartContractCondition(
      id: 'sc-004',
      title: 'Sports Excellence Award',
      description: 'Upcoming inter-university championship',
      progress: 0.0,
      reward: '200 Impact Tokens',
      status: ContractStatus.upcoming,
      conditions: ['Team qualification', 'Tournament participation'],
    ),
  ];

  static final missions = [
    Mission(
      id: 'mis-001',
      title: 'Knowledge Seeker',
      description: 'Attend 5 lectures this week',
      category: 'Academic',
      currentProgress: 3,
      targetProgress: 5,
      rewardTokens: 50,
      rewardType: TokenType.academic,
      deadline: DateTime.now().add(const Duration(days: 4)),
    ),
    Mission(
      id: 'mis-002',
      title: 'Eco Warrior',
      description: 'Recycle 20 items this month',
      category: 'Sustainability',
      currentProgress: 14,
      targetProgress: 20,
      rewardTokens: 100,
      rewardType: TokenType.impact,
      deadline: DateTime.now().add(const Duration(days: 12)),
    ),
    Mission(
      id: 'mis-003',
      title: 'Mentor Star',
      description: 'Tutor 3 peers in any subject',
      category: 'Community',
      currentProgress: 3,
      targetProgress: 3,
      rewardTokens: 75,
      rewardType: TokenType.academic,
      isClaimed: false,
    ),
    Mission(
      id: 'mis-004',
      title: 'Early Bird',
      description: 'Check in before 8 AM for 10 days',
      category: 'Habits',
      currentProgress: 7,
      targetProgress: 10,
      rewardTokens: 40,
      rewardType: TokenType.utility,
      deadline: DateTime.now().add(const Duration(days: 8)),
    ),
    Mission(
      id: 'mis-005',
      title: 'Campus Explorer',
      description: 'Visit 5 different campus facilities',
      category: 'Exploration',
      currentProgress: 2,
      targetProgress: 5,
      rewardTokens: 30,
      rewardType: TokenType.utility,
    ),
    Mission(
      id: 'mis-006',
      title: 'Civic Duty',
      description: 'Vote on 3 governance proposals',
      category: 'Governance',
      currentProgress: 1,
      targetProgress: 3,
      rewardTokens: 60,
      rewardType: TokenType.impact,
    ),
  ];

  static final proposals = [
    Proposal(
      id: 'prop-001',
      title: 'Extend Library Hours to Midnight',
      description:
          'Proposal to extend library operating hours from 10 PM to 12 AM on weekdays to support students during exam periods. This would require additional staffing and operational costs covered by a 2% token policy adjustment.',
      author: 'Student Council',
      votesFor: 342,
      votesAgainst: 58,
      totalVoters: 500,
      status: ProposalStatus.active,
      endDate: DateTime.now().add(const Duration(days: 5)),
      category: 'Facilities',
    ),
    Proposal(
      id: 'prop-002',
      title: 'Increase Sustainability Rewards by 25%',
      description:
          'Boost Impact Token rewards for recycling, clean energy usage, and green transportation to incentivize more eco-friendly behavior on campus.',
      author: 'Green Campus Initiative',
      votesFor: 289,
      votesAgainst: 112,
      totalVoters: 500,
      status: ProposalStatus.active,
      endDate: DateTime.now().add(const Duration(days: 3)),
      category: 'Token Policy',
    ),
    Proposal(
      id: 'prop-003',
      title: 'Add Peer Tutoring to Fee Structure',
      description:
          'Formally recognize peer tutoring with standardized token payments, creating a structured micro-economy for academic support.',
      author: 'Academic Affairs',
      votesFor: 410,
      votesAgainst: 45,
      totalVoters: 500,
      status: ProposalStatus.passed,
      endDate: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Fee Structure',
    ),
    Proposal(
      id: 'prop-004',
      title: 'Token Inflation Control Mechanism',
      description:
          'Implement a dynamic burn rate for excess tokens to maintain economic stability within the campus ecosystem.',
      author: 'Economics Club',
      votesFor: 156,
      votesAgainst: 201,
      totalVoters: 500,
      status: ProposalStatus.rejected,
      endDate: DateTime.now().subtract(const Duration(days: 7)),
      category: 'Token Policy',
    ),
  ];

  static final marketListings = [
    MarketListing(
      id: 'ml-001',
      title: 'CS301 Lecture Notes (Complete)',
      description:
          'Comprehensive notes for Advanced Algorithms including diagrams, examples, and exam prep summaries.',
      seller: 'Ananya Verma',
      sellerAvatar: '',
      price: 25,
      priceTokenType: TokenType.academic,
      category: 'Notes',
      sellerReputation: 92.3,
      postedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    MarketListing(
      id: 'ml-002',
      title: 'Python Tutoring (1 hour)',
      description:
          'One-on-one Python tutoring session covering basics to advanced topics. Perfect for beginners!',
      seller: 'Rahul Desai',
      sellerAvatar: '',
      price: 40,
      priceTokenType: TokenType.academic,
      category: 'Tutoring',
      sellerReputation: 88.7,
      postedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    MarketListing(
      id: 'ml-003',
      title: 'CodeFest 2026 After-Party Ticket',
      description:
          'VIP access to the post-hackathon celebration. Includes food and networking session.',
      seller: 'Tech Club',
      sellerAvatar: '',
      price: 60,
      priceTokenType: TokenType.utility,
      category: 'Events',
      sellerReputation: 95.0,
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MarketListing(
      id: 'ml-004',
      title: 'UI/UX Design Workshop Recording',
      description:
          'Full recording of the campus UI/UX workshop with Figma templates and design assets.',
      seller: 'Design Society',
      sellerAvatar: '',
      price: 35,
      priceTokenType: TokenType.academic,
      category: 'Resources',
      sellerReputation: 90.1,
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MarketListing(
      id: 'ml-005',
      title: 'Campus Garden Volunteering Slot',
      description:
          'Sign up for a 2-hour slot at the campus garden. Earn Impact Tokens while contributing to campus greening.',
      seller: 'Green Campus',
      sellerAvatar: '',
      price: 0,
      priceTokenType: TokenType.impact,
      category: 'Volunteering',
      sellerReputation: 97.2,
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final leaderboard = [
    LeaderboardEntry(
      rank: 1,
      name: 'Priya Sharma',
      department: 'Computer Science',
      reputationScore: 96.8,
      totalTokens: 3450,
      avatarUrl: '',
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Meet Patel',
      department: 'Computer Science',
      reputationScore: 87.5,
      totalTokens: 2246,
      avatarUrl: '',
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Arjun Nair',
      department: 'Electronics',
      reputationScore: 85.2,
      totalTokens: 2100,
      avatarUrl: '',
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Sakshi Gupta',
      department: 'Mathematics',
      reputationScore: 82.9,
      totalTokens: 1980,
      avatarUrl: '',
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Rohan Mehta',
      department: 'Mechanical',
      reputationScore: 80.1,
      totalTokens: 1850,
      avatarUrl: '',
    ),
  ];

  static const aiSuggestedQuestions = [
    'Why did I get fewer tokens today?',
    'How can I increase my rewards?',
    'When is my next scholarship release?',
    'What missions should I focus on?',
    'How does reputation affect my discounts?',
  ];

  static final chartData = [
    1200.0, 1180.0, 1210.0, 1195.0, 1230.0, 1215.0, 1245.5,
  ];
  static const chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
