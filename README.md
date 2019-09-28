# SlackPet

A customizable Slack bot tool with pet-like friendliness written in swift.

## 初期設定
`exampleEnv.swift` でコメントアウトされている部分を `env.swift` に追加してください。
各 `Secrets("")` の `""` 内に記述することで動作します。


- `bitrisePersonalAccessToken`: Bitrise のパーソナルアクセストークン
- `slackBotToken`: SlackBot トークン
- `githubUserName`: GitHub のユーザ名
- `githubPersonalToken`: GitHub のパーソナルアクセストークン
- `githubTargetUser`: GitHub の対象リポジトリユーザー名
- `githubTargetRepository`: GitHub の対象リポジトリ名

```swift
public extension Secrets {
    static let bitrisePersonalAccessToken = Secrets("")
    static let slackBotToken = Secrets("")
    static let githubUserName = Secrets("")
    static let githubPersonalToken = Secrets("")
    static let githubTargetUser = Secrets("")
    static let githubTargetRepository = Secrets("")
}
```

## 実行
実行には以下のコマンドを入力してください。

```
$ make all
```


## Bitrise トリガービルド
Bitrise のビルドを開始します。

### 反応メッセージ

`:hammer: ` + Bitrise app タイトル

#### オプション

- 2行目以降に `branch: ` + Branch 名 で実行ブランチを指定する必要があります。
- 2行目以降に `workflow: ` + Workflow 名 で実行ワークフローを指定できます。
- 2行目以降に Key 名 + `: ` + Value 名 でカスタム環境変数を指定できます。

<img width="633" alt="screenshot 74" src="https://user-images.githubusercontent.com/22558921/64196565-16e9b080-cebf-11e9-8c99-d531e25d6042.png">

## GitHub issue 追加
SlackBot が存在するチャンネルでの発言に応じて GitHub に issue を作成します。

### 反応メッセージ

`:ticket: ` + 任意のタイトル + (改行) + 任意の内容

<img width="639" alt="screenshot 291" src="https://user-images.githubusercontent.com/22558921/62356430-08207e80-b54c-11e9-92c0-4f1c32b6c791.png">

#### オプション

- 2行目以降に ( `labels: ` or `label: ` ) + 存在するラベル名 でラベルがつきます (存在しない場合はラベルが生成されます)
- 2行目以降に `assignees: ` + 存在するコントリビュータ名 でアサイン指定ができます

## Slack emoji 作成
文字列からカスタム絵文字用の emoji 画像を生成し，アップロードします。

:warning: 現状 Slack には Custom emoji の作成に対応した API が公開されていないため，Bot は追加用 URL を発行します。

### 反応メッセージ

`:art: ` + 任意の文字列

<img width="633" alt="screenshot 1" src="https://user-images.githubusercontent.com/22558921/62644040-31923d80-b984-11e9-8a39-2dbca3b3a26c.png">

#### オプション

- 2行目以降に ( `color: ` or `textColor: ` or `text: ` ) + ( `0xRRGGBB` or `0xAARRGGBB` or `#RRGGBB` `#AARRGGBB` ) で文字色を指定できます。
- 2行目以降に ( `background: ` or `backgroundColor: ` or `back: ` ) + (  `0xRRGGBB` or `0xAARRGGBB` or `#RRGGBB` `#AARRGGBB` ) で背景色を指定できます。

<img width="629" alt="screenshot 4" src="https://user-images.githubusercontent.com/22558921/62676226-07bd3300-b9e5-11e9-8543-e00f254e5e2c.png">

## longcat

[longcat](https://github.com/mattn/longcat) を出力します。

`:cat: ` (+ オプション) + (任意の文字)

<img width="628" alt="screenshot 100" src="https://user-images.githubusercontent.com/22558921/64666381-176ee200-d491-11e9-99ff-a889e27f8a70.png">

#### [オプション](https://github.com/mattn/longcat#usage)

```
Usage of longcat:
  -R    flip vertical
  -i float
        rate of intervals (default 1)
  -l int
        number of columns (default 1)
  -n int
        how long cat (default 1)
  -o string
        output image file
  -r    flip holizontal
```

## ojichat

[ojichat](https://github.com/greymd/ojichat) を出力します。

`:older_man: ` (+ オプション) + (任意の文字)

<img width="630" alt="screenshot 305" src="https://user-images.githubusercontent.com/22558921/62444208-d26fd580-b797-11e9-8426-43d519e4ba5f.png">

#### [オプション](https://github.com/greymd/ojichat#使い方)

```
Options:
  -h, --help      ヘルプを表示.
  -V, --version   バージョンを表示.
  -e <number>     絵文字/顔文字の最大連続数 [default: 4].
  -p <level>      句読点挿入頻度レベル [min:0, max:3] [default: 0].
```

## タイマー
入力した時間後に Slack から通知するタイマー機能です。

`:clock` + x時間 + x分 + (伝え or 知らせ or 教え)

<img width="635" alt="screenshot 289" src="https://user-images.githubusercontent.com/22558921/62355771-a875a380-b54a-11e9-920e-f5f0661dd380.png">
<img width="639" alt="screenshot 290" src="https://user-images.githubusercontent.com/22558921/62355809-b88d8300-b54a-11e9-9429-f1b44b35d108.png">

#### オプション

`「」` を利用することで，通知時に任意のメッセージを含めることができます。

<img width="640" alt="screenshot 303" src="https://user-images.githubusercontent.com/22558921/62422077-a268f980-b6e7-11e9-8aac-482696d1752d.png">

## イースターエッグ

### Tests
- `hello` (完全一致) -> `Hello, world!!`

<img width="637" alt="screenshot 297" src="https://user-images.githubusercontent.com/22558921/62356910-073c1c80-b54d-11e9-84f2-3e5471f85084.png">

### Echoes
- `こんにちは` -> `こんにちは`
- `こんにちわ` -> `こんにちわ`

<img width="634" alt="screenshot 298" src="https://user-images.githubusercontent.com/22558921/62356909-073c1c80-b54d-11e9-99a2-1e8802cc05f3.png">

### Emotions
- `ありがとう` -> `どういたしまして!`

<img width="626" alt="screenshot 299" src="https://user-images.githubusercontent.com/22558921/62356908-073c1c80-b54d-11e9-9dd7-748674d8a50c.png">

# 開発者用

詳しくは `./Makefile` を参照して下さい。

## 環境構築
Swift のインストールなど

```
$ make deps
```

## 依存関係のインストール

```
$ make install
```

## 依存関係のアップデート

```
$ make update
```

## Xcode を開く

```
$ make open
```

## ビルド

```
$ make build
```

## ビルドして実行 (Run)

```
$ make run
```

## テスト

```
$ make test
```

## クリーン

```
$ make clean
```
