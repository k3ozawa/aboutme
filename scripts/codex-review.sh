#!/usr/bin/env bash
# ============================================================
# Kanban Review → Codex 自動コードレビュースクリプト
#
# 使い方:
#   ./scripts/codex-review.sh
#
# 動作:
#   Kanban の Review カラムにあるタスクを取得し、
#   各タスクの worktree で codex によるコードレビューを実行する。
#   一度レビュー済みのタスクはスキップする。
# ============================================================

set -euo pipefail

# ---- 設定 ---------------------------------------------------
PROJECT_PATH="/Users/ozawakosuke/aboutme"
WORKTREE_BASE="/Users/ozawakosuke/.cline/worktrees"
REVIEWED_FLAG_PREFIX="/tmp/codex-reviewed-"

# codex CLI の検索
CODEX_BIN=""
if command -v codex &>/dev/null; then
  CODEX_BIN="$(command -v codex)"
elif [[ -x "/usr/local/bin/codex" ]]; then
  CODEX_BIN="/usr/local/bin/codex"
else
  echo "ERROR: codex CLI が見つかりません。インストールしてください。" >&2
  echo "       npm install -g @openai/codex  または" >&2
  echo "       https://github.com/openai/codex を参照してください。" >&2
  exit 1
fi

echo "codex: ${CODEX_BIN}"

# ---- Review タスク一覧取得 ----------------------------------
echo "=== Review カラムのタスクを取得中... ==="

TASKS_JSON=$(kanban task list --column review --project-path "${PROJECT_PATH}" 2>/dev/null) || {
  echo "ERROR: kanban コマンドの実行に失敗しました。" >&2
  exit 1
}

TASK_IDS=$(echo "${TASKS_JSON}" | python3 -c "
import json, sys
data = json.load(sys.stdin)
tasks = data['tasks'] if isinstance(data, dict) else data
for t in tasks:
    print(t.get('id', ''))
" 2>/dev/null) || {
  # JSON パースに失敗した場合は行ごとにIDを抽出 (フォールバック)
  TASK_IDS=$(kanban task list --column review --project-path "${PROJECT_PATH}" 2>/dev/null \
    | awk '/^[[:space:]]*[a-f0-9-]{36}/ { print $1 }')
}

if [[ -z "${TASK_IDS}" ]]; then
  echo "Review カラムにタスクはありません。"
  exit 0
fi

# ---- 各タスクをレビュー -------------------------------------
while IFS= read -r TASK_ID; do
  [[ -z "${TASK_ID}" ]] && continue

  echo ""
  echo "--- タスク: ${TASK_ID} ---"

  # レビュー済みチェック
  FLAG_FILE="${REVIEWED_FLAG_PREFIX}${TASK_ID}"
  if [[ -f "${FLAG_FILE}" ]]; then
    echo "スキップ: 既にレビュー済みです (${FLAG_FILE})"
    continue
  fi

  # worktree パスの確認
  WORKTREE_PATH="${WORKTREE_BASE}/${TASK_ID}/aboutme"
  if [[ ! -d "${WORKTREE_PATH}" ]]; then
    echo "WARNING: worktree が見つかりません: ${WORKTREE_PATH}" >&2
    echo "         このタスクはスキップします。"
    continue
  fi

  # git diff の確認
  DIFF=$(git -C "${WORKTREE_PATH}" diff main...HEAD 2>/dev/null) || {
    echo "WARNING: git diff の取得に失敗しました (task=${TASK_ID})" >&2
    continue
  }

  if [[ -z "${DIFF}" ]]; then
    echo "INFO: main からの差分がありません。スキップします。"
    touch "${FLAG_FILE}"
    continue
  fi

  DIFF_LINES=$(echo "${DIFF}" | wc -l | tr -d ' ')
  echo "diff: ${DIFF_LINES} 行"

  # codex によるコードレビュー実行
  echo "codex レビューを開始します..."
  (
    cd "${WORKTREE_PATH}"
    "${CODEX_BIN}" review --base main
  ) && REVIEW_EXIT=0 || REVIEW_EXIT=$?

  if [[ "${REVIEW_EXIT}" -ne 0 ]]; then
    echo "WARNING: codex レビューがエラーで終了しました (exit=${REVIEW_EXIT}, task=${TASK_ID})" >&2
    echo "         次回も再試行されます (フラグを作成しません)。"
    continue
  fi

  # レビュー済みフラグを作成
  touch "${FLAG_FILE}"
  echo "完了: レビュー済みフラグを作成しました (${FLAG_FILE})"

done <<< "${TASK_IDS}"

echo ""
echo "=== 全タスクの処理が完了しました ==="
