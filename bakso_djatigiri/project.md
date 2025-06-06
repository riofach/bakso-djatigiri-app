# Panduan Project

**UMKM Kasir & Manajemen Stok Mie Ayam Bakso Djatigiri - Project Overview**

---

### ✅ Maksud dan Tujuan

Membangun sebuah aplikasi kasir digital berbasis mobile untuk UMKM "Mie Ayam Bakso Djatigiri" agar dapat:

- Mempermudah pencatatan transaksi harian
- Mengelola stok bahan secara akurat
- Menghindari kekurangan bahan saat pemesanan
- Melihat riwayat transaksi dengan transparan

Aplikasi akan dibangun dengan pendekatan profesional menggunakan Flutter dan Firebase berdasarkan arsitektur Clean Architecture agar maintainable, scalable, dan siap production.

---

### ⚖️ Teknologi yang Digunakan

- **Flutter** (frontend & backend dalam 1 codebase)
- **Firebase:**

  - Firestore (NoSQL database)
  - Firebase Auth (Email/Password Auth)
  - Firebase Storage (tidak digunakan; digantikan oleh supabase storage)

- **supabase storage** (image hosting & CDN)
- **get_it** & **injectable** (Dependency Injection)
- **flutter_bloc** (State Management)
- **equatable** (value equality)
- **formz** (form validation)
- **go_router** (routing/navigation)
- **cloud_functions** (opsional untuk rule kustom)

---

### 📊 Skema Database - Firestore

```dbml
Table users {
  uid varchar [pk]
  name varchar
  email varchar
  status varchar // 'active' atau 'inactive'
  role varchar // 'owner' atau 'kasir'
}

Table ingredients {
  id varchar [pk]
  name varchar
  stock_amount int
  image_url varchar
  created_at datetime
}

  Table menus {
    id varchar [pk]
    name varchar
    price int
    stock int
    image_url varchar
    created_at datetime
  }

Table menu_requirements {
  id varchar [pk]
  menu_id varchar [ref: > menus.id]
  ingredient_id varchar [ref: > ingredients.id]
  ingredient_name varchar
  required_amount int
}

Table transactions {
  id varchar [pk]
  transaction_code varchar
  timestamp datetime
  cashier_id varchar [ref: > users.uid]
  cashier_name varchar
  total int
  customer_payment int
  change int
}

Table transaction_items {
  id varchar [pk]
  transaction_id varchar [ref: > transactions.id]
  menu_id varchar [ref: > menus.id]
  menu_name varchar
  quantity int
  price_each int
  subtotal int
}
```

---

### 📂 Struktur Folder (Flutter Clean Architecture)

```
lib/
├── core/
├── config/
├── data/
├── domain/
├── features/
│   ├── auth/
│   ├── menu/
│   ├── stock/
│   ├── cashier/
│   ├── history/
│   └── dashboard/
└── main.dart
```

---

### 👥 Role & Permissions

- **owner**:

  - Full access (manage semua data: menu, stock, user, transaksi)

- **kasir**:

  - Hanya bisa mengakses fitur kasir dan melihat menu yang tersedia
  - Tidak bisa CRUD stock/menu/user

---

### ⛓️ Rules & Business Logic

- Saat user login, role dicek untuk navigasi ke fitur yang tersedia
- User hanya bisa login jika statusnya `active`
- Menu hanya bisa dipesan jika semua bahan `cukup` (dibandingkan `menu_requirements`)
- Stok bahan otomatis dikurangi saat transaksi berhasil
- Tidak bisa checkout jika pembayaran kurang
- Riwayat transaksi disimpan lengkap dengan detail item dan kembalian

---

### 📊 Fitur-Fitur Utama

1. **Autentikasi Firebase Email/Password**
2. **Manajemen User** (role owner/kasir)
3. **Kasir**

   - Tambah menu ke keranjang
   - Checkout dengan input uang pembeli & hitung kembalian
   - Validasi stok bahan tersedia

4. **Stok Bahan**

   - CRUD bahan baku (nama, jumlah, gambar)

5. **Manajemen Menu**

   - CRUD menu (nama, harga, gambar, requirement bahan)
   - Tidak bisa simpan menu jika requirement bahan tidak ada

6. **Riwayat Transaksi**

   - List transaksi by date
   - Detail transaksi lengkap

---
