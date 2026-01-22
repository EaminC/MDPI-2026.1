#!/bin/bash

# MDPI LaTeX 一键编译脚本
# 自动执行完整的编译流程：pdflatex -> bibtex -> pdflatex -> pdflatex

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
