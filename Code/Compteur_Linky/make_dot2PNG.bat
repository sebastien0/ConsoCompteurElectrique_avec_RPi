@echo off
echo ========================================================================
echo                   GENERATION DES GRAPHIQUES
echo Calling GraphViz/dot on each .dot files in html directory
echo output files are in .png format in html repository
echo ========================================================================

echo Generation des images UML :
FOR %%I in (.\Doxygen\html\*.dot) DO (
                echo %TAB%- %%~nI...
                echo.
                "C:\Program Files (x86)\Graphviz2.38\bin\dot.exe" -Tpng .\%%I -o .\Doxygen\html\%%~nI.png
)
echo.
echo.
echo Done !
echo.
:: Tempo 1s
ping -n 1 -w 1000 1.1.1.1 > nul

