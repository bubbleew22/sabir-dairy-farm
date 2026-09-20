@echo off
setlocal EnableDelayedExpansion
color 0A
title Sabir Dairy Farm - AUTO APK Builder
cls

echo.
echo  ================================================================
echo    SABIR DAIRY FARM - FULL AUTO APK BUILDER
echo  ================================================================
echo.
echo   Yeh file sab kuch automatic karegi:
echo   [1] Saari files khud banayegi
echo   [2] www folder setup karega
echo   [3] GitHub repo initialize karega
echo   [4] Code push karega
echo   [5] APK build trigger karega
echo.
echo  ================================================================
echo.
timeout /t 2 /nobreak >nul

cd /d "%~dp0"

REM ============================================================
REM  STEP 1: CHECK GIT
REM ============================================================
echo  [1/8] Git check kar rahe hain...
where git >nul 2>nul
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [ERROR] Git install nahi hai!
    echo.
    echo  Download: https://git-scm.com/download/win
    echo  Install karke yeh file dobara chalayein
    echo.
    pause
    exit /b 1
)
echo  [OK] Git mil gaya
echo.

REM ============================================================
REM  STEP 2: CREATE FOLDER STRUCTURE
REM ============================================================
echo  [2/8] Folder structure bana rahe hain...

if not exist "www" mkdir www
if not exist ".github" mkdir .github
if not exist ".github\workflows" mkdir ".github\workflows"

echo  [OK] Folders ready
echo.

REM ============================================================
REM  STEP 3: MOVE FILES TO WWW
REM ============================================================
echo  [3/8] Web files setup kar rahe hain...

if exist "index.html" (
    if not exist "www\index.html" (
        move /Y "index.html" "www\index.html" >nul
        echo  [OK] index.html www\ mein move
    )
) else (
    if exist "www\index.html" (
        echo  [OK] index.html already www\ mein hai
    ) else (
        color 0C
        echo  [ERROR] index.html nahi mili!
        echo  Pehle apni main HTML file is folder mein rakhein
        pause
        exit /b 1
    )
)

if exist "icon.png" (
    if not exist "www\icon.png" (
        move /Y "icon.png" "www\icon.png" >nul
        echo  [OK] icon.png www\ mein move
    )
) else (
    if exist "www\icon.png" (
        echo  [OK] icon.png already www\ mein hai
    ) else (
        echo  [WARN] icon.png nahi mila - default use hoga
    )
)
echo.

REM ============================================================
REM  STEP 4: CREATE CONFIG FILES
REM ============================================================
echo  [4/8] Configuration files bana rahe hain...

REM package.json
if not exist "package.json" (
(
echo {
echo   "name": "sabir-dairy-farm",
echo   "version": "1.0.0",
echo   "description": "Sabir Dairy Farm Management",
echo   "scripts": {
echo     "cap:sync": "npx cap sync"
echo   },
echo   "dependencies": {
echo     "@capacitor/android": "^5.7.0",
echo     "@capacitor/core": "^5.7.0"
echo   },
echo   "devDependencies": {
echo     "@capacitor/cli": "^5.7.0"
echo   }
echo }
) > package.json
echo  [OK] package.json
)

REM capacitor.config.json
if not exist "capacitor.config.json" (
(
echo {
echo   "appId": "com.sabir.dairyfarm",
echo   "appName": "Sabir Dairy Farm",
echo   "webDir": "www",
echo   "bundledWebRuntime": false,
echo   "server": {
echo     "androidScheme": "https"
echo   },
echo   "android": {
echo     "allowMixedContent": true
echo   }
echo }
) > capacitor.config.json
echo  [OK] capacitor.config.json
)

REM .gitignore
if not exist ".gitignore" (
(
echo node_modules/
echo android/
echo ios/
echo .capacitor/
echo *.apk
echo *.aab
echo *.keystore
echo *.jks
echo .DS_Store
echo Thumbs.db
echo .vscode/
echo .idea/
echo *.log
) > .gitignore
echo  [OK] .gitignore
)

REM README.md
if not exist "README.md" (
(
echo # Sabir Dairy Farm App
echo.
echo Complete dairy farm management with Firebase.
echo.
echo ## Master Info
echo - Email: hayatsarwar1989@gmail.com
echo - Phone: 923018020176
echo - Default PIN: 2015
echo.
echo ## APK Download
echo 1. Actions tab
echo 2. Latest build
echo 3. Download Artifact
) > README.md
echo  [OK] README.md
)

REM GitHub Actions workflow
if not exist ".github\workflows\build-apk.yml" (
(
echo name: Build Android APK
echo.
echo on:
echo   push:
echo     branches: [ main, master ]
echo   workflow_dispatch:
echo.
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo       - uses: actions/checkout@v4
echo       - uses: actions/setup-node@v4
echo         with:
echo           node-version: '20'
echo       - uses: actions/setup-java@v4
echo         with:
echo           distribution: 'temurin'
echo           java-version: '17'
echo       - uses: android-actions/setup-android@v3
echo       - run: npm install
echo       - run: mkdir -p www
echo       - run: npx cap add android
echo       - run: npx cap sync android
echo       - name: Build APK
echo         working-directory: android
echo         run: chmod +x gradlew ^&^& ./gradlew assembleDebug
echo       - uses: actions/upload-artifact@v4
echo         with:
echo           name: Sabir-Dairy-Farm-APK
echo           path: android/app/build/outputs/apk/debug/app-debug.apk
echo           retention-days: 30
) > ".github\workflows\build-apk.yml"
echo  [OK] build-apk.yml
)

echo.

REM ============================================================
REM  STEP 5: GIT INIT + CONFIG
REM ============================================================
echo  [5/8] Git setup...

if not exist ".git" (
    git init >nul 2>nul
    git branch -M main >nul 2>nul
    echo  [OK] Git initialized
)

git config user.email >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo  ----------------------------------------------------------------
    echo   GIT SETUP (Pehli dafa)
    echo  ----------------------------------------------------------------
    echo.
    set /p GIT_EMAIL="  Apna Email: "
    set /p GIT_NAME="  Apna Naam: "
    git config --global user.email "!GIT_EMAIL!"
    git config --global user.name "!GIT_NAME!"
    echo  [OK] Git configured
)
echo.

REM ============================================================
REM  STEP 6: GITHUB REPO
REM ============================================================
echo  [6/8] GitHub repository check...

git remote get-url origin >nul 2>nul
if %errorlevel% neq 0 (
    cls
    color 0E
    echo.
    echo  ================================================================
    echo   GITHUB REPOSITORY SETUP
    echo  ================================================================
    echo.
    echo   Pehle GitHub pe naya repo banayein (30 second ka kaam):
    echo.
    echo   1. Browser khulega abhi
    echo   2. "Repository name" mein likhein: sabir-dairy-farm
    echo   3. Public ya Private - koi bhi
    echo   4. Koi checkbox NA tick karein
    echo   5. "Create repository" click karein
    echo   6. URL copy karein
    echo.
    echo  ================================================================
    echo.
    pause
    start "" "https://github.com/new"
    echo.
    echo  Browser mein repo banane ke baad yahan URL paste karein
    echo  Example: https://github.com/username/sabir-dairy-farm.git
    echo.
    set /p REPO_URL="  Repo URL: "
    
    if "!REPO_URL!"=="" (
        color 0C
        echo  [ERROR] URL nahi diya. Exit.
        pause
        exit /b 1
    )
    
    git remote add origin !REPO_URL!
    color 0A
    echo  [OK] Remote added
)
echo.

REM ============================================================
REM  STEP 7: COMMIT + PUSH
REM ============================================================
echo  [7/8] Code commit aur push kar rahe hain...

git add . >nul 2>nul

set COMMIT_MSG=Update: %date% %time%
git commit -m "!COMMIT_MSG!" >nul 2>nul

if %errorlevel% neq 0 (
    echo  [INFO] Koi change nahi ya pehle se commit
) else (
    echo  [OK] Commit ready
)

echo.
echo  Pushing to GitHub...
echo.
git push -u origin main

if %errorlevel% neq 0 (
    echo.
    color 0E
    echo  ----------------------------------------------------------------
    echo   PUSH PROBLEM
    echo  ----------------------------------------------------------------
    echo.
    echo  Agar yeh pehli dafa hai:
    echo  - GitHub username/password maange toh daalein
    echo  - Ya browser mein login popup aayega
    echo.
    echo  Agar error aaye toh:
    echo  git push -u origin main
    echo  Command manually chalayein
    echo.
    pause
)

color 0A
echo.

REM ============================================================
REM  STEP 8: OPEN ACTIONS PAGE
REM ============================================================
echo  [8/8] GitHub Actions page khol rahe hain...

for /f "tokens=*" %%a in ('git remote get-url origin') do set REPO_RAW=%%a
set REPO_URL=!REPO_RAW:.git=!
set REPO_URL=!REPO_URL:git@github.com:=https://github.com/!
set REPO_URL=!REPO_URL:https://github.com/=https://github.com/!

start "" "!REPO_URL!/actions"

cls
color 0A
echo.
echo  ================================================================
echo    SUCCESS! SAB KUCH HO GAYA
echo  ================================================================
echo.
echo   GitHub Actions page browser mein khul gayi hai.
echo.
echo   AB KYA KARNA HAI:
echo.
echo   [1] Actions page pe 3-5 minute wait karein
echo.
echo   [2] Yellow dot (running) green check ho jayega
echo.
echo   [3] Latest "Build Android APK" pe click karein
echo.
echo   [4] Neeche scroll karein - "Artifacts" section
echo.
echo   [5] "Sabir-Dairy-Farm-APK" download karein
echo.
echo   [6] ZIP extract karein - app-debug.apk milega
echo.
echo   [7] APK phone mein install karein
echo.
echo  ================================================================
echo.
echo   Master Info:
echo   Email: hayatsarwar1989@gmail.com
echo   Phone: 923018020176
echo   PIN  : 2015
echo.
echo  ================================================================
echo.

set /p OPEN_URL="  Kya Actions page phir se kholna hai? (Y/N): "
if /i "!OPEN_URL!"=="Y" (
    start "" "!REPO_URL!/actions"
)

echo.
echo  Build complete hone ke baad APK download karein.
echo.
pause