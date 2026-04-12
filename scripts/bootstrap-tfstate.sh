#!/usr/bin/env bash
# Terraform リモートステート用 S3 バケットと DynamoDB テーブルを作成するブートストラップスクリプト
# 使い方: ./scripts/bootstrap-tfstate.sh
# 前提: AWS CLI がセットアップ済みで、必要な権限があること

set -euo pipefail

BUCKET_NAME="ozawakosuke-aboutme-tfstate"
DYNAMODB_TABLE="ozawakosuke-aboutme-tfstate-lock"
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

echo "==> DynamoDB テーブル作成: ${DYNAMODB_TABLE}"
aws dynamodb create-table \
  --table-name "${DYNAMODB_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}"

echo "==> 完了"
echo "S3 バケット  : ${BUCKET_NAME}"
echo "DynamoDB    : ${DYNAMODB_TABLE}"
echo "リージョン   : ${REGION}"
