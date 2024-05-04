# pluralith-aws-practice

DockerコンテナにterraformとPluralithをインストールして実施したかったが、できなかったため、macに直接terraformとPluralithをインストールする。


## 前提
1. Pluralithのアカウントが作成済みである（未作成の場合は`https://www.pluralith.com/`で作る）
2. brewがインストール済みである

## インストール
### terraform
```
brew install tfenv
```

```
tfenv install 1.7.5
```
```
tfenv use 1.7.5
```

### Pluralith
#### pluralith-cli
以下からmac用のバイナリをダウンロード
https://github.com/Pluralith/pluralith-cli/releases


バイナリを`pluralith`にリネームして/usr/local/bin/配下に移動して実行権限付与

参考
```
mv pluralith_cli_darwin_amd64_v0.2.2 pluralith
mv pluralith /usr/local/bin/
chmod +x /usr/local/bin/pluralith
```

#### pluralith-cli-graphing
以下からmac用のバイナリをダウンロード
https://github.com/Pluralith/pluralith-cli-graphing-release/releases


バイナリを`pluralith-cli-graphing`にリネームして/usr/local/bin/配下に移動して実行権限付与

参考
```
mv pluralith_cli_graphing_darwin_amd64_0.2.1 pluralith-cli-graphing
mv pluralith-cli-graphing /usr/local/bin/
chmod +x /usr/local/bin/pluralith-cli-graphing
```

####　確認
以下を実行
```
pluralith version
```

CLI VersionとGraph Module Versionにバージョン番号が表示されていればOK。Not InstalledはNG。（https://github.com/Pluralith/pluralith-cli/issues/131）

```
%pluralith version
parsing response failed -> GetGitHubRelease: %!w(<nil>)
 _
|_)|    _ _ |._|_|_
|  ||_|| (_||| | | |

→ CLI Version: 0.2.2
→ Graph Module Version: 0.2.1
```


## 実行
### 環境変数

```
export AWS_ACCESS_KEY_ID=<AWS ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<AWS SECRET ACCESS KEY>
export TF_ENV=dev
```

### terraform init
```
terraform init
```

### 出力

#### 先にpluralithにログイン
```
pluralith login --api-key <APIキー>
```

#### pluralith実行

##### pluralithのサーバに出力
```
pluralith graph
```

##### ローカルに出力
```
pluralith graph --local-only
```
実行したディレクトリ配下に`Pluralith_Diagram.pdf`が出力される。