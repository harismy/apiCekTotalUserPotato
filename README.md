## Dokumentasi API untuk dipasang di SC Potato 

API ini dipakai bot untuk sinkron total akun aktif dari VPS yang udah di pasang SC potato, dan untuk lookup tanggal expired akun berdasarkan username.

Base URL disesuaikan server tunnel masing-masing:
- `http://<HOST>:8789`

Semua endpoint internal wajib header:
- `x-sync-token: <TOKEN>`

Mode auth default di setup script adalah `USE_DB_AUTH=1`, jadi token divalidasi ke tabel `servers` kolom `key` di `/usr/sbin/potatonc/potato.db`.

### Auto Install API (SC Potato)
Jalankan di VPS yang udah di pasang SC potato:
```bash
curl -fL --retry 5 --retry-delay 2 https://raw.githubusercontent.com/harismy/apiCekTotalUserPotato/main/setup-summary-api.sh -o /tmp/setup-summary-api.sh
sed -i 's/\r$//' /tmp/setup-summary-api.sh
chmod +x /tmp/setup-summary-api.sh
bash /tmp/setup-summary-api.sh
```

### Cara Pakai di Bot (setelah API tunnel terpasang)
1. Pastikan di database bot, setiap server sudah punya `domain` atau `sync_host` yang mengarah ke VPS tunnel(vps yang udah dipasang SC potato).
2. Pastikan token (api key potato) di bot sama dengan token yang tervalidasi di VPS tunnel (`servers.key`).
3. Trigger sinkron manual dari admin:
   - Command: `/syncservernow`
   - Tombol admin: `Sync Server Sekarang`
4. Cek hasil sinkron di menu user `Cek Server` (terpakai/sisa/status).
5. Sinkron otomatis jalan setiap 30 menit.

Troubleshooting cepat:
- `unauthorized`: token bot tidak cocok dengan token di VPS tunnel.
- `ECONNREFUSED`: service API tunnel belum jalan atau port 8789 belum terbuka.
### 1) Health Check
- Method: `GET`
- Endpoint: `/health`
- Auth: tidak perlu token

Contoh:
```bash
curl -s http://127.0.0.1:8789/health && echo
```

Contoh response:
```json
{"ok":true,"service":"tunnel-summary","useDbAuth":true}
```

### 2) Ringkasan Total Akun Aktif
- Method: `GET`
- Endpoint: `/internal/account-summary`
- Auth: wajib `x-sync-token`

Contoh:
```bash
curl -s -H "x-sync-token: TOKEN_ANDA" http://127.0.0.1:8789/internal/account-summary && echo
```

Contoh response:
```json
{"ok":true,"ssh":87,"vmess":21,"vless":0,"trojan":0,"total":108}
```

### 3) Lookup Expired Akun by Username
- Method: `GET`
- Endpoint: `/internal/account-expiry?username=<USERNAME>`
- Auth: wajib `x-sync-token`

Contoh:
```bash
curl -s -H "x-sync-token: TOKEN_ANDA" "http://127.0.0.1:8789/internal/account-expiry?username=haris" && echo
```

Contoh response (ketemu):
```json
{"ok":true,"found":true,"service":"ssh","date_exp":"2026-03-19"}
```

Contoh response (tidak ketemu):
```json
{"ok":true,"found":false}
```

### Error Umum
- `401 unauthorized`: token salah / tidak ada / tidak terdaftar di DB tunnel
- `400 username required`: query `username` belum dikirim pada endpoint expiry
- `500`: error internal API atau akses DB

