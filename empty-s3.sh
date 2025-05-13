#!/bin/bash

# Usage: ./empty-s3-bucket.sh your-bucket-name
BUCKET="$1"

if [ -z "$BUCKET" ]; then
  echo "❌ Bucket name not provided. Usage: $0 your-bucket-name"
  exit 1
fi

echo "🚧 Deleting all objects (non-versioned)..."
aws s3 rm "s3://$BUCKET" --recursive

echo "🔍 Listing all object versions..."
aws s3api list-object-versions --bucket "$BUCKET" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output json > versions.json

echo "🗑️ Deleting object versions..."
if [ -s versions.json ]; then
  aws s3api delete-objects --bucket "$BUCKET" --delete file://versions.json
else
  echo "✅ No object versions found."
fi

echo "🔍 Listing all delete markers..."
aws s3api list-object-versions --bucket "$BUCKET" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output json > delete-markers.json

echo "🗑️ Deleting delete markers..."
if [ -s delete-markers.json ]; then
  aws s3api delete-objects --bucket "$BUCKET" --delete file://delete-markers.json
else
  echo "✅ No delete markers found."
fi

echo "✅ S3 bucket '$BUCKET' emptied successfully."

