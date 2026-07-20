# infra/bootstrap

このモジュールは sops用KMSキーとGitHub Actions用のOIDC IAMロールを作成する。
Terraform stateには既存のS3バケット `k3ozawa-tf-backend` を使用し、バケット自体は管理しない。

## 初回セットアップ手順

1. AWS認証情報を用意する（`aws configure` または環境変数）。KMS/IAM/OIDCプロバイダを
   作成でき、`k3ozawa-tf-backend` をTerraform backendとして利用できる権限が必要。
2. backend設定を用意し、初期化・適用する。

   ```sh
   cp infra/bootstrap/backend.hcl.example infra/bootstrap/backend.hcl
   mise run tf:bootstrap:init
   mise run tf:bootstrap:apply
   ```

3. 適用後、以下の出力値を控える。

   ```sh
   terraform -chdir=infra/bootstrap output
   ```

   - `kms_key_arn` → `secrets/.sops.yaml` に設定する
   - `github_actions_role_arn` → GitHub Actions の `permissions: id-token: write` を使う
     ワークフローで `aws-actions/configure-aws-credentials` の `role-to-assume` に設定する

`backend.hcl` は環境固有の設定なので `.gitignore` 済み（コミットしない）。

## 含まれるリソース

- `aws_kms_key` / `aws_kms_alias`: sops secretsの暗号化に使うキー
- `aws_iam_openid_connect_provider` + `aws_iam_role`: GitHub Actionsが長期AWSキーを持たずに
  既存のステートバケットとKMSキーだけへ限定アクセスできるようにするOIDCロール
  （trust policyは `repo:<owner>/<repo>:*` に限定）
