# BotVPN 1FORCR
Bot Telegram untuk manajemen layanan VPN yang terintegrasi dengan API AutoScript Potato.  
Referensi awal dari [arivpnstores](https://github.com/arivpnstores), based BOT: Fightertunnel.

---

## Instalasi Otomatis
Rekomendasi OS: Ubuntu 24 / Debian 12

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update -y && apt install -y git && apt install -y curl && curl -L -k -sS https://raw.githubusercontent.com/harismy/BotVPN/main/start -o start && bash start sellvpn && [ $? -eq 0 ] && rm -f start
```

---

## Instalasi API Summary (VPS Tunnel)
Untuk fitur sinkronisasi total akun aktif dari VPS tunnel ke bot, jalankan auto installer berikut di VPS yang bakal di pasang API-nya:

```bash
curl -fL --retry 5 --retry-delay 2 https://raw.githubusercontent.com/harismy/apiCekTotalUserPotato/main/setup-summary-api.sh -o /tmp/setup-summary-api.sh
sed -i 's/\r$//' /tmp/setup-summary-api.sh
chmod +x /tmp/setup-summary-api.sh
SYNC_TOKEN='ISI_TOKEN_RAHASIA' bash /tmp/setup-summary-api.sh
```

Setelah selesai, endpoint yang dipakai bot:
- `GET /internal/account-summary`
- Header: `x-sync-token: <SYNC_TOKEN>`

## Bot Telegram
[Menuju Bot Cihuyyyyy](https://t.me/BOT1FORCR_STORE_bot)

---

## Fitur Utama

### Untuk User
- Pembelian akun otomatis: SSH, VMESS, VLESS, TROJAN, ZiVPN, dan UDP HTTP Custom
- Trial akun
- Deposit saldo + pembayaran QRIS otomatis
- Top up manual via QRIS (bisa diaktif/nonaktifkan admin)

### Untuk Admin
- Dashboard admin berbasis menu (Server/Saldo/Reseller/Tools)
- Manajemen user & saldo (tambah/hapus/cek saldo)
- Manajemen server (add/edit/list/detail/hapus/reset)
- Backup database manual + auto backup 24 jam
- Statistik reseller lengkap: `/resellerstats` & `/allresellerstats`
- Help admin dari menu atau `/helpadmin`

### Untuk Reseller
- Akses server khusus reseller
- Statistik penjualan bulanan
- Tools reseller (hapus/lock/unlock akun)

---

## Update Terbaru
- UDP HTTP Custom sudah didukung penuh, termasuk output akun yang ringkas dan format siap copy.
- Server sekarang punya flag `support_zivpn` dan `support_udp_http`, jadi bot hanya menampilkan server yang benar-benar mendukung layanannya.
- Syarat reseller disederhanakan: sekarang hanya melihat total top up bulan berjalan, bukan jumlah akun.
- Saat admin mengubah syarat reseller, semua reseller otomatis mendapat pemberitahuan. Ada reminder H-5 sebelum reset bulan.
- Admin bisa trigger manual cek syarat reseller dan trigger backup langsung dari menu tools.
- Top up manual bisa diaktifkan/nonaktifkan lewat menu admin, tombolnya ikut muncul/hilang di menu user.
- Statistik reseller diperjelas: pendapatan dihitung dari transaksi akun (create/renew), top up dihitung dari transaksi deposit.
- `/allresellerstats` kini menampilkan username Telegram, bukan hanya ID.
- Trial tidak ikut dihitung di statistik (berdasarkan `reference_id`).
- ZIVPN lebih ramah: jika username sudah ada akan diminta ulang, dan password dibuat random otomatis.
- Konfigurasi API dirapikan: ORKUT username/token dan API key sekarang disimpan di `.vars.json`.

---

## Sistem Pembayaran (Top Up Otomatis)

### Data QRIS
Gunakan tools berikut untuk extract data QRIS:  
https://qreader.online/

### Setup API Cek Payment
Input saat instalasi melalui `start` (disimpan ke `.vars.json`):
- `ORKUT_USERNAME`
- `ORKUT_TOKEN`
- `Untuk api key bisa chat ke +6289612745096`

Jika `ORKUT_USERNAME/ORKUT_TOKEN` belum diisi:
- Menu top up otomatis akan nonaktif
- Bot menampilkan notifikasi ke user

---

## Database
Database utama: `sellvpn.db`

Auto-migrasi saat bot start:
- Buat tabel `pending_deposits` bila belum ada
- Tambah kolom `support_zivpn` dan `support_udp_http` di tabel `Server`

---

## Catatan
Pastikan file disimpan UTF-8 agar emoji tampil normal.



