# Bakso Djatigiri App

Aplikasi manajemen untuk bisnis Bakso Djatigiri menggunakan Flutter dan Firebase.

## Teknologi yang Digunakan

- **Flutter**: Framework UI untuk pengembangan aplikasi mobile cross-platform
- **Firebase**: Platform backend-as-a-service
  - **Firestore**: Database NoSQL untuk penyimpanan data
  - **Firebase Auth**: Autentikasi pengguna
- **Supabase Storage**: Penyimpanan file dan gambar
- **BLoC Pattern**: State management
- **Clean Architecture**: Arsitektur aplikasi
- **Dependency Injection**: Menggunakan package get_it dan injectable

## Struktur Proyek

Proyek ini mengikuti prinsip Clean Architecture dengan struktur folder sebagai berikut:

```
lib/
├── config/                     # Konfigurasi aplikasi
│   └── supabase_storage.dart   # Konfigurasi Supabase Storage
├── core/                       # Komponen inti yang digunakan di seluruh aplikasi
│   ├── animation/              # Animasi custom
│   ├── theme/                  # Tema aplikasi (warna, font, dll)
│   ├── utils/                  # Utility functions
│   └── widgets/                # Widget yang dapat digunakan kembali
└── features/                   # Fitur-fitur aplikasi
    ├── auth/                   # Fitur autentikasi
    │   ├── bloc/               # State management untuk auth
    │   ├── data/               # Data layer (model, repository impl, data source)
    │   ├── domain/             # Domain layer (entity, repository interface, use case)
    │   └── presentation/       # UI layer (pages, widgets)
    └── stock/                  # Fitur manajemen stock
        ├── bloc/               # State management untuk stock
        ├── data/               # Data layer
        ├── domain/             # Domain layer
        └── presentation/       # UI layer
```

## Penjelasan Clean Architecture

Setiap fitur dalam aplikasi ini mengikuti prinsip Clean Architecture yang terdiri dari 3 layer utama:

### 1. Domain Layer

Layer ini berisi aturan bisnis inti aplikasi dan tidak bergantung pada framework atau teknologi eksternal.

- **Entities**: Objek bisnis murni
- **Repositories (interface)**: Kontrak untuk akses data
- **Use Cases**: Implementasi logika bisnis spesifik

### 2. Data Layer

Layer ini berisi implementasi dari repository dan interaksi dengan sumber data eksternal.

- **Models**: Representasi data dari sumber eksternal
- **Data Sources**: Interaksi dengan API/database
- **Repository Implementations**: Implementasi dari repository interface

### 3. Presentation Layer

Layer ini berisi UI dan state management.

- **BLoC**: State management untuk UI
- **Pages**: Halaman UI
- **Widgets**: Komponen UI yang dapat digunakan kembali

## Alur Data

1. **UI (Presentation)** memanggil method pada BLoC.
2. **BLoC** memanggil use case yang sesuai.
3. **Use Case** memanggil method pada repository.
4. **Repository** menggunakan data source untuk mengambil/menyimpan data.
5. **Data Source** berkomunikasi dengan API/database eksternal.
6. Data mengalir kembali ke UI melalui jalur yang sama.

## Keuntungan Struktur Ini

1. **Separation of Concerns**: Setiap layer memiliki tanggung jawab yang jelas.
2. **Testability**: Mudah melakukan unit testing pada setiap layer.
3. **Maintainability**: Kode lebih mudah dipelihara dan dikembangkan.
4. **Scalability**: Mudah menambahkan fitur baru tanpa mengubah kode yang sudah ada.
5. **Framework Independence**: Domain layer tidak bergantung pada framework eksternal.
