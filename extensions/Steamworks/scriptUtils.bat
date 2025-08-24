@echo off

set SCRIPT_PATH="%~0"
shift & goto :%~1

:scriptInit
    set "LOG_LABEL=UNSET"
    set "LOG_LEVEL=-1"

    call :assertPowerShellExecutionPolicy

    :: Get extension data
    call :pathExtractBase %SCRIPT_PATH% EXTENSION_NAME
    call :extensionGetVersion EXTENSION_VERSION
    if not defined EXTENSION_VERSION set "EXTENSION_VERSION=0.0.0"

    :: Setup logger
    call :toUpper %EXTENSION_NAME% LOG_LABEL
    call :optionGetValue "logLevel" LOG_LEVEL
    if not defined LOG_LEVEL set "LOG_LEVEL=0"

    :: Check if the operation succeeded
    if %errorlevel% neq 0 (
        call :log "INIT" "Script initialization failed (v%EXTENSION_VERSION% :: %LOG_LEVEL%)."
    ) else (
        call :log "INIT" "Script initialization succeeded (v%EXTENSION_VERSION% :: %LOG_LEVEL%)."
    )
exit /b 0

:assertPowerShellExecutionPolicy
    :: Check the execution policy of the powershell
    for /f "delims=" %%i in ('powershell -Command "Get-ExecutionPolicy"') do set ExecutionPolicy=%%i

    :: If the execution policy is set to 'Restricted' echo the appropriate message.
    IF "!ExecutionPolicy!"=="Restricted" (
        echo The execution of our extensions requires changing the PowerShell Execution Policy.
        echo To do so, please run the following command in your PowerShell terminal:
        echo     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
        exit 1
    )
exit /b 0

:extensionGetVersion result
    :: Need to enabled delayed expansion
    setlocal enabledelayedexpansion

    set "result=!GMEXT_%EXTENSION_NAME%_version!"
    call :logInformation "Accessed extension version with value '%result%'."
    
    :: Need to end local (to push into main scope)
    endlocal & set "%~1=%result%"
exit /b 0

:: Gets an extension option value
:optionGetValue str result
    :: Need to enabled delayed expansion
    setlocal enabledelayedexpansion

    set "result=!YYEXTOPT_%EXTENSION_NAME%_%~1!"
    call :logInformation "Accessed extension option '%~1' with value '%result%'."

    :: Need to end local (to push into main scope)
    endlocal & set "%~2=%result%"
exit /b 0

:: Converts a string to uppercase and stores it into a variable
:toUpper str result
    for /f "usebackq delims=" %%i in (`powershell.exe -Command "$str = '%~1'.ToUpper(); Write-Output $str"`) do set "%~2=%%i"
    call :logInformation "Converted string '%~1' to uppercase."
exit /b 0

:: Extracts folder path from a filepath, if a folder path is provided return it instead
:pathExtractDirectory fullpath result
    set "%~2=%~dp1"
    call :logInformation "Extracted directory path from '%~1'."
exit /b 0

:: Extracts the parent folder path from a filepath. The input 'path\to\my\file.txt' must result in 'my' 
:pathExtractBase fullpath result
    for %%I in ("%~dp1\.") do set "%~2=%%~nI%%~xI"
    call :logInformation "Extracted base name from '%~1'."
exit /b 0

:: Resolves a relative path if required
:pathResolve basePath relativePath result

    :: Need to enable delayed expansion
    setlocal enabledelayedexpansion

    :: Set environment variables for basePath and relativePath
    set "PS_BASEPATH=%~1"
    set "PS_RELATIVEPATH=%~2"

    for /f "delims=" %%i in ('powershell -Command "$basePath = $env:PS_BASEPATH; $relativePath = $env:PS_RELATIVEPATH; Push-Location $basePath; $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($relativePath); Pop-Location;"') do set "result=%%i"

    :: Clean up environment variables
    set "PS_BASEPATH="
    set "PS_RELATIVEPATH="

    call :logInformation "Resolved relative path into '%result%'."

    :: Need to end local (to push into main scope)
    endlocal & set "%~3=%result%"
exit /b 0

:: This function resolves the path if required and stores it into a variable (displays log messages)
:pathResolveExisting basePath relativePath result
    :: Resolve the path
    call :pathResolve "%~1" "%~2" "%~3"

    :: Need to enabled delayed expansion
    setlocal enabledelayedexpansion

    :: Check if the path exists
    if not exist "!%~3%!" (
        call :logError "Path '!%~3%!' does not exist."
        endlocal & exit /b 1
    )
    :: Need to end local (to push into main scope)
    endlocal
exit /b 0

:: Copies a file or folder to the specified destination folder (displays log messages)
:itemCopyTo srcPath destFolder

    call :pathResolve "%cd%" "%~2" destination

    if not exist "%~1" (
        call :logError "Failed to copy '%~1' to '%destination%' (source doesn't exist)."
        exit /b 1
    )

    if exist "%~1\" (
        powershell -NoLogo -NoProfile -Command "Copy-Item -Path '%~1' -Destination '%destination%' -Recurse -Force"
    ) else (
        powershell -NoLogo -NoProfile -Command "Copy-Item -Path '%~1' -Destination '%destination%' -Force"
    )

    if %errorlevel% neq 0 (
        call :logError "Failed to copy '%~1' to '%destination%'."
        exit /b 1
    )

    call :logInformation "Copied '%~1' to '%destination%'."
exit /b 0


:: Deletes a file or folder at the specified path (displays log messages)
:itemDelete targetPath

    call :pathResolve "%cd%" "%~1" target

    if not exist "%~1" (
        call :logWarning "Path '%target%' does not exist. Skipping deletion."
        exit /b 0
    )

    :: Set environment variables for target
    set "PS_TARGET=%target%"

    for /f "delims=" %%a in ('dir /b /a:d "%~1" 2^>nul') do (
        if "%%~a" == "%~nx1" (
            powershell -NoLogo -NoProfile -Command "Remove-Item -Path $env:PS_TARGET -Recurse -Force"
        )
    )

    for /f "delims=" %%a in ('dir /b /a:-d "%~1" 2^>nul') do (
        if "%%~a" == "%~nx1" (
            powershell -NoLogo -NoProfile -Command "Remove-Item -Path $env:PS_TARGET -Force"
        )
    )

    :: Clean up environment variables
    set "PS_TARGET="
    
    :: Check if the deletion operation succeeded
    if %errorlevel% neq 0 (
        call :logError "Failed to delete '%target%'."
        exit /b 1
    )

    call :logInformation "Deleted '%target%'."
exit /b 0

:: Generates the SHA256 hash of a file and stores it into a variable (displays log messages)
:fileGetHash filepath result

    :: Set environment variables for target
    set "PS_FILEPATH=%~1"

    for /f "usebackq delims=" %%i in (`powershell -Command "(Get-FileHash -Path $env:PS_FILEPATH -Algorithm SHA256).Hash"`) do set "%~2=%%i"

    :: Clean up environment variables
    set "PS_FILEPATH="

    call :logInformation "Generated SHA256 hash of '%~1'."
exit /b 0

:: Extracts the contents of a zip file to the specified destination folder (displays log messages)
:fileExtract srcFile destFolder

    :: Set environment variables for target
    set "PS_SRCFILE=%~1"
    set "PS_DESTFOLDER=%~2"

    powershell -Command "if (!(Test-Path $env:PS_DESTFOLDER)) { New-Item -ItemType Directory -Path $env:PS_DESTFOLDER }"
    powershell -Command "$ErrorActionPreference = 'Stop'; Expand-Archive -Path $env:PS_SRCFILE -DestinationPath $env:PS_DESTFOLDER"

    :: Clean up environment variables
    set "PS_SRCFILE="
    set "PS_DESTFOLDER="

    :: Check if the extraction operation succeeded
    if %errorlevel% neq 0 (
        call :logError "Failed to extract contents of '%~1' to '%~2'."
        exit /b 1
    )

    call :logInformation "Extracted contents of '%~1' to '%~2'."
exit /b 0

:: Compresses the contents of a folder into a zip file (displays log messages)
:folderCompress srcFolder destFile

    :: Set environment variables for target
    set "PS_SRCFOLDER=%~1"
    set "PS_DESTFILE=%~2"

    powershell -Command "Compress-Archive -Path $env:PS_SRCFOLDER\* -DestinationPath $env:PS_DESTFILE -Force"

    :: Check if the compression operation succeeded
    if %errorlevel% neq 0 (
        call :logError "Failed to compress contents of '%~1' into '%~2'."
        exit /b 1
    )

    :: Clean up environment variables
    set "PS_SRCFOLDER="
    set "PS_DESTFILE="

    call :logInformation "Compressed contents of '%~1' into '%~2'."
exit /b 0

:: Adds the contents of a folder into a zip file (displays log messages)
:zipUpdate srcFolder destFile

    :: Set environment variables for target
    set "PS_SRCFOLDER=%~1"
    set "PS_DESTFILE=%~2"

    powershell -Command "Compress-Archive -Path $env:PS_SRCFOLDER\* -DestinationPath $env:PS_DESTFILE -Update"

    :: Check if the compression operation succeeded
    if %errorlevel% neq 0 (
        call :logError "Failed to compress contents of '%~1' into '%~2'."
        exit /b 1
    )

    :: Clean up environment variables
    set "PS_SRCFOLDER="
    set "PS_DESTFILE="

    call :logInformation "Compressed contents of '%~1' into '%~2'."
exit /b 0

:: Extracts a specified part of a version string and stores it into a variable (displays log messages)
:versionExtract version part result
    :: Use PowerShell to extract the specified part of the version string
    for /f "usebackq delims=" %%i in (`powershell -Command "$version = New-Object Version '%~1'; Write-Output $version.%~2"`) do set "%~3=%%i"
    
    :: Need to enabled delayed expansion
    setlocal enabledelayedexpansion
    call :logInformation "Extracted part %~2 of version '%~1' with value '!%~3%!'."
    endlocal
exit /b 0

:: Compares two version numbers (major.minor.build.rev) and saves result into variable
:versionCompare version1 version2 result
    for /f "tokens=* usebackq" %%F in (`powershell -NoLogo -NoProfile -Command ^([System.Version]'%~1'^).compareTo^([System.Version]'%~2'^)`) do ( set "%~3=%%F" )
    call :logInformation "Compared version '%~1' with version '%~2'."
exit /b 0

:: Check minimum required versions for STABLE|BETA|DEV releases
:versionLockCheck version stableVersion betaVersion devVersion ltsVersion

    call :versionExtract "%~1" Major majorVersion
    call :versionExtract "%~1" Minor minorVersion

    set "runnerBuild="

    if %minorVersion% equ 0 (
        :: LTS version
        set "runnerBuild=LTS"
        call :assertVersionRequired "%~1" "%~5" "The %%runnerBuild%% runtime version needs to be at least v%~5."
        
    ) else (
        if %majorVersion% geq 2020 (
            if %minorVersion% geq 100 (
                :: Beta version
                set "runnerBuild=BETA"
                call :assertVersionRequired "%~1" "%~3" "The %%runnerBuild%% runtime version needs to be at least v%~3."
            ) else (
                :: Stable version
                set "runnerBuild=STABLE"
                call :assertVersionRequired "%~1" "%~2" "The %%runnerBuild%% runtime version needs to be at least v%~2."
            )
        ) else (
            :: Dev version
            set "runnerBuild=DEV"
            call :assertVersionRequired "%~1" "%~4" "The %%runnerBuild%% runtime version needs to be at least v%~4."
        )
    )

    call :logInformation "Version lock check passed successfully, with %%runnerBuild%% version '%~1'."
exit /b 0

:: ASSERTS

:: Asserts the SHA256 hash of a file, logs an error message and throws an error if they do not match (displays log messages)
:assertFileHashEquals filepath expected message
    :: Generate hash
    call :fileGetHash "%~1" actualHash

    :: Compare the actual hash with the expected hash
    if not "%actualHash%" == "%~2" (
        call :logError "%~3"
        exit /b 1
    )

    :: Log a message
    call :logInformation "Asserted SHA256 hash of '%~1' matches expected hash."
exit /b 0

:: Asserts that the given version string is greater than the expected version string, logs an error message and throws an error if not (displays log messages)
:assertVersionRequired version expected message
    :: Compare the two version strings using :versionCompare
    set "compareResult="
    call :versionCompare "%~1" "%~2" compareResult

    :: Check the result and log an error message and throw an error if not greater
    if %compareResult% lss 0 (
        call :logError "%~3"
        exit /b 1
    )

    :: Log a message
    call :logInformation "Asserted that version '%~1' is greater than or equal to version '%~2'."
exit /b 0

:: Asserts that the given version string is equal to the expected version string, logs an error message and throws an error if not (displays log messages)
:assertVersionEquals version expected message
    :: Compare the two version strings using :versionCompare
    set "compareResult="
    call :versionCompare "%~1" "%~2" compareResult

    :: Check the result and log an error message and throw an error if not equal
    if %compareResult% neq 0 (
        call :logError "%~3"
        exit /b 1
    )

    :: Log a message
    call :logInformation "Asserted that version '%~1' equals version '%~2'."
exit /b 0

:: LOGGING

:: Logs information
:logInformation message
    if %LOG_LEVEL% geq 2 call :log "INFO" "%~1"
exit /b 0

:: Logs warning
:logWarning message
    if %LOG_LEVEL% geq 1 call :log "WARN" "%~1"
exit /b 0

:: Logs error
:logError message
    if %LOG_LEVEL% geq 0 call :log "ERROR" "%~1"
    exit 1
exit /b 0

:: General log function
:log tag message
    echo [%LOG_LABEL%] %~1: %~2
exit /b 0


