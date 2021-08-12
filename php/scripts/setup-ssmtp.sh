#!/bin/bash
#
# You can set up sSMTP by setting the following ENV variables:
#
# SSMTP_TO - This is the address alarms will be delivered to.
# SSMTP_SERVER - This is your SMTP server. Defaults to smtp.gmail.com.
# SSMTP_PORT - This is the SMTP server port. Defaults to 587.
# SSMTP_USER - This is your username for the SMTP server.
# SSMTP_PASS - This is your password for the SMTP server. Use an app password if using Gmail.
# SSMTP_TLS - Use TLS for the connection. Defaults to YES.
# SSMTP_HOSTNAME - The hostname mail will come from. Defaults to localhost.
#
# ... and an addition of SSMTP_FROM, which generates the aliases in
# the mail-out system, replacing USERNAME with the system username
# who is sending mail (root, www-data, whatever,...) and HOSTNAME
# to the effective `/etc/hostname` (env $HOSTNAME) value. More info
# about this is written up below.
#
# TODO: supposedly, ssmtp is not developed anymore. Somebody
# recommended `msmtp` as an alternative; ¯\_(ツ)_/¯
#

if [[ $SSMTP_TO ]] && [[ $SSMTP_USER ]] && [[ $SSMTP_PASS ]]; then

# set reasonable defaults

SSMTP_TLS=${SSMTP_TLS:-YES}
SSMTP_SERVER=${SSMTP_SERVER:-smtp.gmail.com}
SSMTP_PORT=${SSMTP_PORT:-587}
SSMTP_HOSTNAME=${SSMTP_HOSTNAME:-localhost}
SSMTP_FROM=${SSMTP_FROM:-USERNAME@HOSTNAME}

# root=$SSMTP_TO
cat << EOF > /etc/ssmtp/ssmtp.conf
mailhub=$SSMTP_SERVER:$SSMTP_PORT
AuthUser=$SSMTP_USER
AuthPass=$SSMTP_PASS
UseSTARTTLS=$SSMTP_TLS
hostname=$SSMTP_HOSTNAME
FromLineOverride=YES
EOF

# Here's the catch of the day: we don't know which local users might
# receive mail, and we need to forward them to something that might
# pass firewall rules for example (valid email address) without
# losing this information along the way.

USERS=$(cut -d: -f1 /etc/passwd)

CONFIG="# sSMTP aliases
#
# Format:       local_account:outgoing_address:mailhub
#
# Example: root:your_login@your.domain:mailhub.your.domain[:port]
# where [:port] is an optional port number that defaults to 25.
#"

# obviously SSMTP_FROM can be USERNAME@HOSTNAME => root@[hostname]
# but it can also be a valid GMAIL from address => acc@gmail.com,
# or a valid gmail acc+alias => acc+USERNAME+HOSTNAME@gmail.com and
# it *will* get delivered to acc@gmail.com keeping user/host info

for USERNAME in $USERS; do
        ALIAS=${SSMTP_FROM}
        ALIAS=${ALIAS/HOSTNAME/$HOSTNAME}
        ALIAS=${ALIAS/USERNAME/$USERNAME}
        ALIAS="$USERNAME:$ALIAS:$SSMTP_SERVER:$SSMTP_PORT"
        CONFIG="$CONFIG\n$ALIAS"
done

echo -e "$CONFIG" > /etc/ssmtp/revaliases

fi
