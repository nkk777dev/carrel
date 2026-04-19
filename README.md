# Carrel

Flutterを使用した新しいプロジェクトです。

## GitHub Pages への自動デプロイ設定について

当プロジェクトはソースコードを `main` ブランチにプッシュするだけで、GitHub Actionsを利用して自動的にFlutter Webビルドが行われ、GitHub Pagesにデプロイされる仕組みが含まれています。
設定ファイル: `.github/workflows/deploy.yml`

### 必要な初回設定（GitHub側）

自動デプロイを有効にするために、ご自身のGitHubの画面から以下の設定を行ってください。

1. GitHubリポジトリ [nkk777dev/carrel](https://github.com/nkk777dev/carrel) を開く
2. リポジトリ上部の **Settings** (設定) をクリックする
3. 左側のメニューから **Pages** を選択する
4. **Build and deployment** セクションの **Source** を現在の `Deploy from a branch` から **`GitHub Actions`** に変更する

この設定を行うとActionワークフローが実行され、`https://nkk777dev.github.io/carrel/` にプロジェクトが自動で公開されます。

## 開発を始めるには

プロジェクトを初めて編集・実行するための公式リソースはこちらを参考にしてください：

- [最初のFlutterアプリを書く (ラボ)](https://docs.flutter.dev/get-started/codelab)
- [有益なFlutterサンプル (クックブック)](https://docs.flutter.dev/cookbook)

オンラインの [公式ドキュメント](https://docs.flutter.dev/) では、各種チュートリアルやAPIリファレンスが提供されています。
