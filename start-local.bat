@echo off
REM SmartBus Local Startup Script
REM Requires: JDK 21 at C:\jdk21 and Tomcat 10.1 at C:\tomcat10

set JAVA_HOME=C:\jdk21
set JRE_HOME=C:\jdk21
set CATALINA_HOME=C:\tomcat10
set PATH=%JAVA_HOME%\bin;%PATH%

echo ====================================================
echo  SmartBus Local Startup
echo  App will be available at: http://localhost:8090
echo  Login: Maetsok01@gmail.com / M@sydo123
echo ====================================================
echo.

REM Check if port 8090 is already in use
netstat -ano | findstr ":8090" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo WARNING: Port 8090 is already in use. Stop the existing server first.
    pause
    exit /b 1
)

REM Build the WAR (skip if already built)
echo Building WAR...
set MVN="C:\Program Files\NetBeans-11.3\netbeans\java\maven\bin\mvn.cmd"
cd /d C:\smartbus
call %MVN% package -DskipTests -q
if %ERRORLEVEL% NEQ 0 (
    echo BUILD FAILED. Check errors above.
    pause
    exit /b 1
)

REM Deploy
echo Deploying to Tomcat 10...
if exist "C:\tomcat10\webapps\ROOT" rmdir /s /q "C:\tomcat10\webapps\ROOT"
copy /y "C:\smartbus\target\smartbus.war" "C:\tomcat10\webapps\ROOT.war" >nul

REM Start Tomcat
echo Starting Tomcat on port 8090...
start "SmartBus Tomcat" /min "%CATALINA_HOME%\bin\catalina.bat" run

echo.
echo Tomcat is starting up (takes ~30-45 seconds)...
echo Open browser at: http://localhost:8090
echo.
echo Press Ctrl+C in the Tomcat window to stop the server.
pause
