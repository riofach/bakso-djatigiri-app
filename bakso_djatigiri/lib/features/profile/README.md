# Fitur Profile (User Profile)

Fitur ini memungkinkan pengguna untuk melihat profil mereka dan melakukan logout dari aplikasi. Untuk pengguna dengan role owner, disediakan akses untuk mengelola user.

## Struktur

Fitur ini dibangun menggunakan Clean Architecture dengan struktur sebagai berikut:

```
profile/
├── bloc/
│   └── profile_bloc.dart            # State management untuk profile
├── data/
│   ├── datasources/
│   │   └── profile_data_source.dart # Data source untuk mengakses Firebase
│   ├── models/
│   │   └── user_model.dart          # Model untuk data user
│   └── repositories/
│       └── profile_repository_impl.dart # Implementasi repository
├── domain/
│   ├── entities/
│   │   └── user.dart                # Entity user
│   ├── repositories/
│   │   └── profile_repository.dart  # Interface repository
│   └── usecases/
│       ├── get_current_user_usecase.dart # Use case untuk mendapatkan user saat ini
│       ├── sign_out_usecase.dart    # Use case untuk sign out
│       └── get_all_users_usecase.dart   # Use case untuk mendapatkan semua user
└── presentation/
    ├── page_profile.dart            # Halaman profil utama
    └── manage_users_page.dart       # Halaman kelola user (hanya owner)
```

## Fitur

1. **Melihat Profil Pengguna**

   - Menampilkan foto profil default dari ShadCDN
   - Menampilkan nama, email, dan role pengguna
   - Tampilan berbeda untuk role owner dan kasir

2. **Logout**

   - Memungkinkan pengguna untuk keluar dari aplikasi
   - Kembali ke halaman login setelah logout

3. **Kelola User (Khusus Owner)**
   - Tombol untuk mengakses halaman kelola user hanya muncul untuk owner
   - Melihat daftar semua user yang terdaftar
   - Menampilkan status (active/inactive) dan role setiap user

## Penggunaan Firebase

Fitur ini memanfaatkan Firebase Authentication dan Firestore:

1. **Firebase Authentication**

   - Digunakan untuk logout dan memeriksa user yang sedang login

2. **Firestore**
   - Collection 'users' untuk menyimpan data profil pengguna
   - Mendapatkan data user berdasarkan uid dari Auth

## UI & UX

Fitur ini mengikuti design system yang sama dengan fitur-fitur lain dalam aplikasi:

- Menggunakan color palette yang sama dari `color_pallete.dart`
- Custom navigation bar dengan profile sebagai menu aktif
- Animasi transisi yang konsisten dengan `page_transitions.dart`
