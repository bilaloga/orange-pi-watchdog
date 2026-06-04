{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
# Ensure the script is run as root\
if [ "$EUID" -ne 0 ]; then\
  echo "Please run this script as root (use sudo)."\
  exit 1\
fi\
\
SCRIPT_PATH="/usr/local/bin/check_internet.sh"\
\
echo "1. Creating the internet check script at $SCRIPT_PATH..."\
\
# Write the checking logic directly to the target file\
cat << 'EOF' > $SCRIPT_PATH\
#!/bin/bash\
\
# Target IP to ping (Cloudflare DNS)\
TARGET="1.1.1.1"\
\
# Check 1: Send 3 packets, wait up to 2 seconds per packet\
if ! ping -c 3 -W 2 $TARGET > /dev/null 2>&1; then\
    # First check failed. Wait 30 seconds for a second chance.\
    sleep 30\
    \
    # Check 2: Try one more time.\
    if ! ping -c 3 -W 2 $TARGET > /dev/null 2>&1; then\
        # Both checks failed. Internet is down. Reboot.\
        /sbin/reboot\
    fi\
fi\
EOF\
\
echo "2. Setting executable permissions..."\
chmod +x $SCRIPT_PATH\
\
echo "3. Adding the job to crontab (running every 10 minutes)..."\
# This safely appends the cron job to the root crontab without duplicates\
(crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "*/10 * * * * $SCRIPT_PATH") | crontab -\
\
echo "--------------------------------------------------"\
echo "Setup complete! Your Orange Pi will now check the"\
echo "internet every 10 minutes and reboot if disconnected."\
echo "--------------------------------------------------"}