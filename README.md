# OpenJWC Server

部署在你的服务器或者任何你有办法访问ip的机器上。（比如可以考虑内网穿透，或者局域网访问）

## 如何使用？

直接运行容器。

```
docker-compose up -d
```

或者如果你想构建镜像。

```
docker-compose build
```


```docker-compose.yml
services:
  backend:
    image: openjwc-backend:v1.0
    container_name: prod_backend
    restart: always
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
      - ./admins.json:/app/admins.json:ro
    environment:
      - TZ=Asia/Shanghai

  crawler_worker:
    image: openjwc-crawler:v1.0
    container_name: prod_crawler_worker
    restart: always
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    environment:
      - TZ=Asia/Shanghai
    command: ["uv", "run", "python", "-m", "app.crawler_wrapper"]
    depends_on:
      - backend


  frontend:
    image: openjwc-frontend:v1.0
    container_name: prod_frontend
    restart: always
    ports:
      - "8000:8000"
    depends_on:
      - backend

```

如果你从镜像启动容器，在最好某个空目录下（这个目录之后会存放日志文件以及数据库文件）创建以上文件，命名为`docker-compose.yml`，并在同目录下放置`admins.json`用于初始化管理员账号，格式如下：

```json
[
  {
    "username": "Alice",
    "password": "Alice@12345"
  },
  {
    "username":"Bob",
    "password": "thisisapassword"
  }
]
```
其中密码表示该账号的初始密码，管理员可登录控制面板修改密码。此json文件是当前增删管理员账号的唯一手段，仅`admins.json`中声明的管理员用户可以访问控制面板。

之后在该目录下运行：

```
docker-compose up -d
```

对于没有ssl证书的服务器，需要在浏览器中允许服务器ip为安全上下文才能通过控制面板管理员鉴权。具体操作如下：

```
edge://flags/#unsafely-treat-insecure-origin-as-secure
```

在浏览器中访问以上网址（如果用的是chrome则将edge改成chrome），启用对应字段并放行服务器ip。之后重启浏览器，按理就可以通过管理员鉴权了（前提是你有管理员账号）
