#!/bin/sh


DEST="dump/$NAME"
ARCHIVE="$DEST".tar.gz
echo "creating backup for $URI"
mkdir -p dump
mongodump --forceTableScan --uri "$URI" -o "$DEST" || exit 1
echo "finished creating dump"
tar -czvf "$ARCHIVE" "$DEST"
echo "created archive"
echo "pushing to s3"
aws --version
aws s3 cp "$ARCHIVE" s3://"$S3_DESTINATION" || exit 1
rm -rf dump
echo "deleted dump at $DEST"
