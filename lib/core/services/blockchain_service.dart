import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';

// Since this is MVP Phase 2, we use standard known Hardhat addresses.
// In a real production app, these would come from .env
const String rpcUrl = "http://127.0.0.1:8545"; // Use localhost for Web testing
const String wsUrl = "ws://127.0.0.1:8545";
const String testPrivateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"; // Hardhat Account #0

class BlockchainService {
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late EthereumAddress _walletAddress;

  // Contracts
  DeployedContract? _campusIdentity;
  DeployedContract? _campusToken;
  DeployedContract? _campusDAO;

  // Expected default Hardhat deployment addresses
  final String _identityAddr = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';
  final String _tokenAddr = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';
  final String _daoAddr = '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9';

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    _client = Web3Client(rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(testPrivateKey);
    _walletAddress = _credentials.address;

    print("BlockchainService Init - Linked Wallet: ${_walletAddress.toString()}");

    await _loadContracts();
    _isInitialized = true;
  }

  Future<void> _loadContracts() async {
    // 1. Identity
    final identityAbiJson = await rootBundle.loadString('assets/abis/CampusIdentity.json');
    final identityAbiArr = jsonDecode(identityAbiJson)['abi'];
    final identityAbi = ContractAbi.fromJson(jsonEncode(identityAbiArr), 'CampusIdentity');
    _campusIdentity = DeployedContract(identityAbi, EthereumAddress.fromHex(_identityAddr));

    // 2. Token
    final tokenAbiJson = await rootBundle.loadString('assets/abis/CampusToken.json');
    final tokenAbiArr = jsonDecode(tokenAbiJson)['abi'];
    final tokenAbi = ContractAbi.fromJson(jsonEncode(tokenAbiArr), 'CampusToken');
    _campusToken = DeployedContract(tokenAbi, EthereumAddress.fromHex(_tokenAddr));

    // 3. DAO
    final daoAbiJson = await rootBundle.loadString('assets/abis/CampusDAO.json');
    final daoAbiArr = jsonDecode(daoAbiJson)['abi'];
    final daoAbi = ContractAbi.fromJson(jsonEncode(daoAbiArr), 'CampusDAO');
    _campusDAO = DeployedContract(daoAbi, EthereumAddress.fromHex(_daoAddr));
  }

  // ---- Public API ----
  
  EthereumAddress get currentWallet => _walletAddress;

  Future<int> getReputation() async {
    await init();
    try {
      final func = _campusIdentity!.function('getReputation');
      final result = await _client.call(
        contract: _campusIdentity!,
        function: func,
        params: [_walletAddress],
      );
      return (result[0] as BigInt).toInt();
    } catch (e) {
      print("RPC Error (getReputation): $e");
      return 87; // Fallback to mock for testing if RPC down
    }
  }

  Future<double> getTokenBalance(int tokenId) async {
    await init();
    try {
      final func = _campusToken!.function('balanceOf');
      final result = await _client.call(
        contract: _campusToken!,
        function: func,
        params: [_walletAddress, BigInt.from(tokenId)],
      );
      return (result[0] as BigInt).toDouble();
    } catch (e) {
      print("RPC Error (getTokenBalance - $tokenId): $e");
      // Fallback if local node is not actively running
      if (tokenId == 0) return 1245.50; // Academic
      if (tokenId == 1) return 680.00;  // Utility
      return 320.75; // Impact
    }
  }

  Future<void> voteOnProposal(int proposalId, bool inFavor) async {
    await init();
    final func = _campusDAO!.function('vote');
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _campusDAO!,
        function: func,
        parameters: [BigInt.from(proposalId), inFavor],
      ),
      chainId: 1337, // Local hardhat chain
    );
  }

  // Quick helper to mint tokens dynamically for the prototype
  Future<void> earnTokens(int tokenId, int amount) async {
    await init();
    try {
      final func = _campusToken!.function('earnTokens');
      final txHash = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _campusToken!,
          function: func,
          parameters: [_walletAddress, BigInt.from(tokenId), BigInt.from(amount)],
        ),
        chainId: 1337,
      );
      print("Minted Tokens! TX: \$txHash");
    } catch (e) {
      print("RPC Error (earnTokens): \$e");
    }
  }
}

// Global singleton instance
final blockchainService = BlockchainService();
