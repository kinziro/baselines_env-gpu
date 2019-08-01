baselines_env-gpu
====

深層強化学習ライブラリ「stable-baselines」実行用dockerファイルです.  
OS : Ubuntu 18.04  
GPU : Nvidia Geforce GTX 1080 Ti

## Description

構成

- Dockerfile : Dockerfile
- into_container/ : コンテナ内にコピーするファイルを入れるディレクトリ
- cuDNN/ : コンテナ内にコピーするcuDNNインストーラを入れるディレクトリ
- build.sh : DockerfileをDockerimageにbuildするスクリプト
- run.sh : Dockerimageからコンテナを起動するスクリプト

各種バージョン
- python==3.5
- tensorflow==1.13.1
- stable-baselines
- gym
- 他の詳細は into_container/requirements_*.txtを参照

## Version
latest : baselines-env:1.0

1.0 &emsp; 2019/08/01 新規作成  

## Install

### dockerのインストールと設定

### リポジトリをクローン
```git
$ git clone https://github.com/kinziro/baselines_env-gpu.git
```

## Usage
1. cuDNN 7.4のインストーラをダウンロードして、cuDNNディレクトリ配下に置く
   - libcudnn7_7.4.1.5-1+cuda10.0_amd64.deb  
   - libcudnn7-dev_7.4.1.5-1+cuda10.0_amd64.deb  
   - libcudnn7-doc_7.4.1.5-1+cuda10.0_amd64.deb  
1. run.shの「'localdir'」を自分の実行したいpythonファイルを置いているディレクトリに変更
1. Dockerfileをビルド
1. Dockerイメージをコンテナ化

### 設定

### コンテナ内のユーザー
- user : developer
- password : P@ssw0rd

### ビルド
```build.sh
$ sh build.sh
```

### コンテナ起動
```run.sh
$ sh run.sh
```

## Contribution

## Licence

## Author

