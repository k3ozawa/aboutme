# secrets/

Terraform (`infra/prod`)や運用で使う秘匿情報は、平文でコミットせず
[sops](https://github.com/getsops/sops) + AWS KMS で暗号化して管理する。

## 初回セットアップ

1. `infra/bootstrap` を適用済みであること（KMSキーが存在すること）。
2. `terraform -chdir=infra/bootstrap output kms_key_arn` の値を控え、
   `secrets/.sops.yaml` の `kms:` をその値に書き換える。
3. AWS認証情報（KMSキーへの `kms:Encrypt` / `kms:Decrypt` 権限があるIAM主体)を用意する。
4. 以下を実行して暗号化ファイルを作成・編集する。

   ```sh
   mise run secrets:edit
   ```

   初回は `secrets/prod.enc.yaml` が存在しないため、sopsがテンプレートを開く。
   最低限、以下のキーを追加する。

   ```yaml
   vercel_api_token: "実際のVercel APIトークン"
   ```

   保存してエディタを閉じると、sopsが自動的にKMSで暗号化して
   `secrets/prod.enc.yaml` に書き込む。

## 運用

- 編集は必ず `mise run secrets:edit`（内部で `sops secrets/prod.enc.yaml` を実行）を使う。
  平文を一時ファイルに書き出して手動で暗号化する運用はしない。
- `secrets/*.enc.yaml` は暗号化済みなのでコミットしてよい。
- 復号した平文（`sops -d` の出力をファイルに保存したものなど）は絶対にコミットしない
  （`.gitignore` で `secrets/*.dec.yaml` 等の平文出力先を除外済み）。
- `infra/prod` の Terraform は `data.sops_file` 経由でこのファイルを直接復号して読む
  （`terraform plan`/`apply` を実行するIAM主体にKMSの復号権限が必要）。
