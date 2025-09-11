# Change this to your desired subnet
SUBNET=$1 


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


# Configure firewall for private subnet restriction
configure_firewall() {
    log "Configuring firewall rules for subnet restriction..."
    
    # Install ufw if not present
    sudo apt-get install -y ufw
    
    # Enable ufw if not already enabled
    sudo ufw --force enable
    
    # Allow SSH to prevent lockout
    sudo ufw allow ssh
    
    # Allow MongoDB connections only from specified subnet
    sudo ufw allow from $SUBNET to any port 27017
    
    # Reload firewall
    sudo ufw reload
    
    log "Firewall configured to allow MongoDB connections only from $SUBNET"
}


    # Check firewall status
    if sudo ufw status | grep -q "27017.*$SUBNET"; then
        log "✓ Firewall rules verified"
    else
        warning "Firewall rules may not be configured correctly"
    fi