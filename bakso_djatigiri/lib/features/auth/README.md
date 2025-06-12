# Struktur Fitur Auth

## Penjelasan Folder

- `domain/` : Berisi entity, repository abstrak, dan usecase autentikasi. Semua logika bisnis inti dan kontrak berada di sini. Contoh: `user_entity.dart`, `auth_repository.dart`, `login_usecase.dart`, dll.
- `data/` : Berisi model, data source (integrasi ke Firebase Auth & Firestore), dan implementasi repository. Semua interaksi ke sumber data eksternal dan mapping data ke domain. Contoh: `user_model.dart`, `auth_data_source.dart`, `auth_repository_impl.dart`.
- `bloc/` : Berisi state management (Bloc/Cubit) untuk autentikasi, menghubungkan domain ke UI. Contoh: `auth_bloc.dart`.
- `presentation/pages/` : Berisi halaman UI seperti login, register, home, dan auth wrapper. Contoh: `login_page.dart`, `register_page.dart`, `home_page.dart`, `auth_wrapper.dart`.
- `presentation/widgets/` : Berisi widget reusable untuk form autentikasi. Contoh: `auth_text_field.dart`.

## Alur Routing & UX

- Setelah login/register sukses, user otomatis diarahkan ke halaman Home yang menampilkan nama, email, dan role.
- AuthWrapper akan redirect otomatis ke /home jika sudah login, atau ke /login jika belum login.
- Semua validasi form, error handling, dan loading UX sudah diimplementasikan sesuai standar profesional.
- Semua transisi halaman menggunakan custom animation (fade transition) untuk pengalaman UX yang lebih baik.

## Desain UI

### Login Page

- Desain modern dengan konsistensi visual sesuai brand Bakso Djatigiri
- Tampilan form yang bersih dengan field email dan password
- Input field dengan validasi real-time dan tampilan error yang jelas
- Tombol login dengan warna primary dan efek loading yang profesional
- Toggle visibility password untuk UX yang lebih baik
- Responsive layout yang menyesuaikan dengan ukuran layar
- Menggunakan warna dan font yang konsisten dari design system aplikasi

### Auth Wrapper

- Layar loading dengan animasi pulsating yang menarik
- Background gradient yang menyatu dengan tema aplikasi
- Logo dan nama aplikasi yang ditampilkan secara profesional
- Indikator loading dengan efek animasi "breathing" untuk visual feedback yang lebih baik
- Pesan status yang informatif bagi pengguna

## Error Handling & UX Autentikasi

- Semua error dari proses login/register di-handle dan ditampilkan ke user secara informatif (misal: email tidak terdaftar, password salah, email sudah digunakan, akun tidak aktif, dsb).
- Error dari Firebase di-mapping ke pesan yang ramah user menggunakan custom exception (`AuthException`).
- Pesan error akan muncul di halaman login/register melalui SnackBar dengan warna yang sesuai (errorColor).
- Validasi form dilakukan sebelum submit, sehingga user tidak bisa submit data kosong atau format tidak valid.
- Jika login/register berhasil, user akan diarahkan ke halaman Home dan status login disimpan di shared_preferences.

## Keunggulan Implementasi

- **Clean Architecture**: Pemisahan yang jelas antara domain, data, dan presentation layer
- **Reusable Components**: Komponen UI yang dapat digunakan kembali (text field, buttons, dll)
- **Konsistensi Visual**: Penggunaan color_palette.dart untuk warna yang konsisten di seluruh aplikasi
- **Smooth Transitions**: Implementasi custom page transitions untuk UX yang lebih mulus
- **Responsive Design**: Layout yang menyesuaikan dengan berbagai ukuran layar
- **Error Handling**: Penanganan error yang komprehensif dengan feedback visual yang jelas
- **Animasi**: Animasi subtle yang meningkatkan pengalaman pengguna
