# Base image build Cli
docker build --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 -t ccgodevc:2.1.118-1.25-trixie .
