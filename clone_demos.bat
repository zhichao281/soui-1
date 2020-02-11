cd /d %~dp0
@ECHO off
SETLOCAL enabledelayedexpansion
cls
COLOR 1f

cd ..
mkdir soui-demo
cd soui-demo

call :update_repo SoTool 
call :update_repo sinstar3
call :update_repo CapScreenDemo
call :update_repo idoudemo
call :update_repo SouiActivexDemo
call :update_repo SlogViewer
call :update_repo SouiWallPaper
call :update_repo mclistview_demo
call :update_repo MultiLangs
call :update_repo SouiChartDemo
call :update_repo souispy
call :update_repo SweepingEdge

SET /p selected=1.�Ƿ�����soui_demo.sln����[1=YES;Other=No]:
if %selected% neq 1 (
	goto :eof
) 
:createsln
If Defined SOUI3PATH (
Echo %SOUI3PATH%
) Else (
Echo can't find env variable SOUI3PATH, clone soui core and install wizard first, please.
goto error
)

Echo ��ǰĿ¼��"%cd%"

for /f "tokens=1" %%a in ('dir /ad ^|find "��Ŀ¼"') do (
	set all=%%a
)

if(%all%=="2") (
	goto error
	)

goto inipro

:inputfilelist
for /f "tokens=* eol=." %%a in ('dir /ad /b') do (  
if exist %%a\%%a.pro  Echo SUBDIRS += %%a>>soui-demo.pro
)

goto :createbat
:error
Echo "error ��һЩ��������ǰ������"
goto :eof

:inipro
Echo TEMPLATE = subdirs>soui-demo.pro
Echo TARGET = soui-demo>>soui-demo.pro
Echo CONFIG(x64){>>soui-demo.pro
Echo TARGET = $$TARGET"64">>soui-demo.pro
Echo }>>soui-demo.pro
Echo.>>soui-demo.pro
goto :inputfilelist

:createbat

SET cfg=

set file=%SOUI3PATH%\config\build.cfg
for /f "tokens=1,2* delims==" %%i in (%file%) do (
if "%%i"=="UNICODE" set cfg_unicode=%%j
if "%%i"=="WCHAR" set cfg_wchar=%%j
if "%%i"=="MT" set cfg_mt=%%j
)

if %cfg_mt%==1 ( SET cfg=%cfg% USING_MT)
if %cfg_unicode%==0 (SET cfg=%cfg% MBCS)
if %cfg_wchar%==0 (SET cfg=%cfg% DISABLE_WCHAR)

SET specs=
SET selected=
SET vsvarbat=
SET target=

rem ѡ�����汾
SET /p selected=1.ѡ�����汾[1=x86;2=x64]:
if %selected%==1 (
	SET target=x86
) else if %selected%==2 (
	SET target=x64
	SET cfg=!cfg! x64
) else (
	goto error
)

SET proj_ext=

rem ѡ�񿪷�����
SET /p selected=2.ѡ�񿪷�����[1=2008;2=2010;3=2012;4=2013;5=2015;6=2017;7=2005]:

if %selected%==1 (
	SET specs=win32-msvc2008
	SET proj_ext=vcproj
	SET vsvarbat="!VS90COMNTOOLS!..\..\VC\vcvarsall.bat"
	call !vsvarbat! %target%
	rem call "%VS90COMNTOOLS%..\..\VC\vcvarsall.bat" %target%
	goto built
) else if %selected%==2 (
	SET specs=win32-msvc2010
	SET proj_ext=vcxproj
	SET vsvarbat="%VS100COMNTOOLS%..\..\VC\vcvarsall.bat"
	call !vsvarbat! %target%
	rem call "%VS100COMNTOOLS%..\..\VC\vcvarsall.bat" %target%
	goto built
) else if %selected%==3 (
	SET specs=win32-msvc2012	
	SET proj_ext=vcxproj
	SET vsvarbat="%VS110COMNTOOLS%..\..\VC\vcvarsall.bat"
	call !vsvarbat! %target%
	rem call "%VS110COMNTOOLS%..\..\VC\vcvarsall.bat" %target%
	goto built
) else if %selected%==4 (
	SET specs=win32-msvc2013
	SET proj_ext=vcxproj
	SET vsvarbat="%VS120COMNTOOLS%..\..\VC\vcvarsall.bat"
	call !vsvarbat! %target%
	rem call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" %target%
	goto built
) else if %selected%==5 (
	SET specs=win32-msvc2015
	SET proj_ext=vcxproj
	SET vsvarbat="%VS140COMNTOOLS%..\..\VC\vcvarsall.bat"
	call !vsvarbat! %target%
	rem call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" %target%
	goto built
)else if %selected%==6 (
	SET specs=win32-msvc2017
	SET proj_ext=vcxproj
	for /f "skip=2 delims=: tokens=1,*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" /v "15.0" /reg:32') do ( 
	    set str=%%i
	    set var=%%j
	    set "var=!var:"=!"
	    if not "!var:~-1!"=="=" set value=!str:~-1!:!var!
    )
    SET value=!value!\VC\Auxiliary\Build\vcvarsall.bat
    rem ECHO Vs2017 path is:!value! 
	SET vsvarbat="!value!"
	call !vsvarbat! %target%
	rem call "!value!" %target%
	goto built
)
 else if %selected%==7 (
	SET specs=win32-msvc2005
	SET proj_ext=vcproj
	SET vsvarbat="%VS80COMNTOOLS%..\..\VC\vcvarsall.bat"
	call !vsvarbat! %target%
	rem call "%VS80COMNTOOLS%..\..\VC\vcvarsall.bat" %target%
	goto built
) else (
	goto error
)

:built
if %specs%==win32-msvc2017 (	
	%SOUI3PATH%\tools\qmake2017 -tp vc -r -spec %SOUI3PATH%\tools\mkspecs\%specs% "CONFIG += !cfg! "
) else (
	%SOUI3PATH%\tools\qmake -tp vc -r -spec %SOUI3PATH%\tools\mkspecs\%specs% "CONFIG += !cfg! "
)
pause
goto :eof
:update_repo
if not exist %1 (
  echo "clone %1"
  git clone https://github.com/soui3-demo/%1.git
) else (
  echo "pull %1"
  cd %1
  git pull https://github.com/soui3-demo/%1.git
  cd ..
)