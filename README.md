# 文档

由于 Swift 在云服务器拉取第三方依赖慢如蜗牛。今天群里有大佬提供了个思路，用 Docker 打包。如果能在 MacOS 打二进制包，然后将二进制包直接部署到云服务器，那就彻底解决了这个蛋碎问题。

有一个技术点需要补充：

> 如果云服务器中没有安装 Swift 环境，正常打包的二进制是无法在运行的。swift build 有个参数，可以直接打包swift的环境依赖：`swift build --static-swift-stdlib`

## Dockerfile

```sh
# ================================
# 构建镜像
# ================================
FROM swift:5.8-jammy as build

# 安装操作系统更新，如果需要，安装 sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/*

# 设置构建区域
WORKDIR /build

# 首先解决依赖问题
# 这将创建一个可以重复使用的缓存层
# 只要你的 Package.swift/Package.resolved 文件不改变
COPY ./Package.* ./
RUN swift package resolve --verbose

# 将整个 repo 复制到容器中
COPY . .

# 构建
RUN swift build -c release --static-swift-stdlib --verbose

# 切换到暂存区
WORKDIR /staging

# 将可执行文件复制到暂存区
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./

# 将 SPM 捆绑的资源复制到暂存区
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# 如果目录存在，则从 public 目录和 views 目录复制任何资源
# 确保默认情况下目录及其任何内容均不可写。
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

RUN tar -czf /staging.tar.gz -C /staging .

# 删除原始文件
RUN rm -rf /staging
```

其中：

```sh
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./
```

是将`App`这个二进制包进行拷贝，`App`取名取决于`Package.swift`中 executableTarget 的 `name: "App"`：

```swift
.executableTarget(
    name: "App",
    dependencies: [
        .product(name: "Vapor", package: "vapor")
    ],
    swiftSettings: [
        // Enable better optimizations when building in Release configuration. Despite the use of
        // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
        // builds. See <https://www.swift.org/server/guides/building.html#building-for-production> for details.
        .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
    ]
),     
```

上面就完成了打包功能。

## package.sh

通过编写额外脚本，将 Docker 编译的二进制导出到本地。

```sh
docker build -t package-docker-image .
docker create --name temporary-container package-docker-image
docker cp temporary-container:/staging.tar.gz ./PackageApp.zip
docker rm temporary-container
open ./
```

这样就会将在 Docker 编译好的`staging.tar.gz`拷贝到`PackageApp.zip`文件夹中。

给 `package.sh` 添加权限：

```sh
chmod -R 777 package.sh
```

## 最终

打包，在项目根目录下执行：

```shell
$ sh package.sh      
[+] Building 297.9s (19/19) FINISHED                                                                         
 => [internal] load build definition from Dockerfile                                                    0.0s
 => => transferring dockerfile: 4.43kB                                                                  0.0s
 => [internal] load .dockerignore                                                                       0.0s
 => => transferring context: 58B                                                                        0.0s
 => [internal] load metadata for docker.io/library/swift:5.8-jammy                                      1.0s
 => [ 1/14] FROM docker.io/library/swift:5.8-jammy@sha256:a9e2777a93831be8f2c2994c28e49afbb7995d4d272b  0.0s
 => [internal] load build context                                                                       0.8s
 => => transferring context: 36.62MB                                                                    0.8s
 => CACHED [ 2/14] RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true     && a  0.0s
 => CACHED [ 3/14] WORKDIR /build                                                                       0.0s
 => CACHED [ 4/14] COPY ./Package.* ./                                                                  0.0s
 => CACHED [ 5/14] RUN swift package resolve --verbose                                                  0.0s
 => [ 6/14] COPY . .                                                                                    1.6s
 => [ 7/14] RUN swift build -c release --static-swift-stdlib --verbose                                281.0s
 => [ 8/14] WORKDIR /staging                                                                            0.0s
 => [ 9/14] RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./             2.4s
 => [10/14] RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\  0.9s 
 => [11/14] RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || tru  0.3s 
 => [12/14] RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resourc  0.3s 
 => [13/14] RUN tar -czf /staging.tar.gz -C /staging .                                                  5.6s 
 => [14/14] RUN rm -rf /staging                                                                         0.7s
 => exporting to image                                                                                  3.0s
 => => exporting layers                                                                                 3.0s
 => => writing image sha256:ba3be208801d996709ddda6a73e3ae7d4e22adfdb2f8b428a5156721abb3c68f            0.0s
 => => naming to docker.io/library/package-docker-image                                                 0.0s
749393c373b1be0f48b92d12948134b5258ed55fc2e643dd1bdaccda5ea446f3
Successfully copied 36.6MB to /Users/laijihua/Desktop/Dev/Vapor/Code/hello/PackageApp.zip
temporary-container
```

文件目录树：

```sh
./
├── Dockerfile
├── Package.resolved
├── Package.swift
├── PackageApp.zip
├── Public
├── README.md
├── Sources
│   └── App
│       ├── Controllers
│       ├── configure.swift
│       ├── entrypoint.swift
│       └── routes.swift
├── Tests
│   └── AppTests
│       └── AppTests.swift
├── docker-compose.yml
└── package.sh
```

## 注意

如果你的包中依赖了数据库，比如 postgresql，那么你的 Dockerfile 需要进行修改：

```shell
# ================================
# Build image
# ================================
FROM swift:5.8-jammy as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y postgresql \
    && rm -rf /var/lib/apt/lists/* 
# 后面跟上面一样
```
需要安装数据库 `apt-get -q install -y postgresql`


