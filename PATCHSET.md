# PATCHSET · 我们的补丁台账（fork `later-3/Strata`）

> 分支模型：`upstream/main`（只读） · `ours/main`（我们的集成 = upstream/main + patchset） · `patch/pr-<n>`（每个候选补丁单独一条）
> 基线：**v0.1.43**（`16374b3e`，上游 tag）· 我们的集成分支：`ours/main` @ `bdbc356b`
> 维护纪律：**一个 PR 一次只合一个**，每个都跑 `verify.sh`；冲突解决写进本表"我们的改动"列。

## 1. 已进我们集成分支的补丁

| PR | 标题 | 分类 | 我们为什么需要 | 影响文件 | 我们的改动 | 验收证据 | 上游状态 | 丢弃判据 |
|---|---|---|---|---|---|---|---|---|
| [#1744](https://github.com/Niko1221/Strata/pull/1744) | CUDA SM86: opt-in IQ3 two-stage prefill build | 性能(sm86) | 3090(sm_86) 的 IQ3 两阶段 prefill；我们生产在用（`STRATA_PF_IQ3_STAGE2=1`） | `setup.py`、`src/prefill/cuda/moe_fused_iq_stage2_sm86.cu`(新)、`src/prefill/cuda/native_fused_iq_sm86.cuh`(新)、`tools/test_cuda_prefill_variant.py`(新)、`tools/test_setup_sm86_prefill.py`(新)、`docs/INSTALL_SM86_PREFILL.md`(新) | rebase 到 v0.1.43；`setup.py` 一处冲突已解（保留上游 `*host_compiler_defs(True)` + 我们的 `*sm86_build_defs(sm86_prefill)`） | ⏳ 待跑 `verify.sh`（需用户批准） | open（head 未变） | 上游合并进 main 后 |

## 2. 候选补丁（按优先级，未合入）

| 优先级 | PR | 标题 | 分类 | 与我们痛点的对应 | 状态 | 备注 |
|---|---|---|---|---|---|---|
| **P1** | [#2119](https://github.com/Niko1221/Strata/pull/2119) + [#2098](https://github.com/Niko1221/Strata/pull/2098) + [#2082](https://github.com/Niko1221/Strata/pull/2082) | 磁盘版会话停放（`--conversation-cache-storage disk`）+ 停放准入安全化 | 稳定性/内存 | **直击我们的 RAM/swap 痛点**（大会话停放从内存搬到磁盘）→ 可能免去加内存 | open（作者在 RTX 3090 上开发，有 bench） | 优先评估 |
| **P2** | [#2077](https://github.com/Niko1221/Strata/pull/2077) | `--prompt-cache-file`：长提示前缀落盘并可恢复 | 性能/内存 | 新会话"重读长系统提示"（我们记录的 A5 疑点），不吃 RAM | open | 与 #2119 同思路 |
| **P3** | [#1808](https://github.com/Niko1221/Strata/pull/1808) | `max_queue`：队列上限 → 429 + Retry-After | 运维 | 多会话/过载保护（我们多会话时"排队"更可控） | open（head 已更新 `363a4b8`） | 需重新 fetch |
| **P4** | [#1803](https://github.com/Niko1221/Strata/pull/1803) | 重复短语守卫（`repeat_stop_period`） | 稳定性 | 长思考时的重复退化兜底 | open（head 已更新 `1f75140`） | 需重新 fetch |
| **P5** | [#1806](https://github.com/Niko1221/Strata/pull/1806) | `user_args`：保留用户自定义引擎参数 | 运维 | 我们手改 args 的运维友好性 | open（head 已更新 `88a5f83`） | 需重新 fetch |
| **P6** | [#1704](https://github.com/Niko1221/Strata/pull/1704) | 主动层缓存（+7% prefill，H2D 减半） | 性能(sm86) | prefill 提速 | open（head 已更新 `f2fedfd`） | 我们记为 A4，暂缓 |
| P7 | [#2050](https://github.com/Niko1221/Strata/pull/2050) / [#2109](https://github.com/Niko1221/Strata/pull/2109) | batch-groups 冷启动不阻塞 / `--batch` 请求优先级 | 多会话 | 多会话交互体验 | open | 视需要 |
| P8 | [#2039](https://github.com/Niko1221/Strata/pull/2039) / [#2057](https://github.com/Niko1221/Strata/pull/2057) | 保留字面 `</tool_call>` / `stream_all_tool_args` | Agent/工具 | 与 Pi 的工具调用直接相关 | open | 视需要 |
| P9 | [#1822](https://github.com/Niko1221/Strata/pull/1822) | gate/up MMQ 原地读专家 | 性能 | prefill 提速（另需补丁 llama.cpp） | open（head 未变） | 依赖重 |

## 3. 明确丢弃

| PR | 原因 |
|---|---|
| [#1825](https://github.com/Niko1221/Strata/pull/1825) | **sm_75（Turing）专用**，我们是 sm_86，无收益 |
| [#1801](https://github.com/Niko1221/Strata/pull/1801) | 上游已 **closed（未合并）**，不再维护 |
| sm_75 / SYCL / Arc / Windows ARM / 社区 bench 类 PR | 平台无关或纯文档 |

## 4. 只读参考（不进补丁集）

| PR | 用途 |
|---|---|
| [#2030](https://github.com/Niko1221/Strata/pull/2030) | RX 9060 XT 16GB · Flash-Next IQ3_S **@262K** · 0.1.43 → 262K 的实测参考 |
| [#2024](https://github.com/Niko1221/Strata/pull/2024) | **0.1.42 vs 0.1.43** 交错 A/B（agent 场景）→ 判断我们是否该跟 0.1.43 |
| [#2083](https://github.com/Niko1221/Strata/pull/2083) | **不等分双卡层切分**（5060Ti 16GB + 3060 12GB）→ 回答"加小卡行不行" |
| [#2086](https://github.com/Niko1221/Strata/pull/2086) / [#2087](https://github.com/Niko1221/Strata/pull/2087) | 3090 层切分 / 3090 + Flash-Next 数据 |


## 5. 试合结果与测试优先级（2026-10-12 晚，基线 `ours/main` = v0.1.43 + #1744）

| PR | 规模 | 试合 | 分类 | 结论 |
|---|---|---|---|---|
| **#2119** 磁盘版会话停放（`--conversation-cache-storage disk`） | 9 文件 +964/−15 | ✅ **干净** | 稳定性/内存 | **P1 先测**：直击我们 RAM/swap 根因 |
| **#2077** `--prompt-cache-file` 长前缀落盘 | 7 文件 +1536/−15 | ✅ **干净** | 性能/内存 | P2：解决"新会话重读长系统提示" |
| **#1808** `max_queue` → 429 + Retry-After | 4 文件 +377/−7 | ✅ **干净** | 运维 | P2：多会话排队可控 |
| **#1806** `user_args`（保留用户引擎参数） | 6 文件 +85/−9 | ✅ **干净** | 运维 | P3 |
| **#2082** 停放准入安全化 + 测试系列 | 9 文件 +1174/−35 | ⚠️ 冲突（`AGENTS.md`、`LOCAL-PARKING-PATCH-0.1.43.md`、`src/core/conversation_cache_test.cpp`） | 稳定性 | P2：与 #2119 **同主题但独立分支**；必要时只 cherry-pick 其代码提交 |
| **#1803** 重复短语守卫 | 68 文件（含无关） | ⚠️ 冲突（`docs/DETAILS.md`） | 稳定性 | P3：分支基线偏离，需按提交逐个 cherry-pick |
| **#1704** 主动层缓存（+7% prefill） | 23 文件 +47646（含 bench 数据） | ⚠️ 冲突 | 性能(sm86) | P4：**已 rebase 到 v0.1.43**，但体积大、需手工 |
| **#1822** MMQ 原地读专家 | — | — | 性能 | ❌ **我们已实测无收益（−1.7~−2.7%）→ 丢弃** |
| **#1825** qsa_select 四通路 | — | — | 平台 | ❌ **sm_75 专用，我们 sm_86 → 丢弃** |
| **#2098** 磁盘停放 bench（RTX 3090 + 68 GB RAM） | 39 文件 +10753 | — | 只读参考 | 📖 数据参考，不进补丁集 |

**测试顺序（每个都跑 `verify.sh`，一个通过再上下一个）**：
`#2119` → `#2082` → `#2077` → `#1808` → `#1806` → `#1704`

**已丢弃的分支清理**：`patch/pr-1801`（上游已 closed）已从 fork 删除。
