---
type: Agent Configuration
title: 共通テンプレートの配置と検証
description: 共通指示・プロジェクト設定・ユーザー設定の配置先と確認方法
---

# 共通テンプレートの配置と検証

## 配置するファイル

| 配置先 | 用途 |
| --- | --- |
| `AGENTS.md` | 各プロジェクトのルート。両ツールで共有する常時指示 |
| `CLAUDE.md` | 各プロジェクトのルート。`@AGENTS.md`を読み込む入口 |
| `docs/agent-guides/` | 同じ相対パス。作業条件に応じて参照する共通手順 |
| `docs/README.md` | 文書管理規則。既存の規則がある場合は内容を統合 |
| `docs/knowledge.md` | 問題解決ナレッジの記録形式。既存の学びがあれば保持して統合 |
| `.claude/settings.json` | プロジェクトで共有する`Read`・`Write`の自動許可 |
| `.claude/settings.user.example.json` | 個人設定と共通の権限ルールを`~/.claude/settings.json`へ統合するための見本。見本の名前のままでは自動適用されない |
| `.claude/statusline.sh` | ユーザー設定のステータス表示を使う場合は`~/.claude/statusline.sh`へ配置 |

`docs/project-rules.md`には導入先の目的・制約を記載する。`docs/index.md`には共通手順と導入先の文書を登録し、既存の索引を保持する。共通テンプレートには、導入先に依存しない指示・手順と文書の記録形式を含める。

## 読み込みと正本

- Codexは`AGENTS.md`、Claude Codeは`CLAUDE.md`経由で同じ共通指示を読む。両方とも作業開始時に、存在する`docs/project-rules.md`を読む。
- 実装・検証・開発ツールの操作前に、`AGENTS.md`から[開発ルール](development.md)を参照する。
- 回答形式・シークレット管理は`AGENTS.md`が正本。
- 開発・Git・学習・外部発信の詳細は`docs/agent-guides/`が正本。
- 手順をMarkdownリンクで案内することと、`@`で常時読み込むことを区別する。必要時参照の手順を`.claude/rules/`や常時インポートにも重複配置しない。

## 設定の分離

モデル・推論強度・表示・言語・通知・更新チャネル・コミット表記の好みと、権限の既定モード・全プロジェクトに適用する許可・確認・禁止ルールはユーザー設定の見本にまとめる。見本は既存のユーザー設定にキー単位で統合し、無関係な設定を保持する。`permissions.allow`・`ask`・`deny`の配列は既存項目を保持して重複を除きながら追加する。

- `statusLine.command`は`$HOME/.claude/statusline.sh`を参照する。Bashと`jq`が必要で、Git情報はGitリポジトリ内でのみ表示する。
- 推論強度はユーザー設定の`effortLevel: high`で指定する。
- `remoteControlAtStartup: true`と`skipAutoPermissionPrompt: true`はユーザー設定で管理する。
- 未使用の設定キーは省略する。

## 権限と承認

- [プロジェクト設定](../../.claude/settings.json)は`Read`・`Write`の自動許可を定義する。
- [ユーザー設定の見本](../../.claude/settings.user.example.json)は`permissions.defaultMode: auto`と、共通の`allow`・`ask`・`deny`を定義する。導入先での実際の権限は、適用される各スコープの設定で決まる。
- 導入先で`npm test`などの検証コマンドを自動許可に追加する場合は、そのプロジェクトの`package.json`と実行先を確認する。スクリプト内容が変わった場合も確認し直す。
- 外部発信の承認条件は[外部発信手順](external-communication.md)に従う。所有者によるGitHubの例外は、宛先を判定できない静的な権限パターンでは表現できないため、ツール側の確認が追加されることがある。
- 権限リストは各スコープの設定から合算され、`deny`・`ask`・`allow`の順に評価される。
- ユーザー所有のGitHubリポジトリも、`deny`で禁止された操作の例外にはならない。
- コマンド文字列のパターンは、別の起動形式や任意のプログラムによる通信すべてを制限する仕組みではない。MCPなどの送信ツールは導入時に確認対象を設定し、ネットワーク自体の制限が必要ならサンドボックス等を併用する。

## ユーザー設定で禁止する操作

ルールの正本は[ユーザー設定の見本](../../.claude/settings.user.example.json)の`permissions.deny`。確認してから実行する操作と、実行自体を禁止する操作を区別する。

| 対象 | 禁止する操作・代表的な形式 |
| --- | --- |
| Gitのリポジトリ作成 | `git init` |
| Gitの削除 | ブランチ・タグの削除、`git push --delete`・`-d`・`:ref`によるリモート参照の削除 |
| Gitの強制更新 | `git push --force`・`--force-with-lease`・`-f`・主な結合短縮形、`+refspec`、`--mirror`、`--prune` |
| GitHub CLIの削除 | `gh … delete`・`delete-asset`、APIの`DELETE`や`deleteRepository`を含む呼び出し |
| GitHub CLIのリポジトリ作成 | `gh repo create`・`gh repo fork`、`createRepository`・`forkRepository`を含むAPI呼び出し |
| SSH・SCP | `ssh`・`scp`の直接実行と実行ファイルのパスを指定した呼び出し |
| Herdrのリモート操作 | `--machine`・`--remote`を指定した呼び出し、`machine add` |

Git・GitHub CLIではグローバルオプションが先行する代表的な形式と実行ファイルのパス指定も対象にする。`git status`・`diff`・通常のpush、`gh repo view`などはこの禁止リストの対象に含めず、既存の承認方針を適用する。

これらはコマンド文字列に対する制限であり、独自エイリアス、任意のスクリプト、APIの全リクエスト内容、Git内部で起動するSSHなどまで意味を解析して遮断するものではない。禁止操作を別の経路へ置き換えて実行しない。

## 配置後の検証

1. JSON・シェルの構文、リンク・インポートの参照先、文書索引と概念文書のfrontmatterを確認する。
2. 共通指示から開発ルールとプロジェクト固有の制約まで辿れること、必要時参照の共通手順が常時インポートにも重複配置されていないことを確認する。
3. ステータス表示を使う場合は、通常値・欠損値・0／100％の入力で3行の表示と終了コードを確認する。
4. 禁止・通常操作の代表的なコマンド文字列で、禁止パターンの対象範囲を静的に照合する。短縮オプションは引数の区切りを含めて照合し、`-f`の禁止が`--follow-tags`などの別の引数を誤拒否しないことも確認する。破壊的なコマンドを実行して検証しない。
5. 新しいClaude Codeセッションの`/status`で設定元、`/permissions`で統合後の権限を確認する。CLI以外では`defaultMode`の参照元が異なる場合があるため、使用する画面でも確認する。
6. 送信を伴わない検証と、実際の送信の承認を分ける。静的なパターン検証を、実際のClaude Codeでの拒否動作の検証と報告しない。

公式仕様の確認先：[読み込み](https://code.claude.com/docs/en/memory)、[設定スコープ](https://code.claude.com/docs/en/settings)、[設定キー](https://code.claude.com/docs/en/settings-reference)、[権限](https://code.claude.com/docs/en/permissions)。配置・権限の挙動は利用バージョンで確認する。
