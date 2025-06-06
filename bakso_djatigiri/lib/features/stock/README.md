# Struktur Fitur Stock

## Penjelasan Struktur Clean Architecture

Fitur Stock mengikuti prinsip Clean Architecture dengan struktur folder sebagai berikut:

### 1. Domain Layer

Berisi aturan bisnis inti dan kontrak (interface) yang independen dari framework atau teknologi eksternal.

- `domain/entities/`: Berisi entity class yang merupakan objek bisnis murni.

  - `ingredient_entity.dart`: Entity untuk bahan/ingredient.

- `domain/repositories/`: Berisi interface repository yang mendefinisikan kontrak.

  - `stock_repository.dart`: Interface untuk repository stock.

- `domain/usecases/`: Berisi use case yang mengimplementasikan logika bisnis spesifik.
  - `add_ingredient_usecase.dart`: Use case untuk menambahkan ingredient.
  - `delete_ingredient_usecase.dart`: Use case untuk menghapus ingredient.
  - `get_ingredients_usecase.dart`: Use case untuk mendapatkan daftar ingredient.
  - `update_ingredient_usecase.dart`: Use case untuk mengupdate ingredient.

### 2. Data Layer

Berisi implementasi repository dan data source yang berinteraksi dengan sumber data eksternal.

- `data/models/`: Berisi model data yang mewakili entitas dari sumber data.

  - `ingredient_model.dart`: Model untuk ingredient dari Firestore.

- `data/datasources/`: Berisi class yang berinteraksi langsung dengan sumber data.

  - `stock_data_source.dart`: Data source untuk berinteraksi dengan Firestore dan Supabase Storage.

- `data/repositories/`: Berisi implementasi konkret dari repository yang didefinisikan di domain layer.
  - `stock_repository_impl.dart`: Implementasi dari StockRepository.

### 3. Presentation Layer

Berisi UI dan state management (BLoC).

- `bloc/`: Berisi BLoC untuk mengelola state aplikasi.

  - `stock_bloc.dart`: BLoC untuk menampilkan daftar stock.
  - `create_stock_bloc.dart`: BLoC untuk menambah stock baru.
  - `edit_stock_bloc.dart`: BLoC untuk mengedit stock.
  - `delete_stock_bloc.dart`: BLoC untuk menghapus stock.

- `presentation/`: Berisi halaman UI dan komponen.
  - `page_stock.dart`: Halaman utama daftar stock.
  - `create_stock.dart`: Halaman form tambah stock.
  - `edit_stock.dart`: Halaman form edit stock.
  - `delete_stock_dialog.dart`: Dialog konfirmasi hapus stock.

## Alur Data

1. **UI (Presentation)** memanggil method pada BLoC.
2. **BLoC** memanggil use case yang sesuai.
3. **Use Case** memanggil method pada repository.
4. **Repository** menggunakan data source untuk mengambil/menyimpan data.
5. **Data Source** berkomunikasi dengan API/database eksternal (Firestore, Supabase Storage).
6. Data mengalir kembali ke UI melalui jalur yang sama.

## Dependency Injection

Menggunakan package `get_it` dan `injectable` untuk dependency injection, memudahkan testing dan menjaga loose coupling antar layer.

## Keuntungan Clean Architecture

1. **Separation of Concerns**: Setiap layer memiliki tanggung jawab yang jelas.
2. **Testability**: Mudah melakukan unit testing pada setiap layer.
3. **Maintainability**: Kode lebih mudah dipelihara dan dikembangkan.
4. **Scalability**: Mudah menambahkan fitur baru tanpa mengubah kode yang sudah ada.
5. **Framework Independence**: Domain layer tidak bergantung pada framework eksternal.
