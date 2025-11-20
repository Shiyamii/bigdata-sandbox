docker build -t bigdata-sandbox .
docker login
docker tag bigdata-sandbox:latest shiyamii/bigdata-sandbox:v1
docker tag bigdata-sandbox:latest shiyamii/bigdata-sandbox:lastest
docker push shiyamii/bigdata-sandbox:v1