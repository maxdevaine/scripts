#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/01
# license: GNU GPLv3

EMAIL="email1@domain.tld,email2@domain.tld"
MAILFROM="certcheck@domain.tld"
IMAPSERVER=127.0.0.1
SMTPSERVER=127.0.0.1
WEBSERVER=127.0.0.1

# check expiration date in (s)
# 7 days = 604800
# 14 days = 1209600
# 30day = 2592000
EXPDATE=1209600
EXPSTR="Certificate will not expire"


#### check if is all certificates same  ####

# check imap
CERT_IMAP=`echo Q | openssl s_client -crlf -connect ${IMAPSERVER}:993 2>/dev/null | openssl x509 -noout -dates |grep notAfter`

# check smtp
CERT_SMTP=`echo Q | openssl s_client -connect  ${SMTPSERVER}:587 -starttls smtp -crlf 2>/dev/null | openssl x509 -noout -dates |grep notAfter`

# check http
CERT_WEB=`echo Q | openssl s_client -showcerts -connect ${WEBSERVER}:443 2>/dev/null | openssl x509 -noout -dates |grep notAfter`

if [ "$CERT_IMAP" = "$CERT_SMTP" ] && [ "$CERT_SMTP" = "$CERT_WEB" ]; then
     echo "All certs are same, all is ok"
  else
     BODY="Certificates are not same\n\nIMAP: ${CERT_IMAP}\nSMTP: ${CERT_SMTP}\nWEB: ${CERT_WEB}"
     echo -e $BODY
     echo -e "${BODY}" | mail -r ${MAILFROM} -s '!!!'" Warning Cert not same"'!!!' ${EMAIL}
fi


####  Check expiration date  ####

EXP_CERT_IMAP=`echo Q | openssl s_client -crlf -connect  ${IMAPSERVER}:993 2>/dev/null | openssl x509 -noout -checkend ${EXPDATE}`
EXP_CERT_SMTP=`echo Q | openssl s_client -connect  ${SMTPSERVER}:587 -starttls smtp -crlf 2>/dev/null | openssl x509 -noout -checkend ${EXPDATE}`
EXP_CERT_WEB=`echo Q | openssl s_client -showcerts -connect  ${WEBSERVER}:443 2>/dev/null | openssl x509 -noout -checkend ${EXPDATE}`


if [ "$EXP_CERT_IMAP" = "$EXPSTR" ] && [ "$EXP_CERT_SMTP" = "$EXPSTR" ] && [ "$EXP_CERT_WEB" = "$EXPSTR" ]; then
      echo "Expiration of all certificates is ok."
   else
     BODY="Certificate will expire\n\nIMAP: ${EXP_CERT_IMAP}\nSMTP: ${EXP_CERT_SMTP}\nWEB: ${EXP_CERT_WEB}"
     echo -e $BODY
     echo -e "${BODY}" | mail -r ${MAILFROM} -s '!!!'" Warning cert expire "'!!!' ${EMAIL}
fi
