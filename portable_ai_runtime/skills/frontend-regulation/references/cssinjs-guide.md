# CSS-in-JS 在 Ant Design Pro 中的应用

## 1. DefaultSettings.ts — 配置 proLayout 的 token

配置 Layout token，包含侧边栏 Sider Token、头部 Header Token、页面容器 PageContainer Token：

```ts
// DefaultSettings.ts
token: {
  bgLayout: '#fff',
  sider: {
    // 侧边栏样式 token
  },
  header: {
    // 头部样式 token
  },
  pageContainer: {
    // 页面容器样式 token
  },
}
```

参考文档：https://procomponents.ant.design/components/layout#通过-token-修改样式

## 2. config.ts — 全局主题配置

在 `config.ts` 中配置 `antd` 主题：

```ts
// config.ts
antd: {
  theme: {
    // 全局 token
    token: {
      borderRadius: 20,
      fontFamily: 'source-serif-pro, "Helvetica Neue", Helvetica, Georgia, Cambria, "Times New Roman", Times, Arial, Microsoft JhengHei, serif',
      fontSize: 22,
      controlHeight: 35,
      // 可在此自定义项目级 token
    },
    // 按组件定制
    components: {
      Button: {
        colorPrimary: '#00b96b',
        borderRadius: 5,
        algorithm: true,
      },
    },
  },
},
```

可配置属性参考：https://ant-design.antgroup.com/docs/react/customize-theme-cn

## 3. 局部主题覆盖 — ConfigProvider

单独配置某个区域的样式：

```tsx
import { ConfigProvider, Input, Button, Space } from 'antd';

<ConfigProvider
  theme={{
    token: {
      borderRadius: 20,
    },
  }}
>
  <Space>
    <Input placeholder="Please Input" />
    <Button type="primary">Submit</Button>
  </Space>
</ConfigProvider>
```

## 4. Class 样式写法 — createStyles

使用 `antd-style` 的 `createStyles`：

```ts
// style.ts
import { createStyles } from 'antd-style';

const useStyles = createStyles(({ token }) => {
  return {
    histroylist: {
      width: '220px',
      height: '40px',
      fontSize: token.fontSize,
      lineHeight: '40px',
      marginLeft: '25px',
      marginTop: '10px',
      // 嵌套选择器
      '.ant-input': {
        padding: '10px 11px 4px',
      },
    },
  };
});

export default useStyles;
```

在 tsx 中使用：

```tsx
// component.tsx
import useStyles from './style';

const { styles } = useStyles();

<div className={styles.histroylist}>
  {/* content */}
</div>
```

## 5. tsx 中直接使用 Design Token

```tsx
import { theme } from 'antd';

const { useToken } = theme;
const { token } = useToken();

<div
  style={{
    fontSize: token.fontSize,
  }}
>
  使用 Design Token
</div>
```

## 6. 关键原则

- **用 token 管理公共变量**：字体、字号、颜色、圆角等统一通过 token 配置
- **避免样式污染**：`createStyles` 生成的 className 自动 hash，天然隔离
- **全局 vs 局部**：全局主题在 `config.ts`，布局在 `DefaultSettings.ts`，局部用 `createStyles` 或 `ConfigProvider`
- **优先使用 Design Token**：不要硬编码像素值，优先从 `token` 取值
