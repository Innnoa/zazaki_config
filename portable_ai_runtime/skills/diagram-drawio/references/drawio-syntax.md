# drawio XML 语法速查

diagrams.net(draw.io)源文件是 XML,扩展名 `.drawio`。AI 直接写 XML 即可生成图表,无需 GUI。

## 1. 文件骨架(最小结构)

```xml
<mxfile host="app.diagrams.net">
  <diagram id="d1" name="Page-1">
    <mxGraphModel dx="800" dy="600" grid="1" gridSize="10"
                  guides="1" tooltips="1" connect="1" arrows="1"
                  fold="1" page="1" pageScale="1" pageWidth="850"
                  pageHeight="1100" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <!-- 业务节点/连线都放这里,parent="1" -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

- `id="0"` 和 `id="1"` 是保留单元格(根),不要删除
- 所有业务元素 `parent="1"`,否则不显示
- `dx/dy` 影响缩放显示,`pageWidth/pageHeight` 决定画布尺寸

## 2. 节点(vertex)

```xml
<mxCell id="n2" value="节点文字" style="rounded=1;whiteSpace=wrap;html=1;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry" />
</mxCell>
```

- `vertex="1"` 标记为节点,`edge="1"` 标记为连线
- `mxGeometry` 用绝对坐标定位(`as="geometry"` 必写)
- `value` 为显示文字;换行用 `&#10;`

## 3. 连线(edge)

```xml
<mxCell id="e1" style="edgeStyle=orthogonalEdgeStyle;rounded=0;"
        edge="1" parent="1" source="n2" target="n3">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- `source` / `target` 指向节点 id
- `relative="1"` 是连线几何的标准写法(不写绝对坐标)
- 连线必须两端都连上节点,否则可能不显示
- 常用连线样式: `edgeStyle=orthogonalEdgeStyle`(直角)、`edgeStyle=entityRelationEdgeStyle`(ER 关系)、`dashed=1`(虚线)、`endArrow=block`(箭头)、`html=1`(文字)

## 4. 常用样式 key 速查

| key | 值示例 | 作用 |
|---|---|---|
| `rounded` | 0/1 | 圆角 |
| `whiteSpace` | wrap | 文字换行 |
| `html` | 1 | 富文本(中文/换行必开) |
| `verticalAlign` | top/middle/bottom | 文字垂直对齐 |
| `align` | left/center/right | 文字水平对齐 |
| `fillColor` | #f8cecc / #dae8fc / #d5e8d4 | 填充色 |
| `strokeColor` | #b85450 | 边框色 |
| `fontSize` | 12 | 字号 |
| `fontColor` | #000000 | 文字色 |
| `dashed` | 0/1 | 虚线 |
| `container` | 1 | 容器(可放子节点) |
| `swimlane` | 1 | 泳道 |
| `childLayout` | stackLayout | 子节点自动堆叠 |
| `horizontal` | 0/1 | 泳道方向(0=垂直) |
| `startSize` | 30 | 泳道标题区高度 |
| `shape` | process/parallelogram/diamond/hexagon 等 | 形状 |

配色惯例(drawio 默认调色板): 红 `#f8cecc`/`#b85450`,蓝 `#dae8fc`/`#6c8ebf`,绿 `#d5e8d4`/`#82b366`,黄 `#fff2cc`/`#d6b656`,紫 `#e1d5e7`/`#9673a6`。

## 5. 容器与泳道

```xml
<!-- 泳道: 垂直泳道,子节点相对坐标 -->
<mxCell id="lane1" value="阶段A" style="swimlane;horizontal=0;startSize=30;fillColor=#dae8fc;"
        vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="200" height="320" as="geometry" />
</mxCell>
<!-- 泳道内节点: parent=泳道id, 坐标相对泳道 -->
<mxCell id="s1" value="步骤1" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="lane1">
  <mxGeometry x="20" y="40" width="160" height="50" as="geometry" />
</mxCell>
```

- 容器/泳道内子节点 `parent` 指向容器 id,坐标是相对容器的
- 泳道常配 `fillColor` 区分区域;跨泳道连线照常 `source/target`

## 6. 时序图元素

```xml
<!-- 生命线(参与者): 用特殊样式 -->
<mxCell id="actor1" value="Client" style="shape=umlLifeline;perimeter=orthogonalPerimeter;whiteSpace=wrap;html=1;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="40" width="100" height="320" as="geometry" />
</mxCell>
<!-- 消息箭头: activate=1 显示激活条 -->
<mxCell id="m1" value="request()" style="edgeStyle=orthogonalEdgeStyle;html=1;endArrow=block;"
        edge="1" parent="1" source="actor1" target="actor2">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- 时序图常直接竖向排列 actor,消息用横向连线;`umlLifeline` 自动画生命线
- 高度(height)拉长做生命线长度;多条消息用不同 y 偏移

## 7. ER 图元素

```xml
<!-- 实体表: 容器 + 标题行 -->
<mxCell id="t1" value="users" style="shape=table;startSize=30;html=1;whiteSpace=wrap;"
        vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="180" height="120" as="geometry" />
</mxCell>
<mxCell id="t1c1" value="id INT" style="shape=tableRow;horizontal=0;html=1;whiteSpace=wrap;" vertex="1" parent="t1">
  <mxGeometry y="30" width="180" height="30" as="geometry" />
</mxCell>
<mxCell id="t1c2" value="name VARCHAR" style="shape=tableRow;horizontal=0;html=1;whiteSpace=wrap;" vertex="1" parent="t1">
  <mxGeometry y="60" width="180" height="30" as="geometry" />
</mxCell>
<!-- 关系: entityRelationEdgeStyle -->
<mxCell id="r1" style="edgeStyle=entityRelationEdgeStyle;html=1;fontSize=12;"
        edge="1" parent="1" source="t1" target="t2">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- 表用 `shape=table` 容器,行用 `shape=tableRow`,`mxGeometry` 只有 `y` 和 `width`(行自动铺满表宽)
- 关系线用 `entityRelationEdgeStyle`(拐弯带标签),可在 `value` 写基数如 `1..*`

## 8. 思维导图/树

```xml
<!-- 中心主题 -->
<mxCell id="c0" value="主题" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;fontSize=16;"
        vertex="1" parent="1">
  <mxGeometry x="300" y="200" width="120" height="60" as="geometry" />
</mxCell>
<!-- 分支: 节点 + 连线,树形展开 -->
<mxCell id="b1" value="分支1" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1">
  <mxGeometry x="500" y="100" width="100" height="50" as="geometry" />
</mxCell>
<mxCell id="be1" style="edgeStyle=orthogonalEdgeStyle;html=1;rounded=0;" edge="1" parent="1" source="c0" target="b1">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- 树形图核心是手工算好各节点坐标(中心向两侧/向下展开)
- 保持同一层 y 对齐、左右对称,观感最好

## 9. 常见坑

1. **`as="geometry"` 漏写** → 节点没有位置,不显示
2. **edge 没有 `relative="1"`** → 连线几何异常或消失
3. **中文乱码** → 节点样式必须有 `html=1`,且 XML 文件用 UTF-8 保存
4. **子节点坐标** → 容器内子节点坐标是相对的(从容器原点算),不是画布绝对坐标
5. **id 冲突/重复** → 所有 `id` 必须全局唯一;删除节点时同步删连到它的 edge,否则悬空线
6. **泳道内外混淆** → 跨泳道节点不要把 parent 设成泳道,除非确实要放进去
7. **连线方向** → `source`/`target` 决定箭头方向,`endArrow=none` 可去掉箭头

## 10. 渲染命令(WSL → Windows drawio)

```bash
DRAWIO="/mnt/c/Users/hzj/AppData/Local/Programs/draw.io/draw.io.exe"
"$DRAWIO" --export --format png --output out.png input.drawio
```

- 路径探测: `render.sh` 脚本已封装(见 `skills/diagram-drawio/scripts/render.sh`)
- 候选路径(按优先级): 用户级安装 `C:\Users\<user>\AppData\Local\Programs\draw.io\draw.io.exe` → 系统级 `C:\Program Files\draw.io\draw.io.exe` → `command -v drawio`
- 实测: WSL 内直接调用 Windows exe 可行,Electron 无头导出正常
- 其他格式: `--format svg` / `--format pdf` 同理可换
