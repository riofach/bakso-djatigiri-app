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

## Error Handling & UX Autentikasi

- Semua error dari proses login/register di-handle dan ditampilkan ke user secara informatif (misal: email tidak terdaftar, password salah, email sudah digunakan, akun tidak aktif, dsb).
- Error dari Firebase di-mapping ke pesan yang ramah user menggunakan custom exception (`AuthException`).
- Pesan error akan muncul di halaman login/register melalui SnackBar.
- Validasi form dilakukan sebelum submit, sehingga user tidak bisa submit data kosong atau format tidak valid.
- Jika login/register berhasil, user akan diarahkan ke halaman Home dan status login disimpan di shared_preferences.
