# Docker を使用したローカルデータベースセットアップ

このプロジェクトでは、Docker Compose v2 を使用してローカル PostgreSQL データベースを簡単にセットアップできます。

## Docker Compose v2 について

このプロジェクトは Docker Compose v2 形式を使用しています：

- ファイル名: `compose.yml`（`docker-compose.yml` ではなく）
- コマンド: `docker compose`（`docker-compose` ではなく、ハイフンなし）
- フォーマット: `version` フィールドは不要（v2 では自動検出）

## クイックスタート

```bash
# PostgreSQL を起動
docker compose up -d postgres

# データベースが準備できるまで待つ（約10秒）
sleep 10

# dbt の接続をテスト
source env/bin/activate
dbt debug
```

## 使用方法

### Docker Compose コマンド

```bash
# 起動
docker compose up -d postgres

# 停止
docker compose stop postgres

# 再起動
docker compose restart postgres

# ステータス確認
docker compose ps postgres

# ログ表示
docker compose logs -f postgres

# 停止してコンテナを削除（データは保持）
docker compose down postgres

# 停止してコンテナとデータを削除
docker compose down -v postgres
```

### ヘルパースクリプト

```bash
# 起動
./scripts/docker-db.sh start

# 停止
./scripts/docker-db.sh stop

# 再起動
./scripts/docker-db.sh restart

# ステータス確認
./scripts/docker-db.sh status

# ログ表示
./scripts/docker-db.sh logs

# PostgreSQL シェルを開く
./scripts/docker-db.sh shell

# 停止してコンテナを削除（データは保持）
./scripts/docker-db.sh clean

# 停止してコンテナとデータを削除
./scripts/docker-db.sh clean-all
```

## データベース接続情報

- **ホスト**: `localhost`
- **ポート**: `5432`
- **ユーザー名**: `admin`
- **パスワード**: `admin`
- **データベース名**: `jaffle_shop`
- **スキーマ**: `jaffle_shop` (dbt で使用)

## データの永続化

データは Docker ボリューム `postgres_data` に保存されます。コンテナを削除しても、`docker compose down`（`-v` オプションなし）を使用すればデータは保持されます。

データを完全に削除する場合：

```bash
docker compose down -v postgres
```

例：

- PostgreSQL のバージョンを変更: `image: postgres:14` を `image: postgres:15` に変更
- ポート番号を変更: `ports` セクションのポート番号を変更
- 初期化 SQL スクリプトを追加: `volumes` セクションに追加

## 参考リンク

- [Docker Compose 公式ドキュメント](https://docs.docker.com/compose/)
- [PostgreSQL Docker イメージ](https://hub.docker.com/_/postgres)
