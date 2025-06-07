# Fitur Menu - Bakso Djatigiri

## Deskripsi

Fitur Menu merupakan bagian dari aplikasi Bakso Djatigiri yang memungkinkan pengguna untuk mengelola menu yang tersedia di toko. Fitur ini menggunakan Clean Architecture dengan pemisahan antara data, domain, dan presentation layer.

## Fungsionalitas

- Melihat daftar menu
- Mencari menu berdasarkan nama
- Menambahkan menu baru dengan gambar dan bahan-bahan yang dibutuhkan
- Mengedit detail menu (nama, harga, gambar, dan bahan-bahan)
- Menghapus menu yang tidak digunakan lagi
- Perhitungan stok menu secara otomatis berdasarkan ketersediaan bahan

## Struktur Folder

```
menu/
├── bloc/                     # State management
│   ├── create_menu_bloc.dart # BLoC untuk membuat menu baru
│   ├── delete_menu_bloc.dart # BLoC untuk menghapus menu
│   ├── edit_menu_bloc.dart   # BLoC untuk mengedit menu
│   └── menu_bloc.dart        # BLoC untuk daftar menu
├── data/                     # Data layer
│   ├── datasources/          # Data sources
│   └── repositories/         # Repository implementations
├── domain/                   # Domain layer
│   ├── entities/             # Business objects
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Use cases
└── presentation/             # UI layer
    ├── create_menu.dart      # Halaman tambah menu
    ├── delete_menu_dialog.dart # Dialog konfirmasi hapus
    ├── edit_menu.dart        # Halaman edit menu
    └── page_menu.dart        # Halaman daftar menu
```

## Entity Models

- `MenuEntity`: Representasi menu dengan properti id, name, price, stock, imageUrl, dan createdAt
- `MenuRequirementEntity`: Representasi kebutuhan bahan untuk setiap menu dengan properti menuId, ingredientId, ingredientName, dan requiredAmount

## Use Cases

- `AddMenuUseCase`: Menambahkan menu baru ke Firestore
- `GetMenuUseCase`: Mendapatkan detail menu berdasarkan ID
- `UpdateMenuUseCase`: Memperbarui detail menu
- `DeleteMenuUseCase`: Menghapus menu dari Firestore
- `GetMenuRequirementsUseCase`: Mendapatkan daftar bahan yang dibutuhkan menu
- `UpdateMenuRequirementsUseCase`: Memperbarui daftar bahan yang dibutuhkan menu
- `CalculateMenuStockUseCase`: Menghitung stok menu berdasarkan ketersediaan bahan

## BLoC (Business Logic Components)

- `MenuBloc`: Mengelola state untuk halaman daftar menu
- `CreateMenuBloc`: Mengelola state untuk proses pembuatan menu baru
- `EditMenuBloc`: Mengelola state untuk proses edit menu
- `DeleteMenuBloc`: Mengelola state untuk proses hapus menu

## Integrasi dengan Fitur Lain

- **Stock Management**: Menu menggunakan data dari fitur Stock untuk menentukan bahan yang tersedia
- **Supabase Storage**: Gambar menu disimpan menggunakan Supabase Storage

## Cara Penggunaan

1. Lihat daftar menu di halaman Menu
2. Tambahkan menu baru dengan menekan tombol "+" di AppBar
3. Edit menu dengan menekan menu yang ingin diubah
4. Hapus menu dengan menekan tombol hapus di halaman edit menu
