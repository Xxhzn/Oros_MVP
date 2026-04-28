class_name UIBattleEventNames

#region --- UI总控与基础事件 ---
## 战斗 UI 总控事件
# 重置整个战斗 UI 到默认状态。
const UI_RESET := "ui/battle/reset"
#endregion

#region --- 菜单事件与菜单配置 ---
## 菜单显示与关闭事件
# 显示一个战斗菜单。
const MENU_SHOW := "ui/battle/menu/show"
# 隐藏一个战斗菜单。
const MENU_HIDE := "ui/battle/menu/hide"
# 玩家点击了某个菜单项。
const MENU_ITEM_SELECTED := "ui/battle/menu/item_selected"
# 当前菜单流程被关闭。
const MENU_CLOSED := "ui/battle/menu/closed"

## 行动顺序条事件
# 设置整条行动顺序数据。
const TURN_ORDER_SET := "ui/battle/turn_order/set"
# 清空行动顺序条。
const TURN_ORDER_CLEAR := "ui/battle/turn_order/clear"
# 高亮某个行动顺序项。
const TURN_ORDER_HIGHLIGHT := "ui/battle/turn_order/highlight"
#endregion

#region --- 战斗日志 ---
## 战斗日志事件
# 追加一条战斗日志。
const LOG_APPEND := "ui/battle/log/append"
# 清空战斗日志。
const LOG_CLEAR := "ui/battle/log/clear"

## 战斗日志显示类型
# 伤害类日志颜色。
const LOG_TYPE_DAMAGE := "damage"
# 技能类日志颜色。
const LOG_TYPE_SKILL := "skill"
# 状态类日志颜色。
const LOG_TYPE_STATUS := "status"
# 死亡类日志颜色。
const LOG_TYPE_DEATH := "death"

## 战斗日志语义键
# 回合开始。
const LOG_KEY_TURN_START := "turn_start"
# 技能施放。
const LOG_KEY_SKILL_CAST := "skill_cast"
# 造成伤害。
const LOG_KEY_DAMAGE := "damage"
# 恢复生命。
const LOG_KEY_HEAL := "heal"
# 获得状态。
const LOG_KEY_STATUS_GAIN := "status_gain"
# 移除状态。
const LOG_KEY_STATUS_REMOVE := "status_remove"
# 获得护盾。
const LOG_KEY_SHIELD_GAIN := "shield_gain"
# 单位死亡。
const LOG_KEY_DEATH := "death"
# 触发联动。
const LOG_KEY_SYNERGY_TRIGGER := "synergy_trigger"
# 获得回声碎片。
const LOG_KEY_ECHO_GAIN := "echo_gain"
# 消耗回声碎片。
const LOG_KEY_ECHO_USE := "echo_use"
# 行动顺序延后。
const LOG_KEY_TURN_DELAY := "turn_delay"
#endregion

#region --- 玩家HUD与状态栈 ---
## 玩家 HUD 事件
# 刷新左下角玩家状态栏。
const PLAYER_HUD_SET := "ui/battle/player_hud/set"
# 隐藏左下角玩家状态栏。
const PLAYER_HUD_HIDE := "ui/battle/player_hud/hide"

## 单位悬浮状态栈事件
# 设置某个单位的悬浮状态列表。
const STATUS_STACK_SET := "ui/battle/status_stack/set"
# 移除某个单位的悬浮状态列表。
const STATUS_STACK_REMOVE := "ui/battle/status_stack/remove"
#endregion

#region --- 菜单扩展配置 ---
## 菜单模式定义
# 器灵选择菜单。
const MENU_MODE_SPIRIT_SELECT := "spirit_select"
# 技能选择菜单。
const MENU_MODE_SKILL_SELECT := "skill_select"
# 一级行动菜单。
const MENU_MODE_TOP_LEVEL_SELECT := "top_level_select"

## 回声槽状态定义
# 回声槽为空。
const MENU_SLOT_STATE_EMPTY := "empty"
# 回声槽已插入。
const MENU_SLOT_STATE_FILLED := "filled"
# 回声碎片不足。
const MENU_SLOT_STATE_NO_FRAGMENT := "no_fragment"
# 当前槽位不可用。
const MENU_SLOT_STATE_UNAVAILABLE := "unavailable"

## 菜单 ID 定义
# 器灵选择菜单 ID。
const MENU_ID_SPIRIT_SELECT := "spirit_select_menu"
# 技能选择菜单 ID。
const MENU_ID_SKILL_SELECT := "skill_select_menu"
# 一级行动菜单 ID。
const MENU_ID_TOP_LEVEL_SELECT := "top_level_select_menu"

## 菜单项元数据键
# 器灵菜单项对应的器灵 ID。
const MENU_META_SPIRIT_ID := "spirit_id"
# 技能菜单项对应的技能索引。
const MENU_META_ABILITY_INDEX := "ability_index"
# 回声顺序确认后写回的顺序键。
const MENU_META_ORDER_KEY := "order_key"

## 一级菜单固定项 ID
# 普通攻击入口。
const MENU_ITEM_BASIC_ATTACK := "basic_attack"
# 器灵技能入口。
const MENU_ITEM_SPIRIT_SKILL := "spirit_skill"
# 逃跑入口。
const MENU_ITEM_ESCAPE := "escape"

## 菜单上下文字段
# 当前已选器灵 ID。
const MENU_CONTEXT_SELECTED_SPIRIT_ID := "selected_spirit_id"

## 菜单项种类
# 一级菜单项。
const MENU_ITEM_KIND_TOP_LEVEL := "top_level"
# 技能菜单项。
const MENU_ITEM_KIND_SKILL := "skill"

## 菜单扩展交互事件
# 点击技能项右侧回声槽块。
const MENU_SLOT_CLICKED := "ui/battle/menu/slot_clicked"
# 顺序弹窗确认完成。
const MENU_SEQUENCE_CONFIRMED := "ui/battle/menu/sequence_confirmed"
#endregion

#region --- 目标选择 ---
## 目标选择阶段事件
# 进入目标选择阶段。
const TARGET_OVERLAY_SHOW := "ui/battle/target_overlay/show"
# 退出目标选择阶段。
const TARGET_OVERLAY_HIDE := "ui/battle/target_overlay/hide"
# 玩家确认了目标。
const TARGET_SELECTED := "ui/battle/target_overlay/selected"
# 玩家取消了目标选择。
const TARGET_SELECTION_CANCELED := "ui/battle/target_overlay/canceled"

## 目标选择阶段 payload 字段
# 提示文字。
const TARGET_KEY_HINT_TEXT := "hint_text"
# 当前发起行动的单位 ID。
const TARGET_KEY_SOURCE_UNIT_ID := "source_unit_id"
# 当前允许选择的目标 ID 列表。
const TARGET_KEY_CANDIDATE_IDS := "candidate_target_ids"
# 最终确认的目标 ID。
const TARGET_KEY_TARGET_ID := "target_id"
# 本次行动的完整上下文。
const TARGET_KEY_ACTION_CONTEXT := "action_context"
# 当前是否允许取消目标选择。
const TARGET_KEY_ALLOW_CANCEL := "allow_cancel"
#endregion

#region --- 行动上下文 ---
## 行动上下文字段
# 当前选中的器灵 ID。
const ACTION_CONTEXT_SPIRIT_ID := "selected_spirit_id"
# 一级菜单选择结果。
const ACTION_CONTEXT_TOP_LEVEL_ITEM_ID := "top_level_item_id"
# 当前技能索引。
const ACTION_CONTEXT_ABILITY_INDEX := "ability_index"
# 当前是否使用回声。
const ACTION_CONTEXT_USE_ECHO := "use_echo"
# 当前回声施放顺序。
const ACTION_CONTEXT_ORDER_KEY := "order_key"
# 当前是否为普通攻击路径。
const ACTION_CONTEXT_IS_BASIC_ATTACK := "is_basic_attack"

## 返回上一步控制字段
# 目标选择取消后应返回的菜单阶段。
const ACTION_CONTEXT_RETURN_STAGE := "return_stage"
# 返回一级菜单。
const ACTION_CONTEXT_RETURN_STAGE_TOP_LEVEL := "top_level"
# 返回技能菜单。
const ACTION_CONTEXT_RETURN_STAGE_SKILL_SELECT := "skill_select"
#endregion
