// BLoC untuk fitur tambah stock bahan
// ignore_for_file: unused_import
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/supabase_storage.dart';
import '../../../core/utils/image_compressor.dart';

// Event
abstract class CreateStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickImageEvent extends CreateStockEvent {
  final String? imagePath; // local path
  PickImageEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class NameChangedEvent extends CreateStockEvent {
  final String name;
  NameChangedEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class AmountChangedEvent extends CreateStockEvent {
  final String amount;
  AmountChangedEvent(this.amount);
  @override
  List<Object?> get props => [amount];
}

class SubmitStockEvent extends CreateStockEvent {}

// State
class CreateStockState extends Equatable {
  final String? imagePath;
  final String? imageUrl;
  final String name;
  final String amount;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const CreateStockState({
    this.imagePath,
    this.imageUrl,
    this.name = '',
    this.amount = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  CreateStockState copyWith({
    String? imagePath,
    String? imageUrl,
    String? name,
    String? amount,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return CreateStockState(
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        imagePath,
        imageUrl,
        name,
        amount,
        isLoading,
        isSuccess,
        error,
      ];
}

// Bloc
class CreateStockBloc extends Bloc<CreateStockEvent, CreateStockState> {
  final FirebaseFirestore _firestore;

  CreateStockBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CreateStockState()) {
    on<PickImageEvent>((event, emit) {
      emit(state.copyWith(imagePath: event.imagePath, error: null));
    });
    on<NameChangedEvent>((event, emit) {
      emit(state.copyWith(name: event.name, error: null));
    });
    on<AmountChangedEvent>((event, emit) {
      emit(state.copyWith(amount: event.amount, error: null));
    });
    on<SubmitStockEvent>((event, emit) async {
      if (state.name.isEmpty ||
          state.amount.isEmpty ||
          state.imagePath == null) {
        emit(state.copyWith(error: 'Semua field wajib diisi'));
        return;
      }
      emit(state.copyWith(isLoading: true, error: null));
      try {
        // Kompresi gambar terlebih dahulu
        final compressedFile = await _compressImage(state.imagePath!);
        if (compressedFile == null) {
          emit(
            state.copyWith(
              isLoading: false,
              error: 'Gagal mengkompresi gambar',
            ),
          );
          return;
        }

        // Upload ke Supabase Storage
        final imageUrl = await _uploadImageToSupabase(compressedFile.path);
        if (imageUrl == null) {
          emit(
            state.copyWith(
              isLoading: false,
              error: 'Gagal upload gambar ke Supabase Storage',
            ),
          );
          return;
        }

        // Simpan ke Firestore
        await _firestore.collection('ingredients').add({
          'name': state.name,
          'stock_amount': int.tryParse(state.amount) ?? 0,
          'image_url': imageUrl,
          'created_at': DateTime.now(),
        });

        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e'));
      }
    });
  }

  Future<File?> _compressImage(String path) async {
    final file = File(path);
    return await ImageCompressor.compressImage(file);
  }

  Future<String?> _uploadImageToSupabase(String path) async {
    final file = File(path);
    return await SupabaseStorageService.uploadFile(file);
  }
}
