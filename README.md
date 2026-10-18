# dsh-thinking-slider-liang

给 **DSH 桌面发行版**用的一个两行补丁：把思考档位滑杆的档位名改成「小难梁 / 梁子 / 梁圣 / 梁祖」。

本来只是个乐子，但过程中踩到一个发行版独有的坑，所以单独记下来。

## 为什么需要这个仓库

社区里流行的两个「滑动变阻器」插件，在**桌面发行版**上表现不同：

| 插件 | 运行情况 |
| --- | --- |
| [BruzWJ/Liang-Saint-Slider](https://github.com/BruzWJ/Liang-Saint-Slider)（`dsh-plugin-liang-calibrator`） | **静默失效** |
| [dsh-thinking-slider](https://www.npmjs.com/package/dsh-thinking-slider)（MuFeng262） | 正常，但档位名是英文 |

前者的浏览器端代码第一行就 `require("@deepseek-ai/dsh-client-ui-primitives")`。这个包确实发布在 npm 上（`0.2.1-rc.2`），但**没有被打进桌面版的 `app.asar`**。DSH 的客户端模块表是冻结的，表里没有的模块会让整个模块工厂函数抛异常，插件在浏览器里静默不注册——宿主那半照常工作（静态资源路由正常返回 200），于是表现成「装上了、没界面」。

后者只依赖 `react` / `react-dom`，这两个内置 UI 自己也在用，所以在发行版上能跑。代价是它坚持数据驱动、不写死档位名，直接照搬适配器给的 `Off / Low / High / Max`。

这个仓库就是把后者钉在 `0.3.3`，加一个只改显示名的补丁。

## 效果

- 触发器：`deepseek-flash · 梁圣`
- 卡片大字档位、滑轨刻度：小难梁 / 梁子 / 梁圣 / 梁祖
- **实际发给 API 的仍是 `off / low / high / max`**，计费与能力不受影响

映射：

| 显示名 | 实际档位 |
| --- | --- |
| 小难梁 | `off` |
| 梁子 | `low` |
| 梁圣 | `high` |
| 梁祖 | `max` |

> 另一种六段映射（两个模型 × 三档，小难梁 / 牢梁 / 梁子 / 梁圣 / 梁神 / 梁祖）见 BruzWJ 那个仓库的 README。这里用的是四档版本，因为桌面端默认只挂 `deepseek-flash` 一个模型。

## 安装

```powershell
pwsh -File scripts/install.ps1 -Profile desktop
```

脚本做三件事：把这版插件装进 profile、把补丁打到 `lib/client.js`、提示你重启。

然后**从托盘完全退出 DSH 再打开**（客户端模块按启动时扫描，热更新不生效）。

### 手动安装

```powershell
dsh plugin --profile desktop add dsh-thinking-slider@0.3.3

cd "$env:USERPROFILE\.dsh\profiles\desktop\node_modules\dsh-thinking-slider"
git apply -p1 "path\to\patches\liang-level-names.patch"
```

## 卸载 / 回退

```powershell
pwsh -File scripts/revert.ps1 -Profile desktop
```

它只反向应用补丁，恢复成官方的英文档位名。想彻底移除插件用 `dsh plugin --profile desktop remove dsh-thinking-slider`。

## 已验证环境

- DSH Desktop `0.2.1-rc.2`，Windows 11，2026-10-18
- `dsh-thinking-slider@0.3.3`
- 补丁只在这一版上验证过；插件升级后 `client.js` 变长变短，hunk 大概率打不上，需要重做

## 已知限制

- 模型列表里每行的小圆点标题（悬停 tooltip）仍走另一条代码路径，还是英文；主界面可见的档位名都已替换
- 这是对 `node_modules` 里文件的本地补丁，`dsh plugin ... install` 重装依赖会覆盖，需要重新应用

## 许可

MIT。上游插件归 [MuFeng262](https://github.com/MuFeng262/dsh-thinking-slider) 所有，本仓库只包含一个补丁和安装脚本，不复制上游代码。
