#!/bin/bash

# This script installs mongoDB community edition with authentication and network restrictions

set -e  # Exit on any error

# Configuration variables
MONGODB_VERSION="7.0.14"
DATABASE_NAME="uploaded-files"
USERNAME="wiz-user"
ADMIN_USERNAME="admin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root for security reasons"
        error "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

# Generate secure passwords
generate_passwords() {
    ADMIN_PASSWORD=Admin3547!
    USER_PASSWORD=User3547!
    log "Generated secure passwords"
}

# Install MongoDB
install_mongodb() {
    log "Starting MongoDB Community Edition installation..."
    
    # Update package index
    sudo apt-get update
    
    # Install gnupg and curl if not present
    sudo apt-get install -y gnupg curl
    
    # Import MongoDB public GPG key
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
        sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    
    # Create list file for MongoDB
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
        sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    
    # Update package database
    sudo apt-get update
    
    # Install specific MongoDB version
    sudo apt-get install -y \
        mongodb-org=$MONGODB_VERSION \
        mongodb-org-database=$MONGODB_VERSION \
        mongodb-org-server=$MONGODB_VERSION \
        mongodb-org-shell=$MONGODB_VERSION \
        mongodb-org-mongos=$MONGODB_VERSION \
        mongodb-org-tools=$MONGODB_VERSION
    
    
    # Preventing version upgrades when apt-get tuns 
    echo "mongodb-org hold" | sudo dpkg --set-selections
    echo "mongodb-org-database hold" | sudo dpkg --set-selections
    echo "mongodb-org-server hold" | sudo dpkg --set-selections
    echo "mongodb-mongosh hold" | sudo dpkg --set-selections
    echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
    echo "mongodb-org-tools hold" | sudo dpkg --set-selections
    echo "mongodb-org-database-tools-extra hold" | sudo dpkg --set-selections
    
    log "MongoDB Community Edition $MONGODB_VERSION installed successfully"
}

# # Configure MongoDB
# configure_mongodb() {
#     log "Configuring MongoDB..."
    
#     # Backup original config
#     sudo cp /etc/mongod.conf /etc/mongod.conf.backup
    
#     # Create new configuration
#     sudo tee /etc/mongod.conf > /dev/null <<EOF
# # mongod.conf

# # for documentation of all options, see:
# #   http://docs.mongodb.org/manual/reference/configuration-options/


# # Where to write logging data
# systemLog:
#   destination: file
#   logAppend: true
#   path: /var/log/mongodb/mongod.log

# # Network interfaces
# net:
#   port: 27017
#   bindIp: 127.0.0.1,$(ip route get 1 | awk '{print $7}' | head -1)

# # Process management
# processManagement:
#   timeZoneInfo: /usr/share/zoneinfo

# # Security
# security:
#   authorization: enabled

# # Replication (optional)
# #replication:

# # Sharding (optional)
# #sharding:
# EOF

#     log "MongoDB configuration updated"
# }


# Start MongoDB service
start_mongodb() {
    log "Starting MongoDB service..."
    
    # Enable and start MongoDB
    sudo systemctl enable mongod
    sudo systemctl start mongod
    
    # Wait for MongoDB to start
    sleep 5
    
    # Check if MongoDB is running
    if sudo systemctl is-active --quiet mongod; then
        log "MongoDB service started successfully"
    else
        error "Failed to start MongoDB service"
        exit 1
    fi
}

# Create admin user
create_admin_user() {
    log "Creating admin user..."
    
    # Connect to MongoDB and create admin user
    mongosh --quiet --eval "
        use admin;
        db.createUser({
            user: '$ADMIN_USERNAME',
            pwd: '$ADMIN_PASSWORD',
            roles: [
                { role: 'userAdminAnyDatabase', db: 'admin' },
                { role: 'readWriteAnyDatabase', db: 'admin' },
                { role: 'dbAdminAnyDatabase', db: 'admin' },
                { role: 'clusterAdmin', db: 'admin' }
            ]
        });
        print('Admin user created successfully');
    "
    
    log "Admin user '$ADMIN_USERNAME' created"
}

# Create database and user
create_database_and_user() {
    log "Creating database '$DATABASE_NAME' and user '$USERNAME'..."
    
    # Connect with admin credentials and create database user
    mongosh --quiet -u "$ADMIN_USERNAME" -p "$ADMIN_PASSWORD" --authenticationDatabase admin --eval "
        use $DATABASE_NAME;
        db.createUser({
            user: '$USERNAME',
            pwd: '$USER_PASSWORD',
            roles: [
                { role: 'readWrite', db: '$DATABASE_NAME' },
                { role: 'dbAdmin', db: '$DATABASE_NAME' }
            ]
        });
        
        // Create a sample collection to ensure database exists
        db.test.insertOne({message: 'Database created successfully', timestamp: new Date()});
        print('Database and user created successfully');
    "
    
    log "Database '$DATABASE_NAME' and user '$USERNAME' created successfully"
}

# Restart MongoDB with authentication
restart_with_auth() {
    log "Restarting MongoDB with authentication enabled..."
    
    sudo systemctl restart mongod
    sleep 5
    
    if sudo systemctl is-active --quiet mongod; then
        log "MongoDB restarted successfully with authentication"
    else
        error "Failed to restart MongoDB with authentication"
        exit 1
    fi
}

# Verify installation
verify_installation() {
    log "Verifying MongoDB installation..."
    
    # Check MongoDB version
    INSTALLED_VERSION=$(mongod --version | grep "db version" | awk '{print $3}' | sed 's/v//')
    if [[ "$INSTALLED_VERSION" == "$MONGODB_VERSION" ]]; then
        log "✓ MongoDB version $INSTALLED_VERSION verified"
    else
        error "Version mismatch. Expected: $MONGODB_VERSION, Found: $INSTALLED_VERSION"
        exit 1
    fi
    
    # Test admin connection
    if mongosh --quiet -u "$ADMIN_USERNAME" -p "$ADMIN_PASSWORD" --authenticationDatabase admin --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        log "✓ Admin user authentication verified"
    else
        error "Admin user authentication failed"
        exit 1
    fi
    
    # Test database user connection
    if mongosh --quiet -u "$USERNAME" -p "$USER_PASSWORD" --authenticationDatabase "$DATABASE_NAME" "$DATABASE_NAME" --eval "db.runCommand({ping: 1})" > /dev/null 2>&1; then
        log "✓ Database user authentication verified"
    else
        error "Database user authentication failed"
        exit 1
    fi
    
    log "✓ All verifications passed!"
}

# Display connection information
display_connection_info() {
    log "MongoDB installation completed successfully!"
    echo
    info "=== CONNECTION INFORMATION ==="
    echo "MongoDB Version: $MONGODB_VERSION"
    echo "Database Name: $DATABASE_NAME"
    echo "Network Access: Limited to subnet $SUBNET"
    echo
    info "=== ADMIN CREDENTIALS ==="
    echo "Username: $ADMIN_USERNAME"
    echo "Password: $ADMIN_PASSWORD"
    echo "Database: admin"
    echo
    info "=== APPLICATION USER CREDENTIALS ==="
    echo "Username: $USERNAME"
    echo "Password: $USER_PASSWORD"
    echo "Database: $DATABASE_NAME"
    echo
    info "=== CONNECTION STRINGS ==="
    echo "Admin: mongodb://$ADMIN_USERNAME:$ADMIN_PASSWORD@localhost:27017/admin"
    echo "App User: mongodb://$USERNAME:$USER_PASSWORD@localhost:27017/$DATABASE_NAME"
    echo
    warning "IMPORTANT: Save these credentials in a secure location!"
    warning "The passwords are randomly generated and cannot be recovered if lost."
    echo
    info "=== SERVICE COMMANDS ==="
    echo "Start MongoDB: sudo systemctl start mongod"
    echo "Stop MongoDB: sudo systemctl stop mongod"
    echo "Restart MongoDB: sudo systemctl restart mongod"
    echo "Check Status: sudo systemctl status mongod"
    echo "View Logs: sudo tail -f /var/log/mongodb/mongod.log"
}

# Save credentials to file
save_credentials() {
    CRED_FILE="mongodb_credentials_$(date +%Y%m%d_%H%M%S).txt"
    cat > "$CRED_FILE" <<EOF
MongoDB Installation Credentials
Generated on: $(date)

MongoDB Version: $MONGODB_VERSION
Database Name: $DATABASE_NAME
Network Access: Limited to subnet $SUBNET

ADMIN CREDENTIALS:
Username: $ADMIN_USERNAME
Password: $ADMIN_PASSWORD
Database: admin

APPLICATION USER CREDENTIALS:
Username: $USERNAME
Password: $USER_PASSWORD
Database: $DATABASE_NAME

CONNECTION STRINGS:
Admin: mongodb://$ADMIN_USERNAME:$ADMIN_PASSWORD@localhost:27017/admin
App User: mongodb://$USERNAME:$USER_PASSWORD@localhost:27017/$DATABASE_NAME
EOF
    
    chmod 600 "$CRED_FILE"
    log "Credentials saved to: $CRED_FILE"
}

# Main execution
main() {
    log "Starting MongoDB Community Edition 7.0.14 installation script"
    
    check_root
    generate_passwords
    install_mongodb
    # configure_mongodb
    start_mongodb
    create_admin_user
    create_database_and_user
    restart_with_auth
    verify_installation
    display_connection_info
    save_credentials
    
    log "MongoDB installation and configuration completed successfully!"
}

# Run main function
main "$@"