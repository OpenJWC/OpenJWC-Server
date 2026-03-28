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

或者从文件中导入镜像。

```
docker load -i openjwc-images-v1.tar
```

```docker-compose.yml
version: '3.8'

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

镜像导入后在最好某个空目录下（这个目录之后会存放日志文件以及数据库文件）创建以上文件，并在同目录下放置admins.json用于初始化管理员账号，格式如下：

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

之后运行：

```
docker-compose up -d
```
