#!/usr/bin/env bash
# Terraform リモートステート用 S3 バケットを作成するブートストラップスクリプト
# 使い方: ./scripts/bootstrap-tfstate.sh
# 前提: AWS CLI がセットアップ済みで、必要な権限があること

set -euo pipefail

BUCKET_NAME="ozawakosuke-aboutme-tfstate"
REGION="ap-northeast-1"

echo "==> S3 バケット作成: ${BUCKET_NAME}"
aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}" \
  --create-bucket-configuration LocationConstraint="${REGION}"

echo "==> バージョニング有効化"
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo "==> サーバーサイド暗号化有効化"
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

echo "==> パブリックアクセスブロック設定"
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "==> 完了"
echo "S3 バケット  : ${BUCKET_NAME}"
echo "リージョン   : ${REGION}"
