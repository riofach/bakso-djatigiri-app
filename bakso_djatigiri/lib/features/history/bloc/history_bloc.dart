// BLoC untuk manajemen state history
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/transaction.dart';
import '../domain/entities/transaction_item.dart';
import '../domain/usecases/get_transactions_usecase.dart';
import '../domain/usecases/get_transaction_items_usecase.dart';
import '../domain/usecases/watch_transactions_usecase.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends HistoryEvent {}

class RefreshTransactionsEvent extends HistoryEvent {}

class WatchTransactionsEvent extends HistoryEvent {}

class GetTransactionDetailsEvent extends HistoryEvent {
  final String transactionId;
  final String? transactionCode;

  const GetTransactionDetailsEvent(this.transactionId, {this.transactionCode});

  @override
  List<Object?> get props => [transactionId, transactionCode];
}

class FilterTransactionsEvent extends HistoryEvent {
  final String query;

  const FilterTransactionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;

  const HistoryLoaded({
    required this.transactions,
    List<Transaction>? filteredTransactions,
  }) : filteredTransactions = filteredTransactions ?? transactions;

  @override
  List<Object?> get props => [transactions, filteredTransactions];

  HistoryLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
  }) {
    return HistoryLoaded(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
    );
  }
}

class TransactionDetailsLoaded extends HistoryState {
  final List<TransactionItem> items;
  final String? transactionCode;

  const TransactionDetailsLoaded(this.items, {this.transactionCode});

  @override
  List<Object?> get props => [items, transactionCode];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetTransactionItemsUseCase getTransactionItemsUseCase;
  final WatchTransactionsUseCase watchTransactionsUseCase;
  StreamSubscription? _transactionsSubscription;

  HistoryBloc({
    required this.getTransactionsUseCase,
    required this.getTransactionItemsUseCase,
    required this.watchTransactionsUseCase,
  }) : super(HistoryInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
    on<WatchTransactionsEvent>(_onWatchTransactions);
    on<GetTransactionDetailsEvent>(_onGetTransactionDetails);
    on<FilterTransactionsEvent>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final transactions = await getTransactionsUseCase();
      emit(HistoryLoaded(transactions: transactions));
    } catch (e) {
      emit(HistoryError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final transactions = await getTransactionsUseCase();

      // Mempertahankan state filter yang ada jika dalam state loaded
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        emit(currentState.copyWith(transactions: transactions));
      } else {
        emit(HistoryLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(HistoryError('Failed to refresh transactions: $e'));
    }
  }

  void _onWatchTransactions(
    WatchTransactionsEvent event,
    Emitter<HistoryState> emit,
  ) {
    // Batalkan subscription yang sedang berjalan
    _transactionsSubscription?.cancel();

    _transactionsSubscription = watchTransactionsUseCase().listen(
      (transactions) {
        // Menggunakan add karena ini asinkron listener
        if (state is HistoryLoaded) {
          final currentState = state as HistoryLoaded;
          add(FilterTransactionsEvent('')); // Reset filter dan refresh data
        } else {
          add(LoadTransactionsEvent());
        }
      },
      onError: (error) {
        add(LoadTransactionsEvent()); // Fallback ke load biasa jika stream error
      },
    );
  }

  Future<void> _onGetTransactionDetails(
    GetTransactionDetailsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    // Tidak perlu loading state untuk menghindari UI flicker
    try {
      final items = await getTransactionItemsUseCase(event.transactionId);
      emit(TransactionDetailsLoaded(
        items,
        transactionCode: event.transactionCode,
      ));
    } catch (e) {
      emit(HistoryError('Failed to load transaction details: $e'));
    }
  }

  void _onFilterTransactions(
    FilterTransactionsEvent event,
    Emitter<HistoryState> emit,
  ) {
    if (state is HistoryLoaded) {
      final currentState = state as HistoryLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        // Reset filter jika query kosong
        emit(currentState.copyWith(
          filteredTransactions: currentState.transactions,
        ));
        return;
      }

      // Filter berdasarkan transaction_code atau total
      final filtered = currentState.transactions.where((transaction) {
        return transaction.transactionCode.toLowerCase().contains(query) ||
            transaction.total.toString().contains(query) ||
            transaction.cashierName.toLowerCase().contains(query);
      }).toList();

      emit(currentState.copyWith(filteredTransactions: filtered));
    }
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
