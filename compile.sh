#!/bin/bash

# MDPI LaTeX 一键编译脚本
# 自动执行完整的编译流程：pdflatex -> bibtex -> pdflatex -> pdflatex
#
# 可选：编译成功后自动提交并推送到 GitHub
# 用法：
#   ./compile.sh --git
# 该模式只执行：git add -A -> git commit (从键盘输入 message) -> git push

# 设置颜色输出（可选）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 主文件名（不含扩展名）
MAIN_FILE="main"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}开始编译 LaTeX 文档...${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# 检查主文件是否存在
if [ ! -f "${MAIN_FILE}.tex" ]; then
    echo -e "${RED}错误: 找不到文件 ${MAIN_FILE}.tex${NC}"
    exit 1
fi

# 第一步：第一次 pdflatex 编译
echo -e "${GREEN}[1/4] 第一次 pdflatex 编译...${NC}"
pdflatex -interaction=nonstopmode "${MAIN_FILE}.tex" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: pdflatex 第一次编译失败${NC}"
    echo "查看详细错误信息，请运行: pdflatex ${MAIN_FILE}.tex"
    exit 1
fi
echo -e "${GREEN}✓ 第一次编译完成${NC}"
echo ""

# 第二步：运行 bibtex
echo -e "${GREEN}[2/4] 运行 BibTeX...${NC}"
bibtex "${MAIN_FILE}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}警告: BibTeX 可能有问题，但继续编译...${NC}"
    echo "查看详细错误信息，请运行: bibtex ${MAIN_FILE}"
else
    echo -e "${GREEN}✓ BibTeX 完成${NC}"
fi
echo ""

# 第三步：第二次 pdflatex 编译（处理引用）
echo -e "${GREEN}[3/4] 第二次 pdflatex 编译（处理引用）...${NC}"
pdflatex -interaction=nonstopmode "${MAIN_FILE}.tex" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: pdflatex 第二次编译失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 第二次编译完成${NC}"
echo ""

# 第四步：第三次 pdflatex 编译（确保所有交叉引用正确）
echo -e "${GREEN}[4/4] 第三次 pdflatex 编译（最终处理）...${NC}"
pdflatex -interaction=nonstopmode "${MAIN_FILE}.tex" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: pdflatex 第三次编译失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 第三次编译完成${NC}"
echo ""

# 清理临时文件（可选）
echo -e "${YELLOW}清理临时文件...${NC}"
rm -f "${MAIN_FILE}.aux" "${MAIN_FILE}.bbl" "${MAIN_FILE}.blg" "${MAIN_FILE}.log" \
      "${MAIN_FILE}.out" "${MAIN_FILE}.toc" "${MAIN_FILE}.lof" "${MAIN_FILE}.lot" \
      "${MAIN_FILE}.fls" "${MAIN_FILE}.fdb_latexmk" "${MAIN_FILE}.synctex.gz" 2>/dev/null
echo -e "${GREEN}✓ 清理完成${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}编译完成！输出文件: ${MAIN_FILE}.pdf${NC}"
echo -e "${GREEN}========================================${NC}"

# 可选：自动 Git add/commit/push
if [ "${1:-}" = "--git" ]; then
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Git 自动提交与推送（--git）${NC}"
    echo -e "${YELLOW}========================================${NC}"

    # 必须在 git 仓库内
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 当前目录不是 git 仓库，无法执行 git add/commit/push${NC}"
        exit 1
    fi

    # 暂存所有变更（包括新增/删除）
    git add -A

    # 如果没有任何需要提交的内容，就直接退出
    git diff --cached --quiet
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}没有可提交的改动（working tree clean / 无 staged changes），跳过 commit/push。${NC}"
        exit 0
    fi

    # 从键盘读取 commit message
    echo ""
    read -r -p "请输入 commit message（留空则取消）： " COMMIT_MSG
    if [ -z "${COMMIT_MSG}" ]; then
        echo -e "${YELLOW}已取消：commit message 为空。${NC}"
        exit 0
    fi

    git commit -m "${COMMIT_MSG}"
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: git commit 失败${NC}"
        exit 1
    fi

    git push
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: git push 失败${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Git add/commit/push 完成${NC}"
fi
