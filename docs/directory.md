---
type: Directory Structure
title: ディレクトリ構成
description: リポジトリ内のディレクトリと主要ファイルの役割
---

# ディレクトリ構成

- ./.claude: Claude Codeの設定
  - settings.json: プロジェクトで共有する権限設定
  - settings.user.example.json: `~/.claude/settings.json`へ統合するユーザー設定の見本
  - statusline.sh: モデル名、コンテキスト使用率、レート制限を表示するステータスライン
- ./docs: ドキュメントディレクトリ
  - README.md: 文書の管理・更新ルール
  - agent-guides/: CodexとClaude Codeが作業条件に応じて参照する共通手順
    - [development.md](agent-guides/development.md): 実装・検証、調査、ブラウザ操作、並行作業の開発ルール
    - [external-communication.md](agent-guides/external-communication.md): 外部送信・公開前の確認手順
    - [git.md](agent-guides/git.md): Gitの確認、コミット、同期に関する運用ルール
    - [learning.md](agent-guides/learning.md): 訂正や失敗から再利用可能な知識へ反映する手順
    - [setup.md](agent-guides/setup.md): 共通テンプレートの配置と検証
  - architecture.md: プロジェクトのアーキテクチャについて記載
  - directory.md: リポジトリのディレクトリ構成について（本ファイル）
  - index.md: OKF準拠のドキュメント索引
  - knowledge.md: レビュー・エージェント間の問題解決ナレッジ
  - log.md: ドキュメントの更新履歴
