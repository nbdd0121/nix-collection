#!@bash@/bin/bash

# This script is called with "load-key.sh <dataset>" and needs to be called as root.

FS="$1"

encrypted()
{
    [ "$(@zfs@/sbin/zfs get -H -o value keystatus "$FS")" = "unavailable" ]
}

# Early termination if the filesystem doesn't require encryption
if ! encrypted; then
    echo "$FS does not require decryption"
    exit 0
fi

# Get the encrypted key, decrypt with TPM and load to ZFS
@zfs@/sbin/zfs get -H -o value tpm-unlock:key "$FS" | @systemd@/bin/systemd-creds decrypt --name key - | @zfs@/sbin/zfs load-key "$FS"

if ! encrypted; then
    echo "Unseal key for $FS from TPM"
    exit 0
fi

# We give user 3 attempts
for COUNT in 1 2 3; do
    PASS=$(@systemd@/bin/systemd-ask-password "TPM unlock failed. Enter passphrase for '$FS': ")
    echo
    echo "$PASS" | zfs load-key "$FS" && break
    sleep 1
done

if encrypted; then
    echo "Cannot decrypt filesystem, too many attempts"
    exit 1
fi

@zfs@/sbin/zfs set "tpm-unlock:key=$(echo "$PASS" | @systemd@/bin/systemd-creds encrypt --name key - - -T --tpm2-pcrs=@pcr@)" "$FS"
