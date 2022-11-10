#!/bin/sh

COUNT=1
echo "BEGIN CURL"
while [ $COUNT -le 120 ]; do
    COUNT=$(( $COUNT+1 ))
    curl "khoanlm2.local"; sleep 1
    echo
done
echo "END CURL"