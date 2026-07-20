# aboutme

個人プロフィールサイト。Vercel上でコンテナ（`Dockerfile.vercel`）としてホストする。

## アーキテクチャ

- **フロントエンド**: React + TypeScript + Vite ([web/](web/))。ビルド成果物は静的ファイル。
- **配信**: Nginx (`nginxinc/nginx-unprivileged`, 非root) が静的ファイルを配信。
  セキュリティヘッダ（CSP / X-Frame-Options / HSTS 等）を付与する
  ([docker/nginx.conf.template](docker/nginx.conf.template))。
- **コンテナ化**: リポジトリルートの [Dockerfile.vercel](Dockerfile.vercel) をVercelが検出し、
  ビルド・保存・自動スケールする Vercel Function としてデプロイする
  （Vercel Hobbyプランで稼働、`$PORT` でHTTPを待ち受ける）。
- **IaC**: Terraform。
  - [infra/bootstrap](infra/bootstrap): Terraform stateを置くS3バケット・sops用KMSキー・
    GitHub Actions用OIDC IAMロールを作成する（ローカルstate、初回のみ手動apply）。
  - [infra/prod](infra/prod): S3 remote backend。Vercelプロジェクト・カスタムドメイン・
    環境変数を管理する（[infra/modules/vercel-container-site](infra/modules/vercel-container-site)
    モジュール経由）。
- **秘匿情報**: [sops](https://github.com/getsops/sops) + AWS KMS で暗号化し、
  `secrets/*.enc.yaml` としてのみコミットする（詳細は [secrets/README.md](secrets/README.md)）。
- **バージョン管理**: ツールのバージョンは [mise](https://mise.jdx.dev/) (`.mise.toml`) で固定する。

## ローカル開発

```sh
mise install          # node/terraform/sops/trivy を .mise.toml のバージョンで導入
mise run web:install   # フロントエンドの依存関係インストール
mise run dev           # 開発サーバー起動 (http://localhost:5173)
```

プロフィール内容は [web/src/data/profile.ts](web/src/data/profile.ts) にモックが入っている。
実際の名前・経歴・スキル・SNSリンクに差し替えて使う。

## mise tasks

日常的に使うコマンドは `mise run <task>` に定型化してある。

| タスク | 内容 |
| --- | --- |
| `dev` | フロントエンド開発サーバーを起動 |
| `web:install` | フロントエンドの依存関係をインストール |
| `web:lint` / `web:test` / `web:build` | Lint / unit test (Vitest) / 本番ビルド |
| `web:check` | 上記3つをまとめて実行 |
| `tf:fmt` | Terraformフォーマットチェック |
| `tf:validate` | 全Terraformルートを検証（AWS/Vercel認証情報不要） |
| `tf:test` | `terraform test`（mock providerでオフライン実行、認証情報不要） |
| `tf:bootstrap:init` / `:plan` / `:apply` | `infra/bootstrap` の初回セットアップ |
| `tf:init` / `tf:plan` / `tf:apply` | `infra/prod` の適用（要 `backend.hcl`, 要sops/AWS/Vercel認証情報） |
| `docker:build` | `Dockerfile.vercel` をローカルビルド |
| `docker:smoke` | ビルドしたイメージを起動し `$PORT` での疎通を確認 |
| `docker:scan` | Trivyで HIGH/CRITICAL 脆弱性スキャン |
| `secrets:edit` | `secrets/prod.enc.yaml` をsopsで編集 |
| `ci` | 上記の検証系タスクを一通り実行（ローカルでのpush前チェックにも使える） |

CI (`.github/workflows/ci.yml`) もこれらのタスクをそのまま呼び出しており、
ローカル・CI・今後の運用チェックで同じコマンドを使い回す。

## 初回のインフラ構築手順

1. **状態管理基盤の作成**（`infra/bootstrap`、ローカルstate）

   ```sh
   mise run tf:bootstrap:init
   mise run tf:bootstrap:apply
   terraform -chdir=infra/bootstrap output
   ```

   詳細は [infra/bootstrap/README.md](infra/bootstrap/README.md) を参照。

2. **秘匿情報の設定**

   `infra/bootstrap` の出力 `kms_key_arn` を `secrets/.sops.yaml` に書き込み、
   `mise run secrets:edit` でVercel APIトークン等を暗号化保存する。
   詳細は [secrets/README.md](secrets/README.md) を参照。

3. **本番インフラの適用**（`infra/prod`、S3 remote backend）

   ```sh
   cp infra/prod/backend.hcl.example infra/prod/backend.hcl
   # backend.hcl の bucket を手順1で控えた state_bucket_name に書き換える
   mise run tf:init
   mise run tf:plan
   mise run tf:apply
   ```

   `infra/prod/variables.tf` の `custom_domain` はプレースホルダー(`example.com`)なので、
   実際のドメインが決まったら `infra/prod/terraform.tfvars`
   （`terraform.tfvars.example` をコピー）で上書きする。

4. **Vercel側の設定**

   `vercel_project.git_repository` でGitHub連携を設定するため、事前にVercelの
   GitHub Appをこのリポジトリにインストールしておく。以降は `main` へのpushで
   自動デプロイされる。

## セキュリティ対策の要点

- **依存関係**: `npm audit` をCIで実行し、Dependabot (`.github/dependabot.yml`) が
  npm / Docker / GitHub Actions / Terraform provider を定期更新する。
- **コンテナ**: 非rootの `nginx-unprivileged` ベース、マルチステージビルドで
  ビルドツールを最終イメージに残さない、Trivyによる脆弱性スキャンをCIでゲート。
- **Webアプリケーション**: CSP / X-Content-Type-Options / X-Frame-Options /
  Referrer-Policy / Permissions-Policy / HSTS をNginxで付与、`server_tokens off`。
- **シークレット管理**: 平文の秘匿情報はコミットしない。sops + AWS KMSで暗号化し、
  CIはGitHub OIDC経由でAWSロールを引き受ける（長期AWSキーをGitHub Secretsに置かない）。
- **Terraform state**: S3にSSE-KMS暗号化・バージョニング・パブリックアクセスブロック済み
  バケットで保管し、S3ネイティブロック(`use_lockfile`)で同時実行を防ぐ。

## 未実施事項（このリポジトリのスキャフォールド時点）

- 実際の `terraform apply` / Vercelプロジェクト作成 / sops暗号化の実行
  （AWS認証情報・Vercelトークンが必要なため、上記手順に沿ってユーザー側で実施する）。
- E2Eテスト（要件により対象外。フロントエンド・Terraformとも unit test / `terraform test` まで）。
