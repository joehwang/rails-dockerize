# rails-dockerize

`docker-compose up` 啟動

rails app 放在./rails_app的資料夾中

deploy到產品環境參考./deploy資料夾

## 部署

無法使用 capistrano 進行部署

需自行撰寫流程

見deploy/setup.rb與deploy/update_new_ver.rb

流程如下:

在空的production server先安裝docker-ce(見docker網站)

用ruby deploy/setup.rb建立並運行db redis nginx sidekiq等容器

之後只需用ruby deploy/update_new_ver.rb上傳新版本的程式

每次部署會以藍/綠兩代號循環，並reload nginx config設定以進行zero-downtime 部署

## rails 設定要點

### database.yml

資料庫連接方式改用`host` 參數

```yaml
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: root
  password: 123456
  host: db
```

### environments/development.rb

增加 ` config.logger = Logger.new(STDOUT)`

把log輸出到STDOUT方便用docker logs指令

### environments/production.rb

同development.rb

### 使用DRONE CI 跑test與deploy

DRONE CI所有的動作皆已容器為單位
避開了環境的相依性，非常便利

文件:`http://readme.drone.io/`

#### 現在設定

```yaml
version: '2'
services:
  drone-server:
    image: drone/drone:0.8
    ports:
      - 81:8000
      - 9000
    volumes:
      - ./var/lib/drone:/var/lib/drone/
    restart: always
    environment:
      - DRONE_OPEN=false
      - DRONE_HOST=<your drone host>
      - DRONE_BITBUCKET=true
      - DRONE_BITBUCKET_CLIENT=<your bitbucket client>
      - DRONE_BITBUCKET_SECRET=<your bitbucket secret>
      - DRONE_SECRET=<your drone secret>
      - DRONE_ADMIN=joehwang

  drone-agent:
    image: drone/agent:0.8
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SERVER=drone-server:9000
      - DRONE_SECRET=<your drone secret>
```

#### 放sshkey到CI 

$SSH_KEY可呼叫
```shell
 drone secret add \
  -repository <yourname>/rails-dockerlize \
  -image bptw/rails5 \
  -name ssh_key \
 -value @/home/<yourname>/.ssh/id_rsa
```


