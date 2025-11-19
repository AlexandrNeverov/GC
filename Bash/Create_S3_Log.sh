#!/usr/bin/bash

set -Eeuo pipefail

LOG_BUCKET="logs-$(date +%s)"
REGION="us-east-1"

# 1. Create bucket
aws s3api create-bucket \
    --bucket "$LOG_BUCKET" \
    --region "$REGION" \
    $( [[ "$REGION" != "us-east-1" ]] && echo "--create-bucket-configuration LocationConstraint=$REGION" )

# 2. Block public access
aws s3api put-public-access-block \
    --bucket "$LOG_BUCKET" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 3. Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$LOG_BUCKET" \
    --versioning-configuration Status=Enabled

# 4. Enable encruption
aws s3api put-bucket-encryption \
    --bucket "$LOG_BUCKET" \
    --server-side-encryption-configuration '{
        "Rules": [
         {
          "ApplyServerSideEncryptionByDefault" : {
           "SSEAlgorithm": "AES256"
           }
         }
     ]
    }'

# 5. Add recomended ACL for log delivery

#aws s3api put-bucket-acl \
 #   --bucket "$LOG_BUCKET" \
  #  --grant-write 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"' \
   # --grant-read-acp 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"'
#
echo "Created secure S3 log bucket: $LOG_BUCKET"