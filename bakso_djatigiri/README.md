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
    ├── stock/                  # Fitur manajemen stock
    │   ├── bloc/               # State management untuk stock
    │   ├── data/               # Data layer
    │   ├── domain/             # Domain layer
    │   └── presentation/       # UI layer
    ├── menu/                   # Fitur manajemen menu
    │   ├── bloc/               # State management untuk menu
    │   ├── data/               # Data layer
    │   ├── domain/             # Domain layer
    │   └── presentation/       # UI layer
    └── cashier/                # Fitur kasir
        ├── bloc/               # State management untuk kasir
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

## Fitur Aplikasi

### Autentikasi

- Login dengan email dan password
- Register untuk akun baru
- Validasi form dan penanganan error

### Manajemen Stock

- Lihat daftar bahan (stok)
- Tambah bahan baru dengan gambar dari galeri
- Edit bahan (nama, jumlah, gambar)
- Hapus bahan dengan konfirmasi

### Manajemen Menu

- Lihat daftar menu dalam bentuk grid
- Tambah menu baru dengan:
  - Gambar dari galeri
  - Nama dan harga
  - Pemilihan bahan yang dibutuhkan
  - Perhitungan stok otomatis berdasarkan ketersediaan bahan
- Edit menu (nama, harga, gambar)
- Hapus menu dengan konfirmasi

### Kasir

- Melihat daftar menu yang tersedia untuk dijual
- Menambahkan menu ke keranjang
- Pencarian menu berdasarkan nama
- Proses checkout dengan:
  - Input jumlah pembayaran
  - Perhitungan kembalian otomatis
  - Validasi pembayaran cukup
  - Pengurangan stok bahan secara otomatis
  - Update stok menu secara realtime berdasarkan ketersediaan bahan
- Riwayat transaksi dengan detail lengkap

## Sistem Perhitungan Stok

Aplikasi menggunakan sistem perhitungan stok otomatis dengan alur sebagai berikut:

1. **Menu Stock**: Stok menu dihitung secara otomatis berdasarkan ketersediaan bahan yang dibutuhkan.
2. **Menu Requirements**: Setiap menu memiliki daftar bahan dan jumlah yang dibutuhkan.
3. **Checkout Process**:
   - Saat transaksi, bahan yang dibutuhkan untuk menu akan dikurangi secara otomatis.
   - Stok bahan berkurang sesuai dengan jumlah yang dibutuhkan oleh menu.
   - Stok menu kemudian diperbarui secara realtime berdasarkan ketersediaan bahan terbaru.

Dengan sistem ini, memastikan bahwa menu hanya dapat dijual jika semua bahan yang dibutuhkan tersedia, dan stok selalu diperbarui secara akurat setelah setiap transaksi.

## Panduan Penggunaan Aplikasi

### Alur Penambahan Bahan (Ingredients)

1. Buka aplikasi dan login sebagai owner.
2. Navigasi ke halaman "Stock" melalui bottom navigation bar.
3. Tekan tombol "+" di sudut kanan atas untuk menambah bahan baru.
4. Isi formulir dengan informasi berikut:
   - Nama bahan (wajib)
   - Jumlah stok (wajib)
   - Gambar bahan (opsional) - dapat dipilih dari galeri
5. Tekan tombol "Simpan" untuk menyimpan bahan.
6. Sistem akan secara otomatis memperbarui stok menu yang menggunakan bahan tersebut.

### Alur Penambahan Menu

1. Buka aplikasi dan login sebagai owner.
2. Navigasi ke halaman "Menu" melalui bottom navigation bar.
3. Tekan tombol "+" di sudut kanan atas untuk menambah menu baru.
4. Isi formulir dengan informasi berikut:
   - Nama menu (wajib)
   - Harga (wajib)
   - Gambar menu (opsional) - dapat dipilih dari galeri
5. Pada bagian "Bahan yang Dibutuhkan", pilih bahan dan tentukan jumlah yang dibutuhkan untuk setiap menu.
   - Tekan tombol "+" untuk menambahkan bahan
   - Pilih bahan dari form yang muncul
   - Tentukan jumlah yang dibutuhkan
   - Ulangi untuk bahan lain jika diperlukan
6. Sistem akan otomatis menghitung stok menu berdasarkan ketersediaan bahan.
7. Tekan tombol "Simpan" untuk menyimpan menu.

### Alur Proses Kasir (Checkout)

1. Buka aplikasi dan login sebagai kasir atau owner.
2. Pada halaman "Home", Anda akan melihat daftar menu yang tersedia untuk dijual.
3. Pencarian menu dapat dilakukan menggunakan search bar di bagian atas.
4. Tambahkan menu ke keranjang dengan cara:
   - Tap pada menu untuk menambahkan ke keranjang
   - Atau tap tombol "+" di pojok kanan bawah kartu menu
5. Untuk melihat keranjang, tap icon keranjang di sudut kanan atas.
6. Di halaman keranjang:
   - Lihat daftar menu yang ditambahkan
   - Hapus menu jika diperlukan dengan swipe ke kiri
   - Lihat total harga
7. Untuk melakukan checkout:
   - Masukkan jumlah pembayaran dari pelanggan
   - Sistem akan otomatis menghitung kembalian
   - Pastikan pembayaran cukup (tidak kurang dari total)
8. Tekan tombol "Checkout" untuk memproses transaksi.
9. Setelah checkout berhasil:
   - Stok bahan akan otomatis berkurang sesuai dengan menu yang dibeli
   - Stok menu akan diperbarui berdasarkan ketersediaan bahan terbaru
   - Dialog konfirmasi akan muncul dengan informasi kembalian
10. Tekan "OK" pada dialog konfirmasi untuk kembali ke halaman menu.
11. Untuk me-refresh daftar menu dan melihat stok terbaru, gunakan tombol refresh di pojok kanan atas atau tarik layar ke bawah.

## Panduan Kontribusi untuk Tim

### Prasyarat

Sebelum Anda mulai, pastikan Anda memiliki:

- Flutter SDK (versi 3.3.0 atau lebih baru)
- Dart SDK (versi 3.0.0 atau lebih baru)
- Editor kode (VS Code, Android Studio, dll)
- Git
- Firebase CLI (untuk konfigurasi Firebase lokal)

### Persiapan Lingkungan Pengembangan

1. **Clone repositori**:

   ```bash
   git clone https://github.com/username/bakso_djatigiri.git
   cd bakso_djatigiri
   ```

2. **Instal dependencies**:

   ```bash
   flutter pub get
   ```

3. **Setup Firebase**:

   - Pastikan Anda memiliki akses ke proyek Firebase
   - Minta konfigurasi `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS) dari admin proyek
   - Letakkan file konfigurasi di direktori yang sesuai:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Setup Supabase Storage**:

   - Minta URL dan API Key Supabase dari admin proyek
   - Buat file `.env` di root proyek dengan format:

   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   ```

5. **Generate kode injectable**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Workflow Pengembangan

1. **Buat branch baru untuk fitur atau perbaikan**:

   ```bash
   git checkout -b feature/nama-fitur
   ```

   atau

   ```bash
   git checkout -b fix/nama-perbaikan
   ```

2. **Ikuti konvensi pengkodean**:

   - Gunakan Clean Architecture
   - Setiap fitur dalam folder terpisah
   - Nama file menggunakan snake_case
   - Nama class menggunakan PascalCase
   - Tambahkan komentar untuk fungsi kompleks

3. **Commit perubahan Anda**:

   ```bash
   git add .
   git commit -m "Deskripsi perubahan"
   ```

4. **Push ke repositori**:

   ```bash
   git push origin feature/nama-fitur
   ```

5. **Buat Pull Request (PR) ke branch `master`**:
   - Berikan judul yang jelas
   - Jelaskan perubahan yang Anda buat
   - Lampirkan screenshot jika ada perubahan UI
   - Tag reviewer yang relevan

### Proses Review

1. Minimal 1 reviewer harus menyetujui PR sebelum merge
2. Pastikan semua komentar sudah ditindaklanjuti
3. Pastikan build CI berhasil

### Debugging

1. **Logging**:

   - Gunakan `debugPrint()` untuk logging (bukan `print()`)
   - Format log: `'[NamaClass/NamaMethod] Pesan'`

2. **Firebase Analytics & Crashlytics**:
   - Gunakan Firebase Analytics untuk melacak alur pengguna
   - Crash akan dilaporkan otomatis ke Crashlytics

## Troubleshooting

### Masalah Umum dan Solusi

1. **Masalah Firebase Connection**:

   - Pastikan device memiliki koneksi internet
   - Verifikasi konfigurasi Firebase (`google-services.json`)
   - Cek konsol Firebase untuk aturan keamanan

2. **Masalah UI Rendering**:

   - Gunakan widget `ErrorBuilder` untuk menangani error UI
   - Pastikan data tidak null sebelum render
   - Gunakan `try-catch` untuk menangkap error

3. **Masalah Stok Menu Tidak Diperbarui**:

   - Gunakan tombol refresh untuk memuat ulang menu
   - Pastikan proses checkout selesai dengan benar
   - Periksa log untuk memastikan stok bahan berhasil dikurangi

4. **Masalah Injection**:
   - Jalankan `flutter pub run build_runner build --delete-conflicting-outputs`
   - Pastikan semua dependency terdaftar dengan benar di `injection.dart`
