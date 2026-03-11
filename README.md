# Dokumentasi API `setup-summary-api.sh` + Integrasi `MigrasiPotatobot`

Dokumen ini menjelaskan endpoint API yang dibuat dari `setup-summary-api.sh` dan endpoint mana saja yang dipakai oleh bot `MigrasiPotatobot` .

## Install API di VPS (SC potato)

```bash
curl -fL --retry 5 --retry-delay 2 https://raw.githubusercontent.com/harismy/apiCekTotalUserPotato/main/setup-summary-api.sh -o /tmp/setup-summary-api.sh
sed -i 's/\r$//' /tmp/setup-summary-api.sh
chmod +x /tmp/setup-summary-api.sh
bash /tmp/setup-summary-api.sh
```

Default API listen di port `8789`.

## Auth API

- Header wajib: `x-sync-token: <TOKEN>`
- Jika `USE_DB_AUTH=1` (default), token harus cocok dengan kolom `servers.key` di `potato.db`.

---

## Daftar Endpoint API

### 1) Health
- `GET /health`
- Fungsi: cek service API aktif.

### 2) Ringkasan akun aktif
- `GET /internal/account-summary`
- Fungsi: total akun aktif per layanan (`ssh/vmess/vless/trojan`).

### 3) Cek masa aktif akun per username
- `GET /internal/account-expiry?username=<USERNAME>`
- Fungsi: cari expiry akun berdasarkan username.

### 4) Ringkasan expired harian
- `GET /internal/expiry-summary?date=YYYY-MM-DD`
- Fungsi: total akun expired per hari.

### 5) Trafik vnstat harian/bulanan
- `GET /internal/vnstat-daily`
- Fungsi: ambil trafik harian + bulanan dari vnstat.

### 6) Export akun (untuk migrasi)
- `GET /internal/export-accounts?type=<ssh|zivpn|udp_http|vmess|vless|trojan>&limit=<N>`
- Fungsi: ambil akun dari DB sumber (urutan terbaru `rowid DESC`).

### 7) Import akun (untuk migrasi)
- `POST /internal/import-accounts`
- Body:
  ```json
  {
    "type": "ssh",
    "accounts": [ ... ]
  }
  ```
- Fungsi:
  - insert/replace akun ke DB tujuan,
  - untuk `ssh/zivpn/udp_http`: sinkron user Linux (useradd/chpasswd/chage),
  - untuk `zivpn`: sinkron `/etc/zivpn/config.json`.

### 8) Delete akun by username (untuk migrasi move)
- `POST /internal/delete-accounts`
- Body:
  ```json
  {
    "type": "ssh",
    "usernames": ["user1","user2"]
  }
  ```
- Fungsi: hapus akun terpilih dari DB (dan sinkron linux user / zivpn config untuk tipe ssh-like).

### 9) Delete semua akun ssh/zivpn
- `POST /internal/delete-all-accounts`
- Body:
  ```json
  {
    "type": "ssh"
  }
  ```
- Fungsi: hapus massal akun SSH/ZIVPN (DB + linux user + config zivpn).

---

## Endpoint yang dipakai `MigrasiPotatobot` (hanya 3 menu utama)

`MigrasiPotatobot` hanya punya 3 menu:

1. **Cek Bandwidth Server**
2. **Migrasi User Server**
3. **Hapus Semua Akun SSH/ZIVPN**

Endpoint yang dipakai:

- Menu **Cek Bandwidth Server**
  - `GET /internal/account-summary`
  - `GET /internal/vnstat-daily`

- Menu **Migrasi User Server**
  - `GET /internal/export-accounts`
  - `POST /internal/import-accounts`
  - `POST /internal/delete-accounts`

- Menu **Hapus Semua Akun SSH/ZIVPN**
  - `POST /internal/delete-all-accounts`

> Catatan: di `MigrasiPotatobot`, user selalu input manual `hostname + key` untuk sumber/tujuan. Bot tidak menyimpan data submit tersebut.

---

## Integrasi dengan Bot Utama

Untuk fitur lain di luar 3 menu utama `MigrasiPotatobot`, gunakan bot utama:

- Repo: https://github.com/harismy/BotVPN

Endpoint lain seperti `account-expiry`, `expiry-summary`, dsb bisa tetap dipakai oleh bot utama (`BotVPN`) sesuai kebutuhan integrasi.

