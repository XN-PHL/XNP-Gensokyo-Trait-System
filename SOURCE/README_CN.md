# XNP 幻想乡特质系统 V2 2.3.0-test.1

这是 Project Zomboid Build 42.20 的独立测试通道。

- Mod ID：`XNP_PZ_DistanceRunnerTrait_Test`
- 内部版本：`2.3.0-test.1-multi-record-inheritance-a`
- Build Marker：`XNP_V2_230_TEST1_MULTI_RECORD_INHERITANCE_A`
- 测试 Workshop ID：`3762431102`
- 互斥稳定通道：`XNP_PZ_DistanceRunnerTrait`
- 实机状态：`NOT_TESTED`

本测试版新增由世界 ModData 保存、按角色归属隔离的多条残机继承记录库。每次成功的初始、手动或自动记录都会生成新的不可变记录 ID；显示名可改，记录保存职业、规范化特质对象、快照和规范化内容摘要。恢复严格使用已选择的记录 ID：清空当前 CharacterTraits，精确写入所选记录的规范对象并读取验证；除体能和力量外，只补足正向技能经验差的四分之一。启动时只迁移和去重，不会自动恢复任何记录。仍需用户实机验收，请勿与稳定版同时启用。
