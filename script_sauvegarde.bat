@echo off  ; Désactive l'affichage des commandes exécutées
setlocal  ; Limite la portée des variables à ce script

:: SECTION CONFIGURATION
:: Chemins à personnaliser selon votre besoin
set "SOURCE=folder_to_copy"     ; Chemin du dossier source à sauvegarder
set "DEST=folder_zip_dest"       ; Dossier de destination des sauvegardes
set "LOG=%~dp0backup_log.txt"    ; Chemin du fichier de log (dans le même dossier que le script)

:: Création de l'entête du log avec date et heure
> "%LOG%" echo ===== %DATE% %TIME% =====

:: VÉRIFICATION DU DOSSIER SOURCE
:: Vérifie si le dossier source existe
if not exist "%SOURCE%" (
  >> "%LOG%" echo ERREUR: dossier source introuvable: "%SOURCE%"
  exit /b 1  ; Quitte le script avec un code d'erreur si le dossier n'existe pas
)

:: PRÉPARATION DU DOSSIER DE DESTINATION
:: Crée le dossier de destination s'il n'existe pas
if not exist "%DEST%" mkdir "%DEST%" 2>>"%LOG%"

:: GÉNÉRATION DU TIMESTAMP
:: Utilise PowerShell pour obtenir un horodatage précis au format YYYY-MM-DD_HH-mm-ss
for /f "usebackq delims=" %%x in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"`) do set "TS=%%x"

:: PRÉPARATION DU NOM DE L'ARCHIVE
:: Extrait le nom du dossier source
for %%I in ("%SOURCE%") do set "SRC_NAME=%%~nI"

:: Construit le chemin complet de l'archive avec nom du dossier et timestamp
set "ARCHIVE=%DEST%\%SRC_NAME%_%TS%.zip"

:: COMPRESSION DU DOSSIER
:: Utilise tar pour créer une archive ZIP
:: Options :
;;  -a : détecte automatiquement le format de compression
;;  -c : crée une nouvelle archive
;;  -f : spécifie le nom du fichier de sortie
;;  -C : change le répertoire de travail avant la compression
>> "%LOG%" echo Tentative de compression avec tar...
tar -a -c -f "%ARCHIVE%" -C "%SOURCE%\.." "%SRC_NAME%" >>"%LOG%" 2>&1

:: GESTION DU RÉSULTAT DE LA COMPRESSION
:: Récupère le code de sortie de tar
set "RC=%ERRORLEVEL%"

:: Vérifie si la compression a réussi
if %RC% EQU 0 (
  ; Log de succès
  >> "%LOG%" echo Archive créée: "%ARCHIVE%"
) else (
  ; Log d'erreur si la compression a échoué
  >> "%LOG%" echo ERREUR: tar a échoué (code %RC%). Voir %LOG%
)
