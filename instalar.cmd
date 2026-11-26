@echo off
rem Abre o instalar.sh no Git Bash: o bash que o Windows acha primeiro pode ser o do WSL.
for /f "delims=" %%G in ('git --exec-path 2^>nul') do set "GIT_EXEC=%%G"
if not defined GIT_EXEC (
  echo Git nao encontrado. O instalador precisa do Git for Windows, que traz o Git Bash:
  echo https://git-scm.com/download/win
  echo Instale, feche esta janela e de dois cliques de novo em instalar.cmd.
  pause
  exit /b 1
)
set "GIT_BASH=%GIT_EXEC%\..\..\..\bin\bash.exe"
if not exist "%GIT_BASH%" (
  echo Git encontrado, mas o Git Bash nao esta em "%GIT_BASH%".
  echo Reinstale o Git for Windows com o Git Bash marcado.
  pause
  exit /b 1
)
"%GIT_BASH%" "%~dp0instalar.sh" %*
pause
