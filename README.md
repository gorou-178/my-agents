# my-agents

Codex と Claude Code で共有するエージェント設定・ドキュメントのテンプレートです。

> [!IMPORTANT]
> `docs/` は導入先プロジェクト用の文書テンプレートです。このテンプレートリポジトリ自身の
> 設計・変更履歴は記録しません。導入ツールの説明は、この `README.md` に記録します。

## 導入方法

`install.sh` に導入先フォルダを指定します。存在しないフォルダは自動作成されます。
実行にはBashが必要です。`./install.sh`・`bash install.sh`・`sh install.sh`で起動でき、いずれもBashの通常モードで動作します。

```bash
./install.sh /path/to/project
```

次の対応でファイルを配置します。

| テンプレート | 導入先 |
| --- | --- |
| `AGENTS.md` | `AGENTS.md` |
| `CLAUDE.md` | `CLAUDE.md` |
| `claude/` | `.claude/` |
| `docs/` | `docs/` |

内容が異なる既存ファイルはスキップされます。テンプレートで更新する場合は、既存ファイルを同じ場所へタイムスタンプ付きで退避する `--backup` を指定します。

```bash
./install.sh --backup /path/to/project
```

変更内容だけを事前確認する場合は `--dry-run` を使います。`--backup` と併用すると退避予定も確認できます。

```bash
./install.sh --dry-run --backup /path/to/project
```

## dotfiles との役割分担

手で書くエージェントの方針はこのリポジトリ、ツールの導入とツールが生成するファイルは[dotfiles](https://github.com/gorou-178/dotfiles)で管理します。

| リポジトリ | 管理するもの | Herdrの例 |
| --- | --- | --- |
| my-agents | 共通指示、手順、権限ルールなどの方針 | `claude/settings.user.example.json`の`allow`・`ask`・`deny` |
| dotfiles | ツール本体、設定、補完、ツールが生成するスキル | `scripts/setup-herdr.sh`が`herdr --skill`の出力を`~/.agents/skills/herdr/`と`~/.claude/skills/herdr/`へ配置 |

ツールが生成するスキルは、導入したバージョンと内容が対応するため、このリポジトリへコミットしません。更新はdotfilesのセットアップを再実行して行います。

## テスト

```bash
./tests/install_test.sh
```
