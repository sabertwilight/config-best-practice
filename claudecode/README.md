Build CMD
```bash
docker buildx build --provenance=false --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 -t swr.cn-east-3.myhuaweicloud.com/vsatlib/claudecode:2.1.139 .
```
