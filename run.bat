@echo off
title iPod Run Data Compiler
echo Recherche de l'iPod et compilation du JSON...

:: Exécution du script PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "parse_runs.ps1"

if %errorlevel% neq 0 (
    echo Une erreur est survenue durant le script PowerShell.
    pause
) else (
    echo Operation terminee avec succes.
    echo Ouverture du HUD...
    
    :: Ouvre le fichier HTML avec le navigateur par défaut
    start "" "index.html"
    
    :: Le script s'arrête ici et la fenêtre se ferme immédiatement
    exit
)
