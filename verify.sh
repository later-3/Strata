#!/usr/bin/env bash
# 补丁验收协议（每个补丁合入前必跑；证据写入 PATCHSET.md 与 results/）
# 用法: ./verify.sh <基线二进制> <候选二进制> [workdir]
set -u
BASE=${1:?基线引擎二进制}; CAND=${2:?候选引擎二进制}; WORK=${3:-/tmp/strata-verify}
mkdir -p "$WORK"
echo "== 1/7 构建：由调用方保证（干净构建通过、无影响运行的新 warning）"
echo "== 2/7 冒烟：起 serve → /metrics 有数 → 一次对话返回非空"
echo "   关键纪律：保命参数始终带上 --ple-io mmap --prefill 8192 --vram-reserve-mib 700~1000"
echo "== 3/7 确定性：STRATA_PREFILL_CPU_SHARE=0 跑固定 3 条 prompt，与基线逐 token 比对"
echo "   不同必须解释（auto 抖动 vs 补丁引入）"
echo "== 4/7 性能：prompt tok/s、decode tok/s 在 4K / 32K / 128K 三档，与上一次 good build 比"
echo "   判据：prefill ±0.5%、decode ±10%"
echo "== 5/7 资源：VRAM 峰值、主机 RAM 峰值、专家驻留/miss（/metrics）"
echo "== 6/7 稳定性：无 watchdog 重启、无 illegal memory access、无重复 token 退化"
echo "== 7/7 收尾：结果写入 PATCHSET.md 的"验收证据"列"
echo "（本脚本是协议骨架：具体命令在验证时按当时的服务配置填充，禁止凭记忆改参数）"
