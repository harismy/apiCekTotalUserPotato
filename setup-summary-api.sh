#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/root/tunnel-sync}"
APP_NAME="${APP_NAME:-tunnel-summary}"
PORT="${SUMMARY_PORT:-8789}"
DB_PATH="${POTATO_DB:-/usr/sbin/potatonc/potato.db}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root (or sudo)."
  exit 1
fi

log() { echo "[setup-summary-api] $*"; }

install_node_if_missing() {
  if command -v node >/dev/null 2>&1; then
    log "Node.js already installed: $(node -v)"
    return
  fi

  log "Installing Node.js 20.x..."
  apt-get update -y
  apt-get install -y curl ca-certificates gnupg
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
  log "Node.js installed: $(node -v)"
}

install_pm2_if_missing() {
  if command -v pm2 >/dev/null 2>&1; then
    log "PM2 already installed: $(pm2 -v)"
    return
  fi

  log "Installing PM2..."
  npm install -g pm2
  log "PM2 installed: $(pm2 -v)"
}

ask_sync_token() {
  if [[ -n "${SYNC_TOKEN:-}" ]]; then
    return
  fi

  read -r -s -p "Input SYNC_TOKEN for API auth: " SYNC_TOKEN
  echo
  if [[ -z "${SYNC_TOKEN}" ]]; then
    echo "SYNC_TOKEN cannot be empty."
    exit 1
  fi
}

write_files() {
  mkdir -p "${APP_DIR}"

  cat > "${APP_DIR}/summary-api.js" <<'JS'
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
require('dotenv').config();

const app = express();
const PORT = Number(process.env.SUMMARY_PORT || 8789);
const TOKEN = process.env.SYNC_TOKEN || '';
const DB = process.env.POTATO_DB || '/usr/sbin/potatonc/potato.db';

if (!TOKEN) {
  console.error('SYNC_TOKEN is empty. Fill .env first.');
  process.exit(1);
}

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'tunnel-summary' });
});

app.get('/internal/account-summary', (req, res) => {
  if (req.headers['x-sync-token'] !== TOKEN) {
    return res.status(401).json({ ok: false, message: 'unauthorized' });
  }

  const db = new sqlite3.Database(DB);
  db.get(`
    SELECT
      (SELECT COUNT(*) FROM account_sshs    WHERE UPPER(TRIM(status))='AKTIF') AS ssh,
      (SELECT COUNT(*) FROM account_vmesses WHERE UPPER(TRIM(status))='AKTIF') AS vmess,
      (SELECT COUNT(*) FROM account_vlesses WHERE UPPER(TRIM(status))='AKTIF') AS vless,
      (SELECT COUNT(*) FROM account_trojans WHERE UPPER(TRIM(status))='AKTIF') AS trojan
  `, (err, row) => {
    db.close();
    if (err) {
      return res.status(500).json({ ok: false, message: err.message });
    }

    const ssh = Number(row?.ssh || 0);
    const vmess = Number(row?.vmess || 0);
    const vless = Number(row?.vless || 0);
    const trojan = Number(row?.trojan || 0);

    return res.json({
      ok: true,
      ssh,
      vmess,
      vless,
      trojan,
      total: ssh + vmess + vless + trojan
    });
  });
});

app.listen(PORT, () => {
  console.log(`summary api on port ${PORT}`);
});
JS

  cat > "${APP_DIR}/.env" <<EOF
SUMMARY_PORT=${PORT}
SYNC_TOKEN=${SYNC_TOKEN}
POTATO_DB=${DB_PATH}
EOF

  chmod 600 "${APP_DIR}/.env"
}

install_dependencies() {
  cd "${APP_DIR}"
  if [[ ! -f package.json ]]; then
    npm init -y >/dev/null 2>&1
  fi
  npm install express sqlite3 dotenv --omit=dev
}

start_pm2_service() {
  cd "${APP_DIR}"
  pm2 delete "${APP_NAME}" >/dev/null 2>&1 || true
  pm2 start "${APP_DIR}/summary-api.js" --name "${APP_NAME}"
  pm2 save --force

  pm2 startup systemd -u root --hp /root >/tmp/pm2-startup.out 2>&1 || true
  if grep -q "sudo" /tmp/pm2-startup.out; then
    bash -lc "$(grep -Eo 'sudo .+' /tmp/pm2-startup.out | head -n1 | sed 's/^sudo //')" || true
  fi

  systemctl enable pm2-root >/dev/null 2>&1 || true
  systemctl restart pm2-root >/dev/null 2>&1 || true
}

print_result() {
  log "Done."
  echo
  echo "Service Name : ${APP_NAME}"
  echo "Service Path : ${APP_DIR}/summary-api.js"
  echo "Port         : ${PORT}"
  echo "DB Path      : ${DB_PATH}"
  echo
  echo "Health check:"
  echo "  curl -s http://127.0.0.1:${PORT}/health && echo"
  echo
  echo "Summary check:"
  echo "  curl -s -H \"x-sync-token: ${SYNC_TOKEN}\" http://127.0.0.1:${PORT}/internal/account-summary && echo"
}

install_node_if_missing
install_pm2_if_missing
ask_sync_token
write_files
install_dependencies
start_pm2_service
print_result
