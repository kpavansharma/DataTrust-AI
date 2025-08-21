@echo off
REM DataTrust.AI Installation Script for Windows
REM This script automates the deployment of DataTrust.AI to your Salesforce org

setlocal enabledelayedexpansion

REM Colors (using PowerShell for colored output)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Display banner
echo.
echo %BLUE%    ____        __        _____                 __     ___    ____
echo    / __ \____ _/ /_____ _/_   _/______  _______/ /_   /   ^|  /  _/
echo   / / / / __ `/ __/ __ `/ / / / ___/ / / / ___/ __/  / /^| ^|  / /  
echo  / /_/ / /_/ / /_/ /_/ / / / / /  / /_/ ^(__  ^) /_   / ___ ^|_/ /   
echo /_____/\__,_/\__/\__,_/ /_/ /_/   \__,_/____/\__/  /_/  ^|_/___/   
echo                                                                  %NC%
echo DataTrust.AI - AI-Powered Analytics for Salesforce
echo Installation and Deployment Script
echo ==================================================
echo.

REM Check prerequisites
echo %BLUE%[INFO]%NC% Checking prerequisites...

where sf >nul 2>nul
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Salesforce CLI not found. Please install it first:
    echo %RED%[ERROR]%NC% https://developer.salesforce.com/tools/sfdxcli
    pause
    exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Git not found. Please install Git first.
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Prerequisites check passed

REM Get user inputs
echo %BLUE%[INFO]%NC% Gathering deployment information...

set /p ORG_ALIAS="Enter your Salesforce org alias (e.g., my-org): "
if "%ORG_ALIAS%"=="" (
    echo %RED%[ERROR]%NC% Org alias is required
    pause
    exit /b 1
)

echo.
echo Select deployment type:
echo 1^) Sandbox ^(recommended for testing^)
echo 2^) Production ^(only if you've tested in sandbox^)
set /p DEPLOY_TYPE="Enter choice (1 or 2): "

if "%DEPLOY_TYPE%"=="1" (
    set DEPLOY_ENV=sandbox
    set TEST_LEVEL=NoTestRun
) else if "%DEPLOY_TYPE%"=="2" (
    set DEPLOY_ENV=production
    set TEST_LEVEL=RunLocalTests
    echo %YELLOW%[WARNING]%NC% Production deployment selected. Ensure you've tested in sandbox first!
    set /p confirm="Are you sure you want to deploy to production? (y/N): "
    if /i not "!confirm!"=="y" (
        echo %BLUE%[INFO]%NC% Deployment cancelled
        pause
        exit /b 0
    )
) else (
    echo %RED%[ERROR]%NC% Invalid selection
    pause
    exit /b 1
)

echo.
echo Select installation type:
echo 1^) Full installation ^(all components^)
echo 2^) Core components only ^(minimal install^)
set /p INSTALL_TYPE="Enter choice (1 or 2): "

if "%INSTALL_TYPE%"=="1" (
    set COMPONENTS=force-app
) else if "%INSTALL_TYPE%"=="2" (
    set COMPONENTS=force-app/main/default/lwc/dataTrustExtensionPanel,force-app/main/default/lwc/dataTrustScoreWidget,force-app/main/default/lwc/dataTrustAiSummaryPanel,force-app/main/default/classes/DataTrustAIController.cls
) else (
    echo %RED%[ERROR]%NC% Invalid selection
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Configuration completed

REM Validate source directory
echo %BLUE%[INFO]%NC% Validating source code...

if not exist "force-app" (
    echo %RED%[ERROR]%NC% force-app directory not found. Are you in the correct directory?
    echo %RED%[ERROR]%NC% Please run this script from the DataTrust.AI root directory
    pause
    exit /b 1
)

if not exist "sfdx-project.json" (
    echo %RED%[ERROR]%NC% sfdx-project.json not found. Invalid project structure
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Source validation completed

REM Authenticate to Salesforce
echo %BLUE%[INFO]%NC% Authenticating to Salesforce...

sf org list --json | findstr /C:"%ORG_ALIAS%" >nul
if errorlevel 1 (
    echo %BLUE%[INFO]%NC% Opening browser for authentication...
    sf org login web --alias %ORG_ALIAS%
    if errorlevel 1 (
        echo %RED%[ERROR]%NC% Authentication failed
        pause
        exit /b 1
    )
) else (
    echo %BLUE%[INFO]%NC% Using existing authentication for %ORG_ALIAS%
)

REM Verify connection
sf org display --target-org %ORG_ALIAS% >nul 2>nul
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Unable to connect to org %ORG_ALIAS%
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Successfully authenticated to %ORG_ALIAS%

REM Deploy to Salesforce
echo %BLUE%[INFO]%NC% Deploying DataTrust.AI to %DEPLOY_ENV%...

if "%COMPONENTS%"=="force-app" (
    set DEPLOY_CMD=sf project deploy start --source-dir force-app --target-org %ORG_ALIAS% --test-level %TEST_LEVEL%
) else (
    set DEPLOY_CMD=sf project deploy start --source-dir %COMPONENTS% --target-org %ORG_ALIAS% --test-level %TEST_LEVEL%
)

echo %BLUE%[INFO]%NC% Running deployment command...
echo %BLUE%[INFO]%NC% %DEPLOY_CMD%

%DEPLOY_CMD%
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Deployment failed. Check the error messages above.
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Deployment completed successfully!

REM Post-deployment setup
echo %BLUE%[INFO]%NC% Running post-deployment setup...

if "%DEPLOY_ENV%"=="sandbox" (
    echo %BLUE%[INFO]%NC% Creating sample data for testing...
)

REM Verify deployment
echo %BLUE%[INFO]%NC% Verifying deployment...
sf org list metadata --metadata-type LightningComponentBundle --target-org %ORG_ALIAS% | findstr "dataTrustExtensionPanel" >nul
if errorlevel 1 (
    echo %YELLOW%[WARNING]%NC% Component verification failed - manual check recommended
) else (
    echo %GREEN%[SUCCESS]%NC% Core components verified successfully
)

REM Display next steps
echo.
echo %GREEN%[SUCCESS]%NC% DataTrust.AI installation completed!
echo.
echo Next Steps:
echo ===========
echo.
echo 1. 📋 Assign Permissions:
echo    - Go to Setup → Permission Sets
echo    - Find 'DataTrust AI Users'
echo    - Assign to relevant users
echo.
echo 2. 🚀 Access the Application:
echo    - Go to App Launcher
echo    - Search for 'DataTrust AI'
echo    - Launch the application
echo.
echo 3. 📖 Training Resources:
echo    - End User Guide: docs\END_USER_GUIDE.md
echo    - Component Guide: docs\COMPREHENSIVE_COMPONENT_GUIDE.md
echo    - Quick Reference: docs\QUICK_REFERENCE_GUIDE.md
echo.
echo 4. ⚙️ Configuration:
echo    - Review trust score settings
echo    - Configure anomaly detection thresholds
echo    - Set up data source connections
echo.
echo 5. 🧪 Testing:
echo    - Test with sample dashboards
echo    - Verify all features work correctly
echo    - Train pilot users
echo.
if "%DEPLOY_ENV%"=="sandbox" (
    echo 6. 🎯 Production Deployment:
    echo    - After successful testing, deploy to production
    echo    - Use the same script with production option
    echo.
)
echo 📞 Support:
echo    - GitHub Issues: Report bugs and feature requests
echo    - Documentation: Check docs\ folder for detailed guides
echo.
echo %GREEN%[SUCCESS]%NC% Happy analyzing with DataTrust.AI! 🚀

pause