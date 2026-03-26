@echo off
:: ---------------------------------------------------------------------------
:: SubSentry — Release AAB build script
::
:: Prerequisites:
::   1. android/key.properties is populated with your keystore details
::   2. The keystore file exists at the path specified in key.properties
::   3. Flutter is on your PATH
::
:: Output:
::   build\app\outputs\bundle\release\app-release.aab
:: ---------------------------------------------------------------------------

flutter build appbundle --release ^
  --dart-define=SENTRY_DSN=https://38f4aebc60bdbbbe0321d756476987ba@o4510866595053568.ingest.de.sentry.io/4510894655537232

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Build FAILED. Check output above for errors.
    exit /b %ERRORLEVEL%
)

echo.
echo Build succeeded.
echo AAB located at: build\app\outputs\bundle\release\app-release.aab
