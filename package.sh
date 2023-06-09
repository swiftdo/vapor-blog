# docker build -t package-docker-image .
docker create --name temporary-container package-docker-image
docker cp temporary-container:/staging.tar.gz ./PackageApp.zip
docker rm temporary-container
open ./
