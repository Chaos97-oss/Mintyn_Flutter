import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/card_model.dart';
import '../models/transaction_model.dart';
import '../models/activity_model.dart';

// --------------------------------------------------
// Mock Static Data
// --------------------------------------------------
final mockUser = const UserModel(
  id: '1',
  name: 'Tayyab Sohail',
  email: 'tayyabsohailabd@gmail.com',
  avatarUrl: 'https://i.pravatar.cc/150?img=11', // Placeholder
  role: 'UX/UI Designer',
);

final mockCards = [
  const CardModel(
    id: 'c1',
    type: CardType.physical,
    cardNumber: '•••• •••• •••• 3466',
    cardHolder: 'Tayyab Sohail',
    validThru: '12 / 02 / 2024',
    cvv: '663',
    settings: CardSettings(
      changePin: true,
      qrPayment: true,
      onlineShopping: false,
      tapPay: true,
    ),
  ),
  const CardModel(
    id: 'c2',
    type: CardType.virtual,
    cardNumber: '•••• •••• •••• 8192',
    cardHolder: 'Tayyab Sohail',
    validThru: '08 / 11 / 2026',
    cvv: '123',
    settings: CardSettings(),
  ),
];

final initialTransactions = [
  TransactionModel(
    id: 't1',
    title: 'E wallet',
    amount: 100.0,
    date: DateTime.now().subtract(const Duration(minutes: 5)),
    type: TransactionType.credit,
    iconName: 'wallet',
  ),
  TransactionModel(
    id: 't2',
    title: 'Online Shopping',
    amount: 100.0,
    date: DateTime.now().subtract(const Duration(hours: 1)),
    type: TransactionType.debit,
    iconName: 'shopping',
  ),
  TransactionModel(
    id: 't3',
    title: 'E wallet',
    amount: 100.0,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    type: TransactionType.credit,
    iconName: 'wallet',
  ),
  TransactionModel(
    id: 't4',
    title: 'Banking Fee',
    amount: 100.0,
    date: DateTime.now().subtract(const Duration(hours: 3)),
    type: TransactionType.credit,
    iconName: 'bank',
  ),
  TransactionModel(
    id: 't5',
    title: 'Saving',
    amount: 300.0,
    date: DateTime.now().subtract(const Duration(days: 1)),
    type: TransactionType.debit,
    iconName: 'saving',
  ),
];

final mockActivity = const SpendingModel(
  totalSpending: 3657.0,
  dataPoints: [
    DataPoint(label: 'Jan', value: 1200),
    DataPoint(label: 'Feb', value: 3657),
    DataPoint(label: 'Mar', value: 2500),
    DataPoint(label: 'Apr', value: 4000),
    DataPoint(label: 'May', value: 3000),
    DataPoint(label: 'Jun', value: 4500),
  ],
  period: 'Weekly',
);

// --------------------------------------------------
// Mock Service Layer
// --------------------------------------------------
class MockDataService {
  final StreamController<List<TransactionModel>> _transactionsController = StreamController.broadcast();
  final StreamController<double> _balanceController = StreamController.broadcast();

  List<TransactionModel> _currentTransactions = List.from(initialTransactions);
  double _currentBalance = 1200.0;

  MockDataService() {
    // Initial emit
    _transactionsController.add(_currentTransactions);
    _balanceController.add(_currentBalance);

    // Simulate real-time updates every 10 seconds to emulate a stream
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_transactionsController.isClosed) {
        timer.cancel();
        return;
      }

      final newTx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Transfer Received',
        amount: 25.0,
        date: DateTime.now(),
        type: TransactionType.credit,
        iconName: 'transfer',
      );

      _currentTransactions = [newTx, ..._currentTransactions];
      _transactionsController.add(_currentTransactions);

      _currentBalance += 25.0;
      _balanceController.add(_currentBalance);
    });
  }

  Stream<List<TransactionModel>> get transactionsStream => _transactionsController.stream;
  Stream<double> get balanceStream => _balanceController.stream;

  Future<UserModel> getUser() async => Future.delayed(const Duration(milliseconds: 500), () => mockUser);
  Future<List<CardModel>> getCards() async => Future.delayed(const Duration(milliseconds: 500), () => mockCards);
  Future<SpendingModel> getActivity() async => Future.delayed(const Duration(milliseconds: 500), () => mockActivity);

  void setCardFrozen(String cardId, bool isFrozen) {
    // In a real app, this would mutate backend state
  }

  void dispose() {
    _transactionsController.close();
    _balanceController.close();
  }
}

// --------------------------------------------------
// Riverpod Providers
// --------------------------------------------------
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  final service = MockDataService();
  ref.onDispose(() => service.dispose());
  return service;
});

final balanceStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(mockDataServiceProvider).balanceStream;
});

final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  return ref.watch(mockDataServiceProvider).transactionsStream;
});

final userProvider = FutureProvider<UserModel>((ref) {
  return ref.watch(mockDataServiceProvider).getUser();
});

final cardsProvider = FutureProvider<List<CardModel>>((ref) {
  return ref.watch(mockDataServiceProvider).getCards();
});

final activityProvider = FutureProvider<SpendingModel>((ref) {
  return ref.watch(mockDataServiceProvider).getActivity();
});
