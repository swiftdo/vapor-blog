## Vapor 博客系统实战项目

开发状态：开发中...

源码：

[https://github.com/swiftdo/vapor-blog](https://github.com/swiftdo/vapor-blog)

网站：

![前端](https://github.com/swiftdo/vapor-blog/assets/12316547/c1df733b-5469-47c8-b213-b51d81130003)

后台：

![后台](https://github.com/swiftdo/vapor-blog/assets/12316547/553c87f9-1d66-4a9d-8ecb-c95fb2c9db9c)

文档：

相关文档：[点击前往](https://github.com/swiftdo/vapor-blog/wiki)

## 角色和权限：

系统管理员 > 管理员 > 其他.

一般系统管理员，是指内置的一个管理员，它无视权限校验，全部功能都可用，只能操作数据库的字段才能指定。
管理员：有管理权限 + 用户自身权限
普通用户：用户自身权限
其他: ...

所以系统必须至少内置一个系统管理员，以及初始化一个普通用户角色。
