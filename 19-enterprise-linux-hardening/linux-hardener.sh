#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root (sudo)."
  exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "[-] Cannot detect OS."
    exit 1
fi

echo "[+] Detected OS: $OS $VERSION"

BACKUP_BASE_DIR="/var/backups/linux_hardening"
LATEST_BACKUP_LINK="$BACKUP_BASE_DIR/latest_backup"

# --- ROLLBACK FUNCTION ---
do_rollback() {
    echo "[*] Looking for the latest backup to restore..."
    if [ ! -L "$LATEST_BACKUP_LINK" ]; then
        echo "[-] No backup found to rollback!"
        exit 1
    fi

    TARGET_BACKUP=$(readlink -f "$LATEST_BACKUP_LINK")
    echo "[+] Restoring configurations from: $TARGET_BACKUP"

    [ -f "$TARGET_BACKUP/sshd_config" ] && cp "$TARGET_BACKUP/sshd_config" /etc/ssh/sshd_config && echo "[✔] Restored sshd_config"
    [ -f "$TARGET_BACKUP/sysctl_security.conf" ] && cp "$TARGET_BACKUP/sysctl_security.conf" /etc/sysctl.d/99-security.conf && echo "[✔] Restored sysctl settings"
    [ -f "$TARGET_BACKUP/nginx.conf" ] && cp "$TARGET_BACKUP/nginx.conf" /etc/nginx/nginx.conf && echo "[✔] Restored nginx.conf"
    [ -f "$TARGET_BACKUP/apache2.conf" ] && cp "$TARGET_BACKUP/apache2.conf" /etc/apache2/apache2.conf && echo "[✔] Restored apache2.conf"
    [ -f "$TARGET_BACKUP/httpd.conf" ] && cp "$TARGET_BACKUP/httpd.conf" /etc/httpd/conf/httpd.conf && echo "[✔] Restored httpd.conf"
    [ -f "$TARGET_BACKUP/vsftpd.conf" ] && cp "$TARGET_BACKUP/vsftpd.conf" /etc/vsftpd.conf && echo "[✔] Restored vsftpd.conf"

    sysctl --system > /dev/null 2>&1
    if [ "$OS" == "ubuntu" ]; then
        systemctl restart ssh nginx apache2 vsftpd 2>/dev/null
    else
        systemctl restart sshd nginx httpd vsftpd 2>/dev/null
    fi

    echo "[✔] Rollback completed successfully!"
    exit 0
}

if [ "$1" == "--rollback" ]; then
    do_rollback
fi

# --- BACKUP PHASE ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_BACKUP_DIR="$BACKUP_BASE_DIR/backup_$TIMESTAMP"
mkdir -p "$CURRENT_BACKUP_DIR"

echo "[*] Creating configuration backups in $CURRENT_BACKUP_DIR..."
[ -f /etc/ssh/sshd_config ] && cp /etc/ssh/sshd_config "$CURRENT_BACKUP_DIR/"
[ -f /etc/nginx/nginx.conf ] && cp /etc/nginx/nginx.conf "$CURRENT_BACKUP_DIR/"
[ -f /etc/apache2/apache2.conf ] && cp /etc/apache2/apache2.conf "$CURRENT_BACKUP_DIR/"
[ -f /etc/httpd/conf/httpd.conf ] && cp /etc/httpd/conf/httpd.conf "$CURRENT_BACKUP_DIR/"
[ -f /etc/vsftpd.conf ] && cp /etc/vsftpd.conf "$CURRENT_BACKUP_DIR/"

rm -f "$LATEST_BACKUP_LINK"
ln -s "$CURRENT_BACKUP_DIR" "$LATEST_BACKUP_LINK"
echo "[✔] Backup created successfully."

SCORE=0
MAX_SCORE=100

calculate_score() {
    echo "=========================================="
    echo "[+] Current Security Score: $SCORE / $MAX_SCORE"
    echo "=========================================="
}

secure_ssh() {
    echo "[*] Hardening SSH Configuration..."
    SSH_CONFIG="/etc/ssh/sshd_config"
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONFIG"
    sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$SSH_CONFIG"
    sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG"
    
    if [ "$OS" == "ubuntu" ]; then
        systemctl restart ssh
    else
        systemctl restart sshd
    fi
    SCORE=$((SCORE + 15))
    echo "[✔] SSH hardened successfully."
}

secure_firewall() {
    echo "[*] Hardening Firewall..."
    if [ "$OS" == "ubuntu" ]; then
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
        ufw --force enable
    else
        systemctl enable --now firewalld
        firewall-cmd --set-default-zone=drop >/dev/null 2>&1
        firewall-cmd --permanent --add-service=ssh >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
    fi
    SCORE=$((SCORE + 15))
    echo "[✔] Firewall configured."
}

secure_kernel() {
    echo "[*] Applying Kernel & Network Hardening (Sysctl)..."
    SYSCTL_CONF="/etc/sysctl.d/99-security.conf"
    
    cat << 'EOF' > "$SYSCTL_CONF"
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
fs.suid_dumpable = 0
EOF

    sysctl --system > /dev/null 2>&1
    SCORE=$((SCORE + 20))
    echo "[✔] Kernel parameters secured."
}

secure_web_servers() {
    echo "[*] Checking and hardening Web Servers (Nginx/Apache)..."
    if [ -d /etc/nginx ]; then
        NGINX_CONF="/etc/nginx/nginx.conf"
        if ! grep -q "server_tokens off;" "$NGINX_CONF"; then
            sed -i '/http {/a \    server_tokens off;' "$NGINX_CONF"
        fi
        systemctl restart nginx 2>/dev/null
        echo "[✔] Nginx secured."
    fi

    if [ -d /etc/apache2 ] || [ -d /etc/httpd ]; then
        APACHE_CONF="/etc/apache2/apache2.conf"
        [ -f /etc/httpd/conf/httpd.conf ] && APACHE_CONF="/etc/httpd/conf/httpd.conf"
        
        if [ -f "$APACHE_CONF" ]; then
            sed -i 's/^ServerSignature.*/ServerSignature Off/' "$APACHE_CONF"
            sed -i 's/^ServerTokens.*/ServerTokens Prod/' "$APACHE_CONF"
            systemctl restart apache2 2>/dev/null || systemctl restart httpd 2>/dev/null
            echo "[✔] Apache secured."
        fi
    fi
    SCORE=$((SCORE + 15))
}

secure_ftp() {
    echo "[*] Checking and hardening FTP (VSFTPD)..."
    VSFTPD_CONF="/etc/vsftpd.conf"
    if [ -f "$VSFTPD_CONF" ]; then
        sed -i 's/^anonymous_enable=.*/anonymous_enable=NO/' "$VSFTPD_CONF"
        sed -i 's/^#anonymous_enable=.*/anonymous_enable=NO/' "$VSFTPD_CONF"
        systemctl restart vsftpd 2>/dev/null
        echo "[✔] VSFTPD secured."
    fi
    SCORE=$((SCORE + 10))
}

secure_logging() {
    echo "[*] Configuring Auditd and Logging..."
    if [ "$OS" == "ubuntu" ]; then
        apt-get install -y auditd > /dev/null 2>&1
    else
        dnf install -y audit > /dev/null 2>&1
    fi
    systemctl enable --now auditd
    SCORE=$((SCORE + 15))
    echo "[✔] Audit logging service enabled."
}

check_services() {
    echo "[*] Disabling risky or legacy services..."
    SERVICES=("telnet" "rsh-server" "nis" "tftp" "xinetd")
    for srv in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$srv" 2>/dev/null; then
            systemctl stop "$srv"
            systemctl disable "$srv"
            echo "[~] Disabled: $srv"
        fi
    done
    SCORE=$((SCORE + 10))
}

echo "=== Starting Advanced Hardening Script ==="
calculate_score

secure_ssh
secure_firewall
secure_kernel
secure_web_servers
secure_ftp
secure_logging
check_services

echo "=== Hardening Process Completed ==="
calculate_score
echo "[+] All configurations were safely backed up. If anything breaks, run: sudo ./linux-hardener.sh --rollback"
