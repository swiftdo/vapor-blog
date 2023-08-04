## Vapor 博客系统实战项目

开发状态：开发中...

## 相关文档

* 页面预览：[页面预览](https://github.com/swiftdo/vapor-blog/wiki)
* 开发文档：[点击前往](https://github.com/swiftdo/vapor-blog/wiki)
* 源码：[https://github.com/swiftdo/vapor-blog](https://github.com/swiftdo/vapor-blog)

## 页面

网站：

![前端](https://github.com/swiftdo/vapor-blog/assets/12316547/c1df733b-5469-47c8-b213-b51d81130003)

后台：

![后台](https://github.com/swiftdo/vapor-blog/assets/12316547/2e5b6653-c7f9-4c05-bf56-616b382e56d6)



## 角色和权限：

系统管理员 > 管理员 > 其他.

系统管理员：是指内置的一个管理员，它无视权限校验，全部功能都可用，只能操作数据库的字段才能指定。
管理员：有管理权限 + 用户自身权限
普通用户：用户自身权限
其他：...

所以系统必须至少内置一个系统管理员，以及初始化一个普通用户角色。

## 首页侧边栏规划
* 热门标签，按文章数排序， 20个
* 最新发布，按文章时间排序， 10个
* 点击最多，按文章阅读数排序，10个

## TODO

* [ ] 个人主页
* [ ] 消息中心
* [ ] 文章收藏、点赞
* [ ] 作者关注
* [ ] 文章统计
* [ ] 后台主页
    * 博客数量
    * 今日发表
    * 今日访客
    * 历史访客
    * 网站访问人数
* [ ] 操作日志
* [ ] 留言功能

























