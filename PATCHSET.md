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


## 6. 构建须知（2026-10-12 实测踩坑，务必照抄）

```bash
# 用 worktree 隔离，绝不动生产工作区 ~/src/strata（生产服务从那里跑）
git worktree add ~/src/strata-v0143 ours/main
cd ~/src/strata-v0143
cmake -B build -DCMAKE_BUILD_TYPE=Release \
  -DSTRATA_ENABLE_CUDA=ON -DSTRATA_BUILD_TESTS=OFF -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES=86 -DSTRATA_CUDA_SM86_IQ3_STAGE2=ON \
  -DSTRATA_GGML_DIR="$HOME/src/strata/third_party/llama.cpp" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON
cmake --build build --target strata -j"$(nproc)"
```
| 坑 | 后果 | 原因 |
|---|---|---|
| 不传 `STRATA_GGML_DIR` / `FETCHCONTENT_FULLY_DISCONNECTED` | cmake **卡死 10+ 分钟** | 会去 `git clone github.com/ggml-org/llama.cpp`（本机连不上） |
| 不传 `STRATA_ENABLE_CUDA=ON` | `No rule to make target 'strata'` | 引擎目标未创建（`GGML_CUDA=ON` 不够） |

**已构建产物**：`engine/strata-v0143ps1`（`strata 0.1.43` + SM86 stage2，66 MB）


## 7. 验证证据（2026-10-12/13，单变量 A/B，贪心 top_k=1）

| 补丁 | 场景 | 结果 | 判据 | 结论 |
|---|---|---|---|---|
| **#1744**（SM86 stage2） | v0143ps1，`STRATA_PF_IQ3_STAGE2` 0/1，其余固定 | decode@2K 114.0 vs 114.7；prefill7K 2310.9 vs 2308.4；prefill32K 2823.9 vs 2821.5；**输出指纹逐字节一致** `c05bc626eaa412a2` | prefill ±0.5% / decode ±10% / 输出必须一致 | **零收益、零回归、输出不变** → 保留但不启用（丢弃判据：上游合并 或 继续中性） |

参考（同机基线，v0.1.43 + 生产配置）：decode@2K **114**，prefill 7K/32K **2,308/2,824** tok/s
（上游官方表 3090+IQ3_S：decode 52.4、prefill 1,624@32K；社区同配置 #2100：decode 62.1、prefill 1,200@16K）


## 8. 后续验证（2026-10-13 起，按理论优先级）

| 顺序 | PR | 分支 | 机制 | 状态 |
|---|---|---|---|---|
| 1 | **#2119** 磁盘停放 | `ours/ps-2119` | ③ state：停放落盘，RAM 只留索引 | **已测第一轮**：省 ~700MB/会话、恢复 +24ms、**恢复后 decode −32%（机制待查）** |
| 2 | **#2077** 前缀落盘 | `patch/pr-2077` | ③ state：长前缀存盘可恢复 | 未测（试合干净） |
| 3 | **#1808** max_queue 429 | `patch/pr-1808` | ③ serve：队列上限 | 未测（试合干净） |
| 4 | **#1806** user_args | `patch/pr-1806` | 构建/运维 | 未测（试合干净） |
| 5 | #2082 | `patch/pr-2082` | ③ 停放准入 | 需手工挑（冲突） |
| 6 | #1704 | `patch/pr-1704` | ① prefill 层缓存 | 后置（PCIe 瓶颈） |


## 9. 组合主线 `ours/next`（2026-10-13，验证通过）

**组成**：v0.1.43 + #1744(保留不启用) + **#2119 + #2077 + #1808** + 本台账
**手工解冲突**：`src/program/generate.cpp` 2 处（#2119 的 ConversationStore ↔ #2077 的前缀身份块）
**验证**：构建 ✅ · 确定性**逐字节一致**（特性 OFF）✅ · prefill@32K −0.1% ✅ · decode@2K −5.6%（±10% 内）✅ · 磁盘停放冒烟 ✅
**状态**：候选主线（待用户批准切生产）；`ours/v0142` 保留为现役回滚点


---

## 11. 新基线 v0.1.44 + 补丁集（2026-10-14，**已上线**）

**基线**：上游 **v0.1.44**（分支点 `ed4773eb`；相对 v0.1.43.1 = 271 提交 / 355 文件 / +46.5k 行）
**我们的主线**：`ours/main` = **`8e6b4d61`** · tag **`ours/v0144-ps1`** · 回溯点 `ours/v0143-ps2`(27de0648)

| PR | 标题 | 状态 | 备注 |
|---|---|---|---|
| #1808 | `max_queue` → 429 + Retry-After | ✅ 已应用 | 干净 |
| #2119 | 磁盘停放（`--conversation-cache-storage disk`） | ✅ 已应用 | 干净 |
| #2265 | `--conversation-cache-park-gain N` | ✅ 已应用 | 1 处冲突；生产 1024 |
| #2247 | `--session-state-codec bf16` | ✅ 已应用 | 2 处冲突；**生产不启用**（改存储精度） |
| #1840 | 无答案续写（`literal_think_guard`） | ✅ 已应用 | 4 处冲突（取 theirs）；生产已开；⚠️ 其单测缺 fixture |
| #2327 | `qwen35` F16 手工展宽（CUDA 12 构建） | ✅ **必需** | 我们 CUDA 12.0 下 v0.1.44 原生编译失败，此 PR 修复 |
| 我们的合并修复 ×2 | CMakeLists 残留行 / `ConversationStore` 转发 `parked_prefix_tokens` | ✅ | 见案例 C121 |

**丢弃/暂缓**：#1744（我们自己的 SM86 补丁，实测中性 → 丢弃）· #2077（与 #2247 语义冲突，且实测**让输出指纹偏离基线**）· #1328（需 4 文件端口）· #2318（用户裁决缓）· #1822/#1825（早前已弃）。

**生产配置**：`exe=engine/strata-v0144ps1` · `--max-context 262144` · `--kv int8 --kv-grow` · `--conversation-cache-storage disk --conversation-cache-dir /srv/models/park --conversation-cache-park-gain 1024` · `max_queue: 8` · `literal_think_guard: true` · **无 `--prompt-cache-file`**

**验收**（`pi-007/60`）：确定性指纹 = 纯净基线 `c05bc626…` ✅ · prefill +0.9~2.2% ✅ · decode −0.7~−6.3%（±10% 内）✅ · swap 0 ✅ · 真实补全 ✅


---

## 12. 分支模型（长期，2026-10-14 用户定稿）

> 用户要求：**每批更新"开一个批次分支 + 同时更新主分支"，旧分支不删**；并**每次给出跨版本数据表**（见 `pi-007/61-version-history-and-metrics.md`）。

| 名称 | 角色 | 规则 |
|---|---|---|
| `upstream/*` | 只读跟随上游 | 同步前 `git fetch upstream --tags` |
| **`ours/main`** | ⭐ **当前生产**（始终 = 线上内容） | **每批就地更新** |
| **`ours/v<ver>`** | **每批的分支**（`ours/v0142` / `ours/v0144`） | **永久保留**，用于 diff 与回溯；`ours/next`、`ours/ps-*` 是当时的集成/单补丁验证分支，同样保留 |
| `patch/pr-<n>` | 候选补丁（上游 PR 的 ref） | 保留（含已并入的，用于跟踪上游是否合并） |
| tag `ours/v<ver>-ps<N>` | **上线锚点** | `ours/v0144-ps1`（当前）· `ours/v0143-ps2`（上一代） |
| tag `ours/archive-*` | 更早生产线归档 | 与分支并存（双保险） |

**当前（2026-10-14）**：生产 = **`ours/main`** = 批次分支 **`ours/v0144`** 的内容 + 台账（`PATCHSET.md`/`verify.sh`，**仅文档差异**）· tag **`ours/v0144-ps1`**。

**每批标准动作**：
1. 从上游新基线开 `ours/v<ver>` → 叠加我们的补丁（**丢弃的也要记录**）；
2. 构建 + 验证（确定性=基线 / prefill ±0.5% / decode ±10% / 无致命告警）；
3. 把 `ours/main` **对齐/合并**到该批次；
4. 推 `ours/main` + **批次分支** + tag（`ours/v<ver>-ps<N>`）；
5. **在 `pi-007/61` 追加三处**：批次行 · 性能行 · **与上一批的差异**。

---

## §12 · 批次 B5（`ours/v0144.1`）—— 2026-10-15

| 项 | 值 |
|---|---|
| 基点 | `upstream/main` = **`296b59d2`**（= tag **v0.1.44.1**，11 个提交 / 54 文件 / +763 −4451） |
| 批次分支 | **`ours/v0144.1`**（从上游起，避免把上游改动当"我们的补丁"） |
| 方法 | **逐个 `cherry-pick -x`** 我们的补丁提交（保留来源哈希） |
| 落地 | **15 个补丁全部干净，零冲突** ✅ |
| **跳过** | **#2327（`07af00ff`）** —— 已由上游 `ab638a56` 提供，且**文件内容字节级相同**（md5 `cdcdeb13…` 三处一致）→ **从补丁集移除** ✅ |
| 未带入 | `PATCHSET.md` / `verify.sh`（我们自己的台账，本批补回）· 台账类提交（`cc4aef87`/`5cc3cee7`/`de9f7e90`） |
| 内容核对 | 旧 `ours/main` vs v0.1.44 = 35 文件/+4440；新批次 vs 上游 = 32 文件/+4204；**文件级差异恰好 = PATCHSET.md、verify.sh（补回）、q36_engine.cu（上游已含）** ✅ |
| 上游本批相关改动 | #2324（引擎启动崩溃语义）· #2327（已并入）· 5d08c753（配置 `reasoning_effort` 也走 Responses API）· 版本号 v0.1.44.1 |
