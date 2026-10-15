@echo off
REM Builds a release APK for Threadly on Windows.
REM Requires Flutter + Android SDK (same setup you use for other Flutter apps).
cd /d "%~dp0"

if not exist android (
  echo Generating Android/iOS platform folders...
  call flutter create --org com.threadly --project-name threadly --platforms=android,ios .
)

call flutter pub get || goto :error
call flutter build apk --release || goto :error

echo.
echo Done! APK: %~dp0build\app\outputs\flutter-apk\app-release.apk
start "" "%~dp0build\app\outputs\flutter-apk"
pause
exit /b 0

:error
echo Build failed. Run "flutter doctor" to check your setup.
pause
exit /b 1
