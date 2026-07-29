# 根因与修复索引

| 根因类别 | 典型失败 | 当前修复 | 主要文件 |
|---|---|---|---|
| 坐标与投影契约 | 屏幕固定、飞行不可见、终点闪烁 | 浮点世界坐标为权威，每帧重新投影，镜头偏移只扣一次 | `XNP_DR_GreenSmoothVisual.lua` |
| 可见性与伤害提交分裂 | 无画面伤害、首帧冲击被终止 | 视觉事务先于伤害；绘制证明缺失为诊断，视觉创建失败才中止 | `XNP_DR_GreenWorldOrb.lua` |
| 出生碰撞分类缺失 | 发射比例零立即爆炸 | 发射时捕获重叠僵尸，武装并安全移动后解除临时忽略 | `XNP_DR_GreenWorldOrb.lua` |
| 单槽状态所有权 | 多弹互相覆盖 | 玩家/cast 双索引，资源按 cast ID 拥有 | `XNP_DR_GreenWorldOrb.lua` |
| 非幂等清理 | `unregisterCast` nil、双清理 | finally 清理、双身份检查、重复调用直接返回 | `XNP_DR_GreenWorldOrb.lua` |
| 原生灯光空间索引 | 灯光停在发射点 | 跨格创建并注册新光源，成功后移除旧光 | `XNP_DR_GreenWorldLight.lua` |
| enum 存储语义误读 | 2 FPS / 2 Hz | 直接整数范围与旧索引确定性迁移 | `XNP_DR_SandboxSchema.lua`、`XNP_DR_SandboxTuning.lua` |
| 不一致的速度上限 | 12 被 8 截断 | 目标速度与虚拟硬上限默认统一为 12 | `XNP_DR_GreenWorldOrb.lua` |
| 全局粘滞身份失败 | 紫色写入暂停、全系统冻结 | 事务级拒绝；受控槽对象精确相等；一次性清理旧键 | `XNP_DR_CanonicalPlayerIdentity.lua` |
| 状态/UI/音效所有权分裂 | 黄色只响音效、白色被覆盖 | 单一状态所有者，提交与回读后播放音效 | `XNP_DR_MasterEffectState.lua` |
| 旧死亡对象拥有玩家槽 | 新角色重绑阻断 | tombstone 前任加三帧受控槽确认 | `XNP_DR_Bootstrap.lua` |
| 制作步骤非原子化 | P 点情绪重复或失败后残留 | 物品确认后写成本与情绪，失败完整回滚，完成回调幂等 | `XNP_DR_RedGuardianMark.lua` |

