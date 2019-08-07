# SlackPet

A customizable Slack bot tool with pet-like friendliness written in swift.

## 初期設定
`exampleEnv.swift` でコメントアウトされている部分を `env.swift` に追加してください。
各 `Secrets("")` の `""` 内に記述することで動作します。

- `slackBotToken`: SlackBot トークン
- `githubUserName`: GitHub のユーザ名
- `githubPersonalToken`: GitHub のパーソナルアクセストークン
- `githubTargetUser`: GitHub の対象リポジトリユーザー名
- `githubTargetRepository`: GitHub の対象リポジトリ名

```swift
public extension Secrets {
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
