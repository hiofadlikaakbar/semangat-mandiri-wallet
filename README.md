## Nama

Hio Fadlika Akbar || 1123150077

# Semangat Mandiri Wallet

Semangat Mandiri Wallet adalah aplikasi Flutter yang berfungsi sebagai sistem dompet digital untuk mendukung ekosistem Semangat Mandiri Marketplace. Aplikasi ini digunakan untuk mengelola saldo pengguna, melakukan top up, serta mencatat semua transaksi yang terjadi baik dari top up maupun pembelian di marketplace.

---

## Fitur

* Login menggunakan akun yang terhubung dengan Semangat Mandiri Marketplace
* Menampilkan saldo user secara real-time (sinkron dengan marketplace)
* Top up saldo wallet

  * Top up dengan nominal minimal yang sudah disediakan
  * Top up dengan nominal custom
* Melihat riwayat transaksi

  * Transaksi dari top up
  * Transaksi dari pembelian di marketplace
* Update saldo secara otomatis ketika ada transaksi baru

---

## Tampilan Aplikasi

### Login

<img width="489" height="643" alt="Screenshot 2026-06-18 115213" src="https://github.com/user-attachments/assets/2f356af1-ad3d-4348-913a-5a8b9718422e" />

---

### Home / Dashboard Wallet (Saldo Real-time)

<img width="483" height="636" alt="Screenshot 2026-06-18 115258" src="https://github.com/user-attachments/assets/90777075-e883-4d65-ada8-fdd8cad67b50" />

---

### Top Up Saldo

<img width="485" height="574" alt="Screenshot 2026-06-18 115710" src="https://github.com/user-attachments/assets/3bf5ce07-de31-4717-992c-1b1be5b9f110" />

---

### Setelah Melakukan Top Up Saldo Akan Bertambah

<img width="484" height="610" alt="Screenshot 2026-06-18 115732" src="https://github.com/user-attachments/assets/d43400ce-cdf7-4f23-956a-17a36926ed52" />

---

## Teknologi yang Digunakan

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Real-time Database Sync (Firestore Stream)

---

## Integrasi Sistem

Aplikasi Wallet ini terhubung langsung dengan Semangat Mandiri Marketplace:

* Login menggunakan akun yang sama.
* Saldo user digunakan di Marketplace untuk proses checkout.
* Setiap pembelian di Marketplace otomatis mengurangi saldo Wallet.
* Setiap top up tercatat sebagai transaksi di Wallet.

---

## Alur Penggunaan

```text
Login
   │
   ▼
Home (Lihat Saldo Real-time)
   │
   ▼
Top Up / Tunggu Transaksi dari Marketplace
   │
   ▼
Saldo Berubah Otomatis
   │
   ▼
Lihat Riwayat Transaksi
```

---

## Video Demo
Demo Aplikasi: [Semangat Mandiri Marketplace - Demo Aplikasi](https://www.youtube.com/watch?v=jhByjaxZ4P4)
