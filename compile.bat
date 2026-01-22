@echo off
REM MDPI LaTeX 一键编译脚本 (Windows 版本)
REM 自动执行完整的编译流程：pdflatex -> bibtex -> pdflatex -> pdflatex

set MAIN_FILE=main

echo ========================================
echo 开始编译 LaTeX 文档...
echo ========================================
echo.

REM 检查主文件是否存在
if not exist "%MAIN_FILE%.tex" (
    echo 错误: 找不到文件 %MAIN_FILE%.tex
    exit /b 1
)

REM 第一步：第一次 pdflatex 编译
echo [1/4] 第一次 pdflatex 编译...
pdflatex -interaction=nonstopmode "%MAIN_FILE%.tex" >nul 2>&1
if errorlevel 1 (
    echo 错误: pdflatex 第一次编译失败
    echo 查看详细错误信息，请运行: pdflatex %MAIN_FILE%.tex
    exit /b 1
)
echo ✓ 第一次编译完成
echo.

REM 第二步：运行 bibtex
echo [2/4] 运行 BibTeX...
bibtex "%MAIN_FILE%" >nul 2>&1
if errorlevel 1 (
    echo 警告: BibTeX 可能有问题，但继续编译...
    echo 查看详细错误信息，请运行: bibtex %MAIN_FILE%
) else (
    echo ✓ BibTeX 完成
)
echo.

REM 第三步：第二次 pdflatex 编译（处理引用）
echo [3/4] 第二次 pdflatex 编译（处理引用）...
pdflatex -interaction=nonstopmode "%MAIN_FILE%.tex" >nul 2>&1
if errorlevel 1 (
    echo 错误: pdflatex 第二次编译失败
    exit /b 1
)
echo ✓ 第二次编译完成
echo.

REM 第四步：第三次 pdflatex 编译（确保所有交叉引用正确）
echo [4/4] 第三次 pdflatex 编译（最终处理）...
pdflatex -interaction=nonstopmode "%MAIN_FILE%.tex" >nul 2>&1
if errorlevel 1 (
    echo 错误: pdflatex 第三次编译失败
    exit /b 1
)
echo ✓ 第三次编译完成
echo.

REM 清理临时文件（可选）
echo 清理临时文件...
del /q "%MAIN_FILE%.aux" "%MAIN_FILE%.bbl" "%MAIN_FILE%.blg" "%MAIN_FILE%.log" "%MAIN_FILE%.out" "%MAIN_FILE%.toc" "%MAIN_FILE%.lof" "%MAIN_FILE%.lot" "%MAIN_FILE%.fls" "%MAIN_FILE%.fdb_latexmk" "%MAIN_FILE%.synctex.gz" 2>nul
echo ✓ 清理完成
echo.

echo ========================================
echo 编译完成！输出文件: %MAIN_FILE%.pdf
echo ========================================

pause
