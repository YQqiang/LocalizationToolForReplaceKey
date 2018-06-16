# LocalizationToolForReplaceKey
![](http://yuqiangcoder.com/assets/postImages/ios/201806/1.png)
### 前言
之前发过如何查询项目代码中未国际化的字符串工具 [LocalizationTool](http://yuqiangcoder.com/2017/12/22/LocalizationTool-%E5%9B%BD%E9%99%85%E5%8C%96%E5%B7%A5%E5%85%B7.html), 但是全部词条翻译后, 资源文件仍然有很多问题.

1. 资源文件中词条重复

    * 可能是 key 相同, value 相同;
    * 也可能是 key 相同, value 不同;
    * 甚至可能是 key 不同, value 相同;

2. 存在资源文件中存在的词条, 实际项目代码中却未使用到(可能是功能更改或者提示文案变更, 而资源文件未同步更新的原因);
3. 和安卓组的资源文件不统一;
4. 定义的 `key` 不符合规定, 需要重新替换 `key`;

本工具力求解决上述问题: 去重, 删除无用词条, 替换key 等.

### 下载
下载地址: 
[LocalizationToolForReplaceKey 源码](https://github.com/YQqiang/LocalizationToolForReplaceKey)

### 使用
![应用程序界面](http://yuqiangcoder.com/assets/postImages/ios/201806/2.png)

1. 输出资源文件中 `I18N` 开头的词条;
    * 拖入资源文件 `xxx.strings` 到左侧面板, 点击开始.
    * 执行完毕, 可点击文件夹icon, 自动打开输出的文件夹.
2. 输出资源文件中 `非I18N` 开头的词条;
    * 拖入资源文件 `xxx.strings` 到左侧面板, 点击开始.
    * 执行完毕, 可点击文件夹icon, 自动打开输出的文件夹.
3. 输出资源文件中 `key相同, value相同` 的词条;
    * 拖入资源文件 `xxx.strings` 到左侧面板, 点击开始.
    * 执行完毕, 可点击文件夹icon, 自动打开输出的文件夹.
4. 输出资源文件中 `key相同, value不同` 的词条;
    * 拖入资源文件 `xxx.strings` 到左侧面板, 点击开始.
    * 执行完毕, 可点击文件夹icon, 自动打开输出的文件夹.
5. 输出资源文件中 `key不同, value不同` 的词条;
    * 拖入资源文件 `xxx.strings` 到左侧面板, 点击开始.
    * 执行完毕, 可点击文件夹icon, 自动打开输出的文件夹.
6. 输出资源文件中 `目标文件中存在(面板右侧), 源文件中不存在(页面左侧)` 的词条;
    * 拖入源资源文件到左侧面板, 点击开始.
    * 拖入目标资源文件到右侧侧面板, 点击开始.
    * 执行完毕, 可点击文件夹icon, 自动打开输出的文件夹.
    * 该功能可查询源文件中未用到的词条, 或进行词条去重.
7. 使用目标文件中 `key-value` 的 `value` 匹配源文件中的 `key`, 并使用目标文件的 `key` 替换源文件中的 `key`;
    * 拖入源资源文件到左侧面板, 点击开始.
    * 拖入目标资源文件到右侧侧面板, 点击开始.
    * 此操作无文件输出, 因为直接在源文件上做替换操作.
    * 可替换代码中不规范的 `key`.


### 支持的文件格式如下:

* [x] OC代码 `.m`
* [x] Swift代码 `.swift`
* [x] iOS 国际化资源 `.strings`
* [x] Android 国际化资源 `.xml`


## 联系我：
- 博客: http://yuqiangcoder.com/
- 邮箱: yuqiang.coder@gmail.com


