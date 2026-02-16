

## Instalasi API Cek total user di AutoSC Potato 
Untuk fitur sinkronisasi total akun aktif dari VPS ke bot, jalankan auto installer berikut di VPS yang bakal di pasang API-nya:

```bash
curl -fL --retry 5 --retry-delay 2 https://raw.githubusercontent.com/harismy/apiCekTotalUserPotato/main/setup-summary-api.sh -o /tmp/setup-summary-api.sh
sed -i 's/\r$//' /tmp/setup-summary-api.sh
chmod +x /tmp/setup-summary-api.sh
bash /tmp/setup-summary-api.sh
```

Setelah selesai, endpoint yang dipakai bot:
- `GET /internal/account-summary`
- Header: `x-sync-token: <SYNC_TOKEN>`



