#!/bin/bash

SCRIPT=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$( cd "$( dirname "${SCRIPT}" )" >/dev/null 2>&1 && pwd )

VERSION=$(git describe --tags HEAD | tr -d v)
TAR_FILE=$("${SCRIPT_DIR}/../tar/buildTar.sh")
RPM_FILE=$("${SCRIPT_DIR}/../rpm/buildRpm.sh")
DEBDATE=$(date -R)
# shellcheck disable=SC2012
SIZE=$(ls -la "${TAR_FILE}" | awk '{print $5}')
MD5=$(openssl md5 "${TAR_FILE}" | awk '{print $2}')

cd "${SCRIPT_DIR}" || exit 1
for TFILE in chaossquirrel.dsc debian.changelog; do
    # shellcheck disable=SC2002
    cat "${TFILE}.in" \
        | sed "s/@VERSION@/$VERSION/g" \
        | sed "s/@DEBDATE@/$DEBDATE/g" \
        | sed "s/@MD5@/$MD5/g" \
        | sed "s/@SIZE@/$SIZE/g" \
        > "${TFILE}"
done

DEB_FILE=$(sudo alien -d --scripts "${RPM_FILE}" | grep -F generated | awk '{print $1}')
sudo chown -R "$(id -un):$(id -gn)" "${SCRIPT_DIR}/${DEB_FILE}"
ls "${SCRIPT_DIR}/${DEB_FILE}"
