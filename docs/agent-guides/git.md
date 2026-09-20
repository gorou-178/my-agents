---
type: Agent Procedure
title: Git運用
description: Gitを使うプロジェクトでのみ適用する確認・コミット・同期手順
---

# Git運用

- Gitを使うプロジェクトでのみ適用する。プロジェクト固有の禁止・ブランチ運用を先に確認する。
- [ユーザー設定の禁止操作](setup.md)は確認・承認の有無によらず実行しない。禁止された削除・強制更新・リポジトリ作成を、API・エイリアス・別のコマンドで代替しない。
- コミットメッセージは1行の日本語。stage → commit → pushを一式とし、外部発信の確認は[外部発信手順](external-communication.md)に従う。
- ブランチ切り替えは`git switch`、新規作成は`git switch -c`。複数リポジトリでは`git -C <path>`を使う。
- コミット前に`git status --short`と差分を確認し、無関係な変更を含めない。
- リモートとの差を判断する前に`git fetch`する。取得できない場合は、確認範囲がローカルに限られることを明示する。cleanな作業ツリーだけでリモートの状態や他者の作業を判断しない。
- push前に、利用中のアカウント・push先のリモートURL・対象ブランチをコマンドで確認する。`github.com`のリモートURLでowner部分が`gorou-178`と一致する場合は、ユーザーへの所有者確認と実行直前の承認を省略する。
- 所有者判定には実際のpush先URLを使う。fetch専用URL、push対象ではない別remote、ホスト名以外の場所に`github.com`を含むURL、owner以外の場所に`gorou-178`を含むURLを根拠にしない。
