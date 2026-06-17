# Base image build Cli
# CC_VERSION 默认 2.1.139，可通过 --build-arg CC_VERSION 覆盖（从环境变量读取）
CC_VERSION=2.1.139 docker build --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 --build-arg CC_VERSION -t ccnodevc:${CC_VERSION}-18-bullseye .

# 或先导出再 build
# export CC_VERSION=2.1.139
# docker build --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 --build-arg CC_VERSION -t ccnodevc:${CC_VERSION}-18-bullseye .
