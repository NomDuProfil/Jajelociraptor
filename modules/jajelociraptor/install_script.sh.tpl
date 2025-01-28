#!/bin/bash
# -----------------------------------------------------------------------------
# Script Name: install_script.sh
# Project: Jajelociraptor
# Author: NomDuProfil
# GitHub: https://github.com/NomDuProfil/Jajelociraptor
# -----------------------------------------------------------------------------

# +==================================+
# | Update and packages installation |
# +==================================+

apt update
apt upgrade -y
apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# +==================================+
# |    Initialization variables      |
# +==================================+

ADMIN_EMAIL=${admin_email}
S3_NAME=${s3_name}
ADMIN_USERNAME=${admin_username}
AWS_REGION=${aws_region}

CONFIG_SERVER_FILE="template.config.yaml"
CONFIG_SERVER_FILE_DEST="server.config.yaml"
CONFIG_CLIENT="client.config.yaml"
SERVER_IP=$(curl -sS http://checkip.amazonaws.com)
read PASSWORD SALT PASSWORD_HASH < <(python3 -c "import os, hashlib, random; password=''.join(random.choice('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') for _ in range(20)); salt=os.urandom(32).hex(); hash=hashlib.sha256(bytes.fromhex(salt) + password.encode()).hexdigest(); print(password, salt, hash)")

# +==================================+
# |    Download Velociraptor         |
# +==================================+

mkdir velociraptor

cd velociraptor

echo "Download Linux package 64 bits"

curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep "velociraptor-.*-linux-amd64.$" | cut -d : -f 2,3 | tr -d \" | wget -O velociraptor --show-progress -qi -

echo "Download Windows MSI 64 bits"

curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep "velociraptor-.*-windows-amd64.msi.$" | cut -d : -f 2,3 | tr -d \" | wget -O velociraptor_win_64.msi --show-progress -qi -

echo "Download Windows MSI 32 bits"

curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep "velociraptor-.*-windows-386.msi.$" | cut -d : -f 2,3 | tr -d \" | wget -O velociraptor_win_32.msi --show-progress -qi -

# +============================================+
# | Server Configuration and binary generation |
# +============================================+

echo "Server configuration"

chmod +x velociraptor

./velociraptor config generate >> $CONFIG_SERVER_FILE

./velociraptor --config "$CONFIG_SERVER_FILE" config show --merge '{"Client":{"server_urls":["https://'"$SERVER_IP"':8000/"]},"GUI":{"bind_address":"0.0.0.0","initial_users":[{"name": "'"$ADMIN_USERNAME"'", "password_hash": "'"$PASSWORD_HASH"'", "password_salt": "'"$SALT"'"}]}}' >> $CONFIG_SERVER_FILE_DEST

echo "Server binary generation"

./velociraptor --config $CONFIG_SERVER_FILE_DEST debian server --binary velociraptor

# +============================================+
# | Client Configuration and binary generation |
# +============================================+

echo "Client generation"

./velociraptor --config $CONFIG_SERVER_FILE_DEST config client >> $CONFIG_CLIENT

echo "Windows 64 bits"

./velociraptor config repack --msi velociraptor_win_64.msi $CONFIG_CLIENT client_win_64.msi

echo "Windows 32 bits"

./velociraptor config repack --msi velociraptor_win_32.msi $CONFIG_CLIENT client_win_32.msi

# +============================================+
# |      Server service installation           |
# +============================================+

dpkg -i velociraptor_*.deb

service velociraptor_server restart

# +============================================+
# |      Copy client file to S3                |
# +============================================+

zip velociraptor.zip client_win_* velociraptor client.config.yaml

aws s3 cp velociraptor.zip s3://$S3_NAME

PRESIGNED_URL=$(aws s3 presign s3://$S3_NAME/velociraptor.zip --expires-in 3600 --region $AWS_REGION)

# +============================================+
# |          Sending information               |
# +============================================+

while true; do
    VALIDATION_STATUS=$(aws ses get-identity-verification-attributes --region $AWS_REGION --identities $ADMIN_EMAIL --output text | awk '{print $2}')
    echo $VALIDATION_STATUS
    if [ "$VALIDATION_STATUS" == "Success" ]; then
        echo "Email has been verified."
        break
    else
        echo "Waiting for email verification..."
        sleep 10
    fi
done

FROM_EMAIL="$ADMIN_EMAIL"
TO_EMAIL="$ADMIN_EMAIL"
SUBJECT="Jajelociraptor - Access Information"
BODY=$(cat <<EOF
<html>
  <body>
    <p>Hi,</p>
    <p>Here is all your information for your Velociraptor server:</p>
    <ul>
      <li><strong>Admin URL:</strong> https://$SERVER_IP:8889</li>
      <li><strong>Admin Username:</strong> $ADMIN_USERNAME</li>
      <li><strong>Admin Password:</strong> $PASSWORD</li>
      <li><strong>Client files:</strong> $PRESIGNED_URL</li>
    </ul>
    <p>Thanks,</p>
  </body>
</html>
EOF
)

aws ses send-email --from "$FROM_EMAIL" --destination "ToAddresses=$TO_EMAIL" --message "Subject={Data='$SUBJECT',Charset=utf-8},Body={Html={Data='$BODY',Charset=utf-8}}" --region "$AWS_REGION"
