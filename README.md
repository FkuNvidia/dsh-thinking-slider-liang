# dsh-thinking-slider-liang

DSH composer 里那根思考档位滑杆，档位名换成「小难梁 / 梁子 / 梁圣 / 梁祖」。

**一条命令安装，不需要打补丁、不需要额外脚本。**

```powershell
dsh plugin --profile desktop add github:FkuNvidia/dsh-thinking-slider-liang
```

从系统托盘完全退出 DSH 再打开。点输入框左下角的模型名，滑杆里的档位就是中文名了。

## 效果

- 触发器：`deepseek-flash · 梁圣`
- 卡片大字档位、滑轨刻度：小难梁 / 梁子 / 梁圣 / 梁祖
- **实际发给 API 的仍是 `off / low / high / max`**，计费与能力不受影响

| 显示名 | 实际档位 |
| --- | --- |
| 小难梁 | `off` |
| 梁子 | `low` |
| 梁圣 | `high` |
| 梁祖 | `max` |

> 上游还有另一种六段映射（两个模型 × 三档：小难梁 / 牢梁 / 梁子 / 梁圣 / 梁神 / 梁祖），见 [BruzWJ/Liang-Saint-Slider](https://github.com/BruzWJ/Liang-Saint-Slider)。这里用四档版本，因为桌面端默认只挂 `deepseek-flash` 一个模型。

## 为什么不直接装上游

上游 [dsh-thinking-slider](https://github.com/MuFeng262/dsh-thinking-slider) 能用，但档位名直接照搬适配器给的 `Off / Low / High / Max`——它是刻意数据驱动的，没有改名配置。

社区里另一个更花哨的版本 [BruzWJ/Liang-Saint-Slider](https://github.com/BruzWJ/Liang-Saint-Slider) 有中文名，但**在桌面发行版上静默失效**：它的浏览器端第一行就 `require("@deepseek-ai/dsh-client-ui-primitives")`。这个包确实发布在 npm 上（`0.2.1-rc.2`），但没被打进桌面版的 `app.asar`。DSH 的客户端模块表是冻结的，表里没有的模块会让整个模块工厂函数抛异常，插件在浏览器里静默不注册——宿主那半照常工作（静态资源路由还能返回 200），于是表现成「装上了、没界面」。

所以这个仓库的做法是：**以上游 0.3.3 的构建产物为基础，只替换渲染层的档位名**。上游只依赖 `react` / `react-dom` / `react/jsx-runtime`，这三个内置 UI 自己也在用，所以在发行版上能跑。

## 包结构

```
package.json         dsh.bundle + dsh.client 声明
cordis.patch.yml     插入插件行
lib/index.js         Host 半（空实现）
lib/client.js        浏览器半：上游 0.3.3 产物 + 档位名映射
scripts/sync-upstream.mjs
```

`lib/client.js` 是上游构建产物（MIT）的副本，只改了一处。详见 [NOTICE](NOTICE)。

## 跟进上游

上游发新版时，不需要手工改代码：

```powershell
node scripts/sync-upstream.mjs 0.3.4
```

脚本会从 unpkg 拉取新产物、校验锚点行存在、注入映射、写出 `lib/client.js`，并打印 sha256。上游若改动了那段代码结构，脚本会直接报错而不是产出坏包——那时候改一下锚点即可（`scripts/sync-upstream.mjs` 顶部）。

改完把 `package.json` 的版本改成 `<上游版本>-liang.N`，提交推送。**从 GitHub 安装的插件不会自动更新**，重新执行一次 `dsh plugin ... add` 或先 `remove` 再 `add` 即可。

## 已验证

- DSH Desktop `0.2.1-rc.2`，Windows 11，2026-10-18
- 上游 `dsh-thinking-slider@0.3.3`
- 客户端产物 `node --check` 通过；档位切换真实写入 `reasoningEffort`

## 已知限制

- 模型列表里每行的小圆点标题（悬停 tooltip）仍走另一条代码路径，还是英文；主界面可见的档位名都已替换
- 这是构建产物副本，上游改版后需要跑一次同步脚本
- 与上游插件**不能同时装**：两者都占 `conversation.input.model` 座位，只是优先级不同，会导致行为难以预期

## 卸载

```powershell
dsh plugin --profile desktop remove dsh-thinking-slider-liang
```

## 许可

MIT。上游插件与其中大部分代码归 [MuFeng262](https://github.com/MuFeng262/dsh-thinking-slider) 所有，本仓库仅做显示名替换与发行版兼容性验证。
