# Base image build cli
```bash
# CC_VERSION 默认 2.1.139，可通过 --build-arg CC_VERSION 覆盖（从环境变量读取）
export CC_VERSION=2.1.139
docker build --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 --build-arg CC_VERSION -t ccpydevc:${CC_VERSION}-3.12-debian12 .
```

