# infra/bootstrap

このモジュールは Terraform のリモートstate用 S3バケット・sops用KMSキー・GitHub Actions用の
OIDC IAMロールを作成する。**このモジュール自身は最初はローカルstateで実行する**（stateを置く
バケットをこのモジュール自身が作るため、circular dependencyを避けるための鶏卵問題対応）。

## 初回セットアップ手順

1. AWS認証情報を用意する（`aws configure` または環境変数）。管理者権限、もしくは
   S3/KMS/IAM/OIDCプロバイダを作成できる権限が必要。
2. 必要であれば `variables.tf` の `state_bucket_name` を globally-unique な名前に変更する
   （`-var` で上書きも可）。
3. ローカルstateで初期化・適用する。

   ```sh
   mise run tf:bootstrap:init
   mise run tf:bootstrap:apply
   ```

4. 適用後、以下の出力値を控える。

   ```sh
   terraform -chdir=infra/bootstrap output
   ```

   - `state_bucket_name` → `infra/prod/backend.hcl` に設定する
   - `kms_key_arn` → `secrets/.sops.yaml` に設定する
   - `github_actions_role_arn` → GitHub Actions の `permissions: id-token: write` を使う
     ワークフローで `aws-actions/configure-aws-credentials` の `role-to-assume` に設定する

5. （任意）このモジュール自身のstateもS3に寄せておくと、ローカルの
   `terraform.tfstate` を紛失するリスクを避けられる。

   ```sh
   cp backend.hcl.example backend.hcl
   # backend.hcl の bucket を手順4で控えた state_bucket_name に書き換える
   terraform -chdir=infra/bootstrap init -backend-config=backend.hcl -migrate-state
   ```

   `backend.hcl` は環境固有の設定なので `.gitignore` 済み（コミットしない）。

## 含まれるリソース

- `aws_s3_bucket` + versioning + SSE-KMS + public access block: Terraformリモートstate用
- `aws_kms_key` / `aws_kms_alias`: state暗号化とsops secretsの両方に使う共有キー
- `aws_iam_openid_connect_provider` + `aws_iam_role`: GitHub Actionsが長期AWSキーを持たずに
  ステートバケットとKMSキーだけへ限定アクセスできるようにするOIDCロール
  （trust policyは `repo:<owner>/<repo>:*` に限定）
