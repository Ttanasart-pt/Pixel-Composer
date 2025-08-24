@echo off
set Utils="%~dp0\scriptUtils.bat"


:: ######################################################################################
:: Script Logic

:: Always init the script
call %Utils% scriptInit

:: Version locks
call %Utils% optionGetValue "versionStable" RUNTIME_VERSION_STABLE
call %Utils% optionGetValue "versionBeta" RUNTIME_VERSION_BETA
call %Utils% optionGetValue "versionDev" RUNTIME_VERSION_DEV
call %Utils% optionGetValue "versionLTS" RUNTIME_VERSION_LTS

:: Checks IDE and Runtime versions
call %Utils% versionLockCheck "%YYruntimeVersion%" %RUNTIME_VERSION_STABLE% %RUNTIME_VERSION_BETA% %RUNTIME_VERSION_DEV% %RUNTIME_VERSION_LTS%

call :setup%YYPLATFORM_name% "%~dp0"

exit %errorlevel%

:: ######################################################################################
:: Script Functions

:setupAndroid
    echo "Copying Android Firebase credentials into your project."
    call %Utils% optionGetValue "jsonFile" CREDENTIAL_FILE

    :: Resolve the credentials file path and copy it to the Android ProjectFiles folder
    call %Utils% pathResolveExisting "%YYprojectDir%" "%CREDENTIAL_FILE%" FILE_PATH
    call %Utils% itemCopyTo "%FILE_PATH%" "%~1\AndroidSource\ProjectFiles\google-services.json"
exit /b %errorlevel%

:setupIOS
    echo "Copying iOS Firebase credentials into your project."
    call %Utils% optionGetValue "plistFile" CREDENTIAL_FILE

    :: Resolve the credentials file path and copy it to the iOS ProjectFiles folder
    call %Utils% pathResolveExisting "%YYprojectDir%" "%CREDENTIAL_FILE%" FILE_PATH
    call %Utils% itemCopyTo "%FILE_PATH%" "%~1\iOSProjectFiles\GoogleService-Info.plist"
exit /b %errorlevel%

:setupHTML5
exit /b %errorlevel%