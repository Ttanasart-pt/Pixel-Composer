@echo off
set REMOTE_USER=pxcbot
set REMOTE_IP=192.168.0.218
set KEY_PATH="%USERPROFILE%\.ssh\id_ed25519_linux"

echo Clearing stale GameMaker processes and socket connections on %REMOTE_IP%...

:: Kill processes AND kill any lingering SSH sessions/sockets tied to the user
ssh -i %KEY_PATH% -o BatchMode=yes -o ConnectTimeout=5 %REMOTE_USER%@%REMOTE_IP% "killall -q -9 GameMaker-Runner AssetCompiler igor 2>/dev/null; pkill -9 -u pxcbot -f sshd; rm -rf /tmp/GameMakerStudio2 ~/GameMakerStudio2" < NUL

if %ERRORLEVEL% EQU 0 (
    echo Remote cleanup complete. Ready to run GameMaker.
) else (
    echo Failed to clean up remote target.
)