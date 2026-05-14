# UMKM-core-6 — Aplikasi Manajemen Portofolio

Tugas Praktikum Pemrograman Berbasis Mobile 2026  
**Achmad Faiez Jatmiko — 242410103038**  
Program Studi Informatika, Fakultas Ilmu Komputer, Universitas Jember

---

## Deskripsi

UMKM-core-6 adalah aplikasi mobile manajemen portofolio yang dibangun menggunakan Flutter. Aplikasi ini mengimplementasikan komunikasi client-server melalui REST API dengan autentikasi berbasis Bearer Token.

---

## Fitur

- Login menggunakan NIM dan password dengan autentikasi token
- Penyimpanan token secara aman menggunakan `flutter_secure_storage`
- Menampilkan daftar portofolio dari server (GET /api/products)
- Menambah data portofolio baru (POST /api/products)
- Halaman detail untuk setiap item portofolio
- Format mata uang Rupiah otomatis tanpa library tambahan
- Notifikasi interaktif menggunakan SnackBar floating

---

## Teknologi

| Komponen | Detail |
|---|---|
| Bahasa | Dart |
| Framework | Flutter |
| HTTP Client | `http` |
| Secure Storage | `flutter_secure_storage` |
| Platform | Android / Windows Desktop |
| API Base URL | `https://task.itprojects.web.id` |

---

## Struktur Project

```
lib/
├── models/
│   └── product_model.dart     # Class model representasi data produk dari API
├── pages/
│   ├── add_product_page.dart  # Halaman form tambah produk baru
│   ├── catalog_page.dart      # Halaman utama daftar portofolio
│   ├── detail_page.dart       # Halaman detail item portofolio
│   └── login_page.dart        # Halaman login & HTTP POST autentikasi
└── main.dart                  # Entry point & konfigurasi rute
```

---

## Cara Menjalankan

1. Clone repository ini
   ```bash
   git clone https://github.com/USERNAME/NAMA_REPO.git
   cd NAMA_REPO
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi
   ```bash
   flutter run
   ```

4. Login menggunakan NIM sebagai username dan password

---

## API Endpoints

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/api/auth/login` | Login & ambil token |
| GET | `/api/products` | Ambil daftar produk |
| POST | `/api/products` | Tambah produk baru |
| POST | `/api/products/submit` | Submit tugas |

Semua endpoint kecuali login wajib menyertakan header:
```
Authorization: Bearer <token>
```

---
