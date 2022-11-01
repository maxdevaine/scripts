#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2019/06
# license: GNU GPLv3
# description: parse html web page to check current version of GFI Mail Archiver, notify via email in case of new version

CONTACT=`head -1 /home/version-check/scripts/_contact`
CURVER="15.3"
URL="https://www.gfi.com/products-and-solutions/network-security-solutions/archiver/resources/documentation/product-releases"
NEWVER=`wget -qO- --no-check-certificate ${URL} |grep Version | sed 's/<[^>]*>//g' | cut -c 13-| head -1 | tr -d '\r'`


if [ "$CURVER" != "$NEWVER" ]; then
  echo "It's new version of GFI MailArchiver: ${NEWVER}"
  echo -e "It's new version of GFI MailArchiver: ${CURVER}/${NEWVER} \n ${URL}" | mail -s "GFI MailArchiver new version: ${NEWVER}" ${CONTACT}

else
  echo "Version ${CURVER} is up to date."
fi
