@echo off
rem Extreme HU Version 1.0  Install

if {%OS%}=={Windows_NT} goto :nt2000

:win9x
echo Installing files....
copy comdlg32.ocx %windir%\system
copy msstdfmt.dll %windir%\system
copy mscomm32.ocx %windir%\system
copy msflxgrd.ocx %windir%\system
echo Registering files....
regsvr32 %windir%\system\msstdfmt.dll
goto :cleanup

:nt2000
echo Installing files....
copy comdlg32.ocx %systemroot%\system32
copy msstdfmt.dll %systemroot%\system32
copy mscomm32.ocx %systemroot%\system32
copy msflxgrd.ocx %systemroot%\system32
echo Registering files....
regsvr32 %systemroot%\system32\msstdfmt.dll

:cleanup
echo Removing Files...
del comdlg32.ocx
del msstdfmt.dll
del regsvr32.exe
del msflxgrd.ocx
del mscomm32.ocx
echo Done!
pause
exit

:end