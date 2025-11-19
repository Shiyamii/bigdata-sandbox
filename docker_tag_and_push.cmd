docker build -t bigdata-sandbox .
docker login
docker tag bigdata-sandbox:latest shiyamiii/bigdata-sandbox:v1
docker tag bigdata-sandbox:latest shiyamiii/bigdata-sandbox:lastest
docker push shiyamiii/bigdata-sandbox:v1