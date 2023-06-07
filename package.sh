# docker build -t package-docker-image .
docker create --name temporary-container package-docker-image
rm -rf ./PackageApp
docker cp temporary-container:/staging ./PackageApp
docker rm temporary-container
open ./PackageApp
