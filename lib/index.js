/**
 * dsh-thinking-slider-liang — host half.
 *
 * 插件完全是浏览器侧的：它把 composer 的模型座位换成思考档位滑杆。
 * Host 侧只需要让这一行存在，组合树才会去加载 package.json 里
 * `dsh.client` 声明的 `./client`。不贡献任何 Host 服务或配置。
 */
export const name = 'dsh-thinking-slider-liang'

/** 不需要任何 Host 能力。 */
export const inject = []

/** Host 半是空实现。 */
export function apply() {}
