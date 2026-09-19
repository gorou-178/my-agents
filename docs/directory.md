---
type: Directory Structure
title: ディレクトリ構成
description: リポジトリ内のディレクトリと主要ファイルの役割
---

# ディレクトリ構成

- ./claude: Claude Codeのユーザー設定テンプレート
  - settings.json: Claude Codeの設定
  - statusline.sh: モデル名、コンテキスト使用率、レート制限を表示するステータスライン
  - rules/: 全プロジェクトに適用するClaude Codeのユーザーレベルルール
    - output-format.md: 回答の言語、構成、検証結果の示し方
    - secret-management.md: シークレットの参照、保存、表示に関する制約
    - external-communication.md: 外部送信・公開前の確認手順
    - git.md: Gitの確認、コミット、同期に関する運用ルール
    - learning-loop.md: 訂正や失敗から再利用可能な知識へ反映する手順
- ./src: ソースコードディレクトリ
- ./docs: ドキュメントディレクトリ
  - README.md: プロジェクトの要件や仕様ドキュメントへのインデックス
  - architecture.md: プロジェクトのアーキテクチャについて記載
  - directory.md: リポジトリのディレクトリ構成について（本ファイル）
  - index.md: OKF準拠のドキュメント索引
  - knowledge.md: レビュー・エージェント間の問題解決ナレッジ
  - log.md: ドキュメントの更新履歴
