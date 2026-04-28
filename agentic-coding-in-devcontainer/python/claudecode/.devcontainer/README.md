# Base image build cli
docker build --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 -t ccpydevc:2.1.118-3.12-bullseye .
