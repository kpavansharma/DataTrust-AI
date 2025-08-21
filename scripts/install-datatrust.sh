#!/bin/bash

# DataTrust.AI Installation Script
# This script automates the deployment of DataTrust.AI to your Salesforce org

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists sf; then
        print_error "Salesforce CLI not found. Please install it first:"
        print_error "https://developer.salesforce.com/tools/sfdxcli"
        exit 1
    fi
    
    if ! command_exists git; then
        print_error "Git not found. Please install Git first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Display banner
display_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
    ____        __        _____                 __     ___    ____
   / __ \____ _/ /_____ _/_   _/______  _______/ /_   /   |  /  _/
  / / / / __ `/ __/ __ `/ / / / ___/ / / / ___/ __/  / /| |  / /  
 / /_/ / /_/ / /_/ /_/ / / / / /  / /_/ (__  ) /_   / ___ |_/ /   
/_____/\__,_/\__/\__,_/ /_/ /_/   \__,_/____/\__/  /_/  |_/___/   
                                                                  
EOF
    echo -e "${NC}"
    echo "DataTrust.AI - AI-Powered Analytics for Salesforce"
    echo "Installation and Deployment Script"
    echo "=================================================="
    echo ""
}

# Get user inputs
get_user_inputs() {
    print_status "Gathering deployment information..."
    
    # Org alias
    read -p "Enter your Salesforce org alias (e.g., my-org): " ORG_ALIAS
    if [ -z "$ORG_ALIAS" ]; then
        print_error "Org alias is required"
        exit 1
    fi
    
    # Deployment type
    echo ""
    echo "Select deployment type:"
    echo "1) Sandbox (recommended for testing)"
    echo "2) Production (only if you've tested in sandbox)"
    read -p "Enter choice (1 or 2): " DEPLOY_TYPE
    
    case $DEPLOY_TYPE in
        1)
            DEPLOY_ENV="sandbox"
            TEST_LEVEL="NoTestRun"
            ;;
        2)
            DEPLOY_ENV="production"
            TEST_LEVEL="RunLocalTests"
            print_warning "Production deployment selected. Ensure you've tested in sandbox first!"
            read -p "Are you sure you want to deploy to production? (y/N): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                print_status "Deployment cancelled"
                exit 0
            fi
            ;;
        *)
            print_error "Invalid selection"
            exit 1
            ;;
    esac
    
    # Installation type
    echo ""
    echo "Select installation type:"
    echo "1) Full installation (all components)"
    echo "2) Core components only (minimal install)"
    echo "3) Custom selection"
    read -p "Enter choice (1, 2, or 3): " INSTALL_TYPE
    
    case $INSTALL_TYPE in
        1)
            COMPONENTS="force-app"
            ;;
        2)
            COMPONENTS="force-app/main/default/lwc/dataTrustExtensionPanel,force-app/main/default/lwc/dataTrustScoreWidget,force-app/main/default/lwc/dataTrustAiSummaryPanel,force-app/main/default/classes/DataTrustAIController.cls"
            ;;
        3)
            print_status "Available components:"
            echo "- dataTrustExtensionPanel (Main container - required)"
            echo "- dataTrustScoreWidget (Trust scoring)"
            echo "- dataTrustAiSummaryPanel (AI insights)"
            echo "- dataTrustAnomalyDetector (Anomaly detection)"
            echo "- dataTrustSemanticModel (Data modeling)"
            echo "- dataTrustChatAssistant (AI chat)"
            echo "- dataTrustTimeMachine (Historical analysis)"
            echo "- dataTrustInspector (Deep analysis)"
            echo "- dataTrustSlackIntegration (Collaboration)"
            read -p "Enter comma-separated component names (or 'all' for everything): " CUSTOM_COMPONENTS
            
            if [ "$CUSTOM_COMPONENTS" = "all" ]; then
                COMPONENTS="force-app"
            else
                # Build component path list
                COMPONENTS=""
                IFS=',' read -ra COMP_ARRAY <<< "$CUSTOM_COMPONENTS"
                for comp in "${COMP_ARRAY[@]}"; do
                    comp=$(echo "$comp" | xargs)  # trim whitespace
                    if [ -n "$COMPONENTS" ]; then
                        COMPONENTS="$COMPONENTS,force-app/main/default/lwc/$comp"
                    else
                        COMPONENTS="force-app/main/default/lwc/$comp"
                    fi
                done
            fi
            ;;
        *)
            print_error "Invalid selection"
            exit 1
            ;;
    esac
    
    print_success "Configuration completed"
}

# Authenticate to Salesforce
authenticate_salesforce() {
    print_status "Authenticating to Salesforce..."
    
    # Check if org is already authenticated
    if sf org list --json | grep -q "\"alias\":\"$ORG_ALIAS\""; then
        print_status "Using existing authentication for $ORG_ALIAS"
    else
        print_status "Opening browser for authentication..."
        if ! sf org login web --alias "$ORG_ALIAS"; then
            print_error "Authentication failed"
            exit 1
        fi
    fi
    
    # Verify connection
    if ! sf org display --target-org "$ORG_ALIAS" >/dev/null 2>&1; then
        print_error "Unable to connect to org $ORG_ALIAS"
        exit 1
    fi
    
    print_success "Successfully authenticated to $ORG_ALIAS"
}

# Validate source directory
validate_source() {
    print_status "Validating source code..."
    
    if [ ! -d "force-app" ]; then
        print_error "force-app directory not found. Are you in the correct directory?"
        print_error "Please run this script from the DataTrust.AI root directory"
        exit 1
    fi
    
    if [ ! -f "sfdx-project.json" ]; then
        print_error "sfdx-project.json not found. Invalid project structure"
        exit 1
    fi
    
    print_success "Source validation completed"
}

# Deploy to Salesforce
deploy_to_salesforce() {
    print_status "Deploying DataTrust.AI to $DEPLOY_ENV..."
    
    # Create deployment command
    if [ "$COMPONENTS" = "force-app" ]; then
        DEPLOY_CMD="sf project deploy start --source-dir force-app --target-org $ORG_ALIAS --test-level $TEST_LEVEL"
    else
        DEPLOY_CMD="sf project deploy start --source-dir $COMPONENTS --target-org $ORG_ALIAS --test-level $TEST_LEVEL"
    fi
    
    print_status "Running deployment command..."
    print_status "$DEPLOY_CMD"
    
    if eval "$DEPLOY_CMD"; then
        print_success "Deployment completed successfully!"
    else
        print_error "Deployment failed. Check the error messages above."
        exit 1
    fi
}

# Create permission set
create_permission_set() {
    print_status "Creating permission set..."
    
    # Create permission set metadata
    cat > temp_permset.json << EOF
{
    "fullName": "DataTrust_AI_Users",
    "label": "DataTrust AI Users",
    "description": "Permissions for DataTrust AI application users",
    "hasActivationRequired": false,
    "objectPermissions": [
        {
            "allowCreate": true,
            "allowDelete": false,
            "allowEdit": true,
            "allowRead": true,
            "modifyAllRecords": false,
            "object": "AI_Usage_Log__c",
            "viewAllRecords": false
        },
        {
            "allowCreate": true,
            "allowDelete": false,
            "allowEdit": true,
            "allowRead": true,
            "modifyAllRecords": false,
            "object": "DataTrust_Configuration__c",
            "viewAllRecords": false
        }
    ],
    "applicationVisibilities": [
        {
            "application": "DataTrust_AI",
            "visible": true
        }
    ]
}
EOF

    # Deploy permission set
    if sf data create record --sobject PermissionSet --values "@temp_permset.json" --target-org "$ORG_ALIAS" >/dev/null 2>&1; then
        print_success "Permission set created successfully"
    else
        print_warning "Permission set creation failed or already exists"
    fi
    
    # Clean up temp file
    rm -f temp_permset.json
}

# Post-deployment setup
post_deployment_setup() {
    print_status "Running post-deployment setup..."
    
    # Create sample data (if needed)
    if [ "$DEPLOY_ENV" = "sandbox" ]; then
        print_status "Creating sample data for testing..."
        # Add sample data creation commands here if needed
    fi
    
    # Verify deployment
    print_status "Verifying deployment..."
    if sf org list metadata --metadata-type LightningComponentBundle --target-org "$ORG_ALIAS" | grep -q "dataTrustExtensionPanel"; then
        print_success "Core components verified successfully"
    else
        print_warning "Component verification failed - manual check recommended"
    fi
}

# Display next steps
display_next_steps() {
    print_success "DataTrust.AI installation completed!"
    echo ""
    echo "Next Steps:"
    echo "==========="
    echo ""
    echo "1. 📋 Assign Permissions:"
    echo "   - Go to Setup → Permission Sets"
    echo "   - Find 'DataTrust AI Users'"
    echo "   - Assign to relevant users"
    echo ""
    echo "2. 🚀 Access the Application:"
    echo "   - Go to App Launcher"
    echo "   - Search for 'DataTrust AI'"
    echo "   - Launch the application"
    echo ""
    echo "3. 📖 Training Resources:"
    echo "   - End User Guide: docs/END_USER_GUIDE.md"
    echo "   - Component Guide: docs/COMPREHENSIVE_COMPONENT_GUIDE.md"
    echo "   - Quick Reference: docs/QUICK_REFERENCE_GUIDE.md"
    echo ""
    echo "4. ⚙️ Configuration:"
    echo "   - Review trust score settings"
    echo "   - Configure anomaly detection thresholds"
    echo "   - Set up data source connections"
    echo ""
    echo "5. 🧪 Testing:"
    echo "   - Test with sample dashboards"
    echo "   - Verify all features work correctly"
    echo "   - Train pilot users"
    echo ""
    if [ "$DEPLOY_ENV" = "sandbox" ]; then
        echo "6. 🎯 Production Deployment:"
        echo "   - After successful testing, deploy to production"
        echo "   - Use the same script with production option"
        echo ""
    fi
    echo "📞 Support:"
    echo "   - GitHub Issues: Report bugs and feature requests"
    echo "   - Documentation: Check docs/ folder for detailed guides"
    echo ""
    print_success "Happy analyzing with DataTrust.AI! 🚀"
}

# Main installation flow
main() {
    display_banner
    check_prerequisites
    get_user_inputs
    validate_source
    authenticate_salesforce
    deploy_to_salesforce
    create_permission_set
    post_deployment_setup
    display_next_steps
}

# Handle script interruption
trap 'print_error "Installation interrupted by user"; exit 1' INT

# Run main function
main "$@"