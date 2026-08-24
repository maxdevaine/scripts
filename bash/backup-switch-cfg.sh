#!/bin/bash
# author: Gemini AI + Max Devaine <maxdevaine@gmail.com>
# created: 2026/07
# license: GNU GPLv3

# description
# this script use rancid app and it backup/download network switch configuration via ssh protocol
# current version support hp and cisco SG/CBS
# gemini ai and manual modification were used


# Input parameters check
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <ip_list_file> <credentials_file> <type>"
    echo "Types: cisco | hp"
    echo "Example: $0 ips.txt creds.env cisco"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IP_FILE=${SCRIPT_DIR}/../config/$1
CRED_FILE=${SCRIPT_DIR}/../config/.env-$2

SWITCH_TYPE=$(echo "$3" | tr '[:upper:]' '[:lower:]')
BACKUP_DIR=/var/lib/tftpboot
SVN_DIR=/var/rancid/switch-backup/
DTIME=`date +"%Y-%m-%H"`

# update repository with backuped configs
cd $SVN_DIR
svn up


# File existence check
if [ ! -f "$IP_FILE" ]; then
    echo "Error: IP list file '$IP_FILE' does not exist."
    exit 1
fi

if [ ! -f "$CRED_FILE" ]; then
    echo "Error: Credentials file '$CRED_FILE' does not exist."
    exit 1
fi

# Safely load variables from credentials file
# Loads only KEY=VALUE lines and ignores the rest
eval "$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$CRED_FILE")"

# Mandatory variables check
if [ -z "$LOGIN" ] || [ -z "$PASSWORD" ]; then
    echo "Error: File '$CRED_FILE' must contain LOGIN and PASSWORD variables."
    echo "Example content:"
    echo '  LOGIN="admin"'
    echo '  PASSWORD="MySecretPassword123"'
    exit 1
fi


# Create temporary .cloginrc file
TMP_CLOGINRC=$(mktemp)
# RANCID requires strict 0600 file permissions
chmod 600 "$TMP_CLOGINRC"


case "$SWITCH_TYPE" in

  cisco)
cat << EOF > "$TMP_CLOGINRC"
add user * {$LOGIN}
add password * {$PASSWORD}
add method * {ssh}
add autoenable * {1}
EOF

echo "add cyphertype * aes128-ctr,aes128-cbc,3des-cbc" >> $TMP_CLOGINRC

LOGIN_CMD="csblogin"
BACKUP_CMD="show running-config"
CUT_PATTERN='show running-config'
  ;;

  hp)
cat << EOF > "$TMP_CLOGINRC"
add user * {$LOGIN}
add password * {$PASSWORD}
add method * {ssh}
add autoenable * {1}
EOF

echo "add cyphertype * aes128-ctr,aes128-cbc,3des-cbc" >> $TMP_CLOGINRC

LOGIN_CMD="hlogin"
BACKUP_CMD="show running-config"
CUT_PATTERN='show running-config'
  ;;


  *)
    echo "Error: Unsupported type '$SWITCH_TYPE'. Use 'cisco' or 'hp'."
    rm -f "$TMP_CLOGINRC"
    exit 1
    ;;
esac




echo "=== Starting Cisco Backup Proces ==="

# --- Backup loop for each IP ---
set -o pipefail
while IFS= read -r IP || [ -n "$IP" ]; do
    # Skip empty lines and comments (#)
    [[ -z "$IP" || "$IP" =~ ^# ]] && continue

    echo -n "Backing up $IP... "
    # run rancid (csblogin/hlogin)
    $LOGIN_CMD -f "$TMP_CLOGINRC" -c "$BACKUP_CMD" "$IP" 2>&1 | sed -n "/$CUT_PATTERN/,\$p" > "$BACKUP_DIR/${SWITCH_TYPE}-${IP}.txt"

    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ] && [ -s "$BACKUP_DIR/${SWITCH_TYPE}-${IP}.txt" ]; then
        echo "OK (Saved to $BACKUP_DIR/${SWITCH_TYPE}-${IP}.txt)"
    else
        echo "ERROR (Check connectivity or credentials)"
    fi
done < "$IP_FILE"

echo "=== Backup completed. Files saved in: $BACKUP_DIR ==="


echo "=== Processing svn ==="
cp /var/lib/tftpboot/hp-* $SVN_DIR
cp /var/lib/tftpboot/cisco-* $SVN_DIR

cd $SVN_DIR

svn add --force * --auto-props --parents --depth infinity -q
svn commit -m "$DTIME"


# --- Cleanup ---
rm -f "$TMP_CLOGINRC"
