#!/bin/bash
# 杀死所有 flutter/dart 相关进程

echo "正在查找 Flutter 相关进程..."

# 查找包含 flutter_tools 的 dart 进程
pids=$(ps aux | grep 'flutter_tools' | grep -v grep | awk '{print $2}')

if [ -z "$pids" ]; then
    echo "未找到正在运行的 Flutter 进程。"
    exit 0
fi

echo "找到以下 Flutter 进程："
ps aux | grep 'flutter_tools' | grep -v grep | awk '{printf "  PID: %-8s CMD: %s\n", $2, $11" "$12" "$13" "$14}'

echo ""
echo "正在终止这些进程..."

for pid in $pids; do
    kill "$pid" 2>/dev/null && echo "  ✓ 已终止 PID: $pid" || echo "  ✗ 无法终止 PID: $pid"
done

# 等待 1 秒后检查是否还有残留进程
sleep 1
remaining=$(ps aux | grep 'flutter_tools' | grep -v grep | awk '{print $2}')
if [ -n "$remaining" ]; then
    echo ""
    echo "部分进程未能正常终止，使用 kill -9 强制终止..."
    for pid in $remaining; do
        kill -9 "$pid" 2>/dev/null && echo "  ✓ 已强制终止 PID: $pid" || echo "  ✗ 无法终止 PID: $pid"
    done
fi

echo ""
echo "完成！"
