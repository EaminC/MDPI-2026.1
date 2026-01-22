#!/bin/bash

# MDPI LaTeX 一键编译脚本（详细输出版本）
# 显示所有编译输出，便于调试

# 主文件名（不含扩展名）
MAIN_FILE="main"

echo "========================================"
echo "开始编译 LaTeX 文档（详细模式）..."
echo "========================================"
echo ""

# 检查主文件是否存在
if [ ! -f "${MAIN_FILE}.tex" ]; then
    echo "错误: 找不到文件 ${MAIN_FILE}.tex"
    exit 1
fi

# 第一步：第一次 pdflatex 编译
echo "[1/4] 第一次 pdflatex 编译..."
echo "----------------------------------------"
pdflatex -interaction=nonstopmode "${MAIN_FILE}.tex"
if [ $? -ne 0 ]; then
    echo ""
    echo "错误: pdflatex 第一次编译失败"
    exit 1
fi
echo ""
echo "✓ 第一次编译完成"
echo ""

# 第二步：运行 bibtex
echo "[2/4] 运行 BibTeX..."
echo "----------------------------------------"
bibtex "${MAIN_FILE}"
if [ $? -ne 0 ]; then
    echo ""
    echo "警告: BibTeX 可能有问题，但继续编译..."
else
    echo ""
    echo "✓ BibTeX 完成"
fi
echo ""

# 第三步：第二次 pdflatex 编译（处理引用）
echo "[3/4] 第二次 pdflatex 编译（处理引用）..."
echo "----------------------------------------"
pdflatex -interaction=nonstopmode "${MAIN_FILE}.tex"
if [ $? -ne 0 ]; then
    echo ""
    echo "错误: pdflatex 第二次编译失败"
    exit 1
fi
echo ""
echo "✓ 第二次编译完成"
echo ""

# 第四步：第三次 pdflatex 编译（确保所有交叉引用正确）
echo "[4/4] 第三次 pdflatex 编译（最终处理）..."
echo "----------------------------------------"
pdflatex -interaction=nonstopmode "${MAIN_FILE}.tex"
if [ $? -ne 0 ]; then
    echo ""
    echo "错误: pdflatex 第三次编译失败"
    exit 1
fi
echo ""
echo "✓ 第三次编译完成"
echo ""

echo "========================================"
echo "编译完成！输出文件: ${MAIN_FILE}.pdf"
echo "========================================"
