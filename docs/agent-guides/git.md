---
type: Agent Procedure
title: Git運用
description: Gitを使うプロジェクトでのみ適用する確認・コミット・同期手順
---

# Git運用

- Gitを使うプロジェクトでのみ適用する。プロジェクト固有の禁止・ブランチ運用を先に確認する。
- [ユーザー設定の禁止操作](setup.md)は確認・承認の有無によらず実行しない。禁止された削除・強制更新・リポジトリ作成を、API・エイリアス・別のコマンドで代替しない。
- コミットメッセージは1行の日本語。stage → commit → pushを一式とし、外部発信の確認は[外部発信手順](external-communication.md)に従う。
- ブランチ切り替えは`git switch`、新規作成は`git switch -c`。
- コミット前に`git status --short`と差分を確認し、無関係な変更を含めない（並行セッションがある場合は下の「並行作業との混線防止」に従う）。
- リモートとの差を判断する前に`git fetch`する。取得できない場合は、確認範囲がローカルに限られることを明示する。cleanな作業ツリーだけでリモートの状態や他者の作業を判断しない。
- push前に、利用中のアカウント・push先のリモートURL・対象ブランチをコマンドで確認する。`github.com`のリモートURLでowner部分が`gorou-178`と一致する場合は、ユーザーへの所有者確認と実行直前の承認を省略する。
- 所有者判定には実際のpush先URLを使う。fetch専用URL、push対象ではない別remote、ホスト名以外の場所に`github.com`を含むURL、owner以外の場所に`gorou-178`を含むURLを根拠にしない。

## 並行作業との混線防止

- Bash の並列実行間でも **working directory は共有される**。`cd` を使わず **`git -C <path>`** でリポを明示し、異なるリポの更新を同一メッセージで並列にしない。
- `git add -A` / `git add <dir>/` / `git add -u <dir>/` は**並行セッションの未コミットファイルを巻き込む**。対策の優先順：
  1. 自分が触ったファイルパスを明示列挙して add する
  2. `git commit <path> -m "..."` でパス指定コミット（**`git add` で明示列挙した場合に限る。`git apply --cached` で絞った直後には使わない**→下記）
  3. コミット前に `git status --short <dir>/` で目視。見覚えのないファイルは別セッションの作業
  4. `git add -A` / `git add <dir>/` / `git add -u <dir>/` は「自分しか触っていない」と確信できるときだけ
  5. 削除の stage も `git add <消したファイルの明示パス>` で足りる
- ⚠️ **複数セッションが同じファイルへ追記する「共有台帳ファイル」は、パスを明示列挙しても巻き込みを防げない。** 成果物の登録先 YAML・索引 `README.md` のほか、**ルール・設定ファイル（`CLAUDE.md` / `AGENTS.md` / `.claude/rules/*.md` / `SKILL.md`）も同じ扱いにする。** add の直前に `git diff <path>` を読んで自分の変更だけかを確かめる。混ざっていた場合、`git add -p` は対話式で使えないので、**`-U0` で変更行ごとに分割してから、自分の分だけ `git apply --cached` する**：

```bash
git diff -U0 <path> > /tmp/all.patch   # 文脈行なし＝変更行ごとに別のかたまりになる
# ヘッダー（--- / +++ まで）＋ 自分の変更のかたまりだけを抜き出して /tmp/mine.patch を作る
git apply --cached --unidiff-zero /tmp/mine.patch
git diff --cached <path>                # 自分の変更だけが stage されたか目で確認
```

⚠️ **既定の `git diff`（文脈3行）だと、近い行の変更が1つのかたまりに合流して分離できない**。必ず `-U0` と `--unidiff-zero` を使う。分離できなければ、そのファイルは**コミットせず相手に委ねる**。

⚠️ **`git apply --cached` の直後に `git commit <path> -m "..."` を打たない。** pathspec 付きの `git commit` は index を無視してワーキングツリーの内容をコミットするため、他セッションの未コミット分を巻き込む。**pathspec を付けない `git commit -m "..."`** を使う：

```bash
git apply --cached --unidiff-zero /tmp/mine.patch
git diff --cached <path>   # 自分の変更だけが stage されたか確認
git commit -m "..."        # ← ここで <path> を付けない
```

⚠️ **`git diff` での確認と `git add`〜`commit` を、同じ連結コマンド（`&&` つなぎ）に入れない。** diff は単独の呼び出しで実行し、出力を読んでから次の呼び出しで add する。

⚠️ **復元に相対リビジョン（`HEAD~1` / `HEAD^` / `@{1}`）を使わない。** 並行セッションのコミットで `HEAD` はずれている。`git log --oneline -5 -- <file>` でハッシュを確かめてから `git checkout <hash> -- <file>` を打つ。
