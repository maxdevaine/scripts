#/bin/sh
# author: Max Devaine <maxdevaine@gmail.com>
# license: GPLv3
# Description:
# Script copy all tasks + calendars + contacts to share for migration (migration utility is windows only and not working via share)

DOMAIN=domain.tld
SOURCE=/opt/kerio/mailserver/store/mail/${DOMAIN}
DESTINATION=/mnt/kerio-migration/${DOMAIN}

cd "$SOURCE"
for D in *; do
    if [ -d "${D}" ]; then

        mkdir -p "$DESTINATION/${D}/Calendar"
        cp -Rv $SOURCE/"${D}/Calendar" "$DESTINATION/${D}"

        mkdir -p "$DESTINATION/${D}/Contacts"
        cp -Rv $SOURCE/"${D}/Contacts" "$DESTINATION/${D}"

        mkdir -p "$DESTINATION/${D}/Tasks"
        cp -Rv $SOURCE/"${D}/Tasks" "$DESTINATION/${D}"


    fi
done
