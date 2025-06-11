# Fitur Histori Transaksi (Transaction History)

Fitur ini memungkinkan pengguna untuk melihat riwayat transaksi yang telah dilakukan di Bakso Djatigiri.

## Struktur

Fitur ini dibangun menggunakan Clean Architecture dengan struktur sebagai berikut:

```
history/
├── bloc/
│   └── history_bloc.dart             # State management untuk histori transaksi
├── data/
│   ├── datasources/
│   │   └── history_data_source.dart  # Data source untuk mengakses Firestore
│   ├── models/
│   │   ├── transaction_model.dart    # Model untuk data transaksi
│   │   └── transaction_item_model.dart # Model untuk item transaksi
│   └── repositories/
│       └── history_repository_impl.dart # Implementasi repository
├── domain/
│   ├── entities/
│   │   ├── transaction.dart         # Entity transaksi
│   │   └── transaction_item.dart    # Entity item transaksi
│   ├── repositories/
│   │   └── history_repository.dart  # Interface repository
│   └── usecases/
│       ├── get_transactions_usecase.dart      # Use case untuk mendapatkan transaksi
│       ├── get_transaction_items_usecase.dart # Use case untuk mendapatkan detail transaksi
│       └── watch_transactions_usecase.dart    # Use case untuk memantau transaksi
└── presentation/
    ├── page_history.dart            # Halaman utama histori transaksi
    └── transaction_detail_page.dart # Halaman detail transaksi
```

## Fitur

1. **Melihat Daftar Transaksi**

   - Menampilkan transaksi dalam urutan waktu terbaru
   - Dikelompokkan berdasarkan tanggal
   - Pencarian berdasarkan kode transaksi atau total

2. **Melihat Detail Transaksi**

   - Menampilkan semua item yang dibeli dalam transaksi
   - Menampilkan harga per item dan subtotal
   - Menampilkan total transaksi

3. **Pembaruan Realtime**
   - Menggunakan Firestore stream untuk pembaruan data secara realtime
   - Swipe down untuk refresh manual

## Penggunaan Firebase

Fitur ini memanfaatkan dua koleksi dari Firestore:

1. **transactions**

   - Menyimpan data transaksi utama seperti kode, timestamp, kasir, dan total

2. **transaction_items**
   - Menyimpan detail item yang dibeli dalam transaksi
   - Foreign key ke transactions melalui field `transaction_id`

## UI & UX

Fitur ini mengikuti design system yang sama dengan fitur-fitur lain dalam aplikasi:

- Menggunakan color palette yang sama
- Memiliki animasi transisi yang konsisten
- Custom navigation bar dengan history sebagai menu aktif
