# Splash Screen

Fitur splash screen pada aplikasi Bakso Djatigiri menampilkan halaman pembuka dengan logo dan nama aplikasi.

## Struktur Folder

```
splash/
└── presentation/
    └── splash_screen.dart    # Implementasi UI splash screen
```

## Implementasi

Implementasi splash screen menggunakan beberapa komponen utama:

1. **StatefulWidget** dengan **SingleTickerProviderStateMixin** untuk animasi
2. **AnimationController** dan **Animation** untuk efek fade in dan scaling
3. **Timer** untuk navigasi otomatis setelah beberapa detik
4. **Gradient background** menggunakan style dari color_pallete.dart
5. **Named Route Navigation** dengan custom transition animation

## Cara Kerja

1. **Initialization**:

   - AnimationController diinisialisasi dengan durasi 1.5 detik
   - Dua jenis animasi dibuat: fade dan scale

2. **Animation**:

   - Logo dan teks akan muncul dengan efek fade in (opacity 0 ke 1)
   - Bersamaan dengan itu, terjadi efek scaling (dari 0.8 ke 1.0)

3. **Auto Navigation**:
   - Setelah 3 detik, splash screen akan otomatis berganti ke halaman authentication
   - Perpindahan halaman menggunakan named route ('/auth') dengan custom transition melalui onGenerateRoute

## Aset yang Digunakan

- Logo:
  - `assets/images/logo_bakso_djatigiri.png` (versi utama)
  - `assets/images/logo BD 1.png` (versi alternatif)
- Gradient background: `diagonal01` dari color_pallete.dart

## Komponen UI

1. **Background**: Container dengan gradient diagonal
2. **Logo**: Image asset dengan ukuran responsif (maks 200x200)
3. **Nama Aplikasi**: Text "Bakso Djatigiri" dengan style tebal
4. **Tagline**: Text "Nikmat - Hangat - Terjangkau"
5. **Loading Indicator**: CircularProgressIndicator untuk menunjukkan proses loading

## Penggunaan

Splash screen dikonfigurasi sebagai halaman awal aplikasi di main.dart menggunakan property `home`:

```dart
MaterialApp(
  // ...
  home: const SplashScreen(),
  onGenerateRoute: (settings) {
    // Logic untuk menangani named routes dengan custom transition
    // ...
  },
)
```

## Perbaikan yang Telah Dilakukan

1. **Masalah Loading Gambar**:

   - Menambahkan error handling pada Image.asset
   - Menyediakan alternatif nama file (dengan dan tanpa spasi)
   - Membuat fallback icon jika kedua gambar tidak dapat dimuat

2. **Navigasi**:

   - Mengganti penggunaan pushReplacement dengan pushReplacementNamed
   - Menggunakan named route '/auth' alih-alih class AuthWrapper secara langsung
   - Implementasi onGenerateRoute untuk mempertahankan animasi transisi custom

3. **UI Responsif**:

   - Menggunakan MediaQuery untuk menyesuaikan ukuran logo dengan layar
   - Menambahkan width dan height infinity pada container utama
   - Menambahkan textAlign center untuk teks

4. **Indikator Loading**:

   - Menambahkan CircularProgressIndicator untuk memberikan feedback visual kepada pengguna

5. **Konfigurasi**:

   - Menghapus route '/' dari routes table untuk mencegah konflik dengan home property
   - Menggunakan onGenerateRoute untuk menangani semua navigasi dengan transisi custom
