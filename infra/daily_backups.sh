#!/bin/bash

# Mongodb Backup Script
# This script creates a backup of mogodb databases using mongodump

# Configuration
BACKUP_DIR="/home/ubuntu/mongodb-backups"
MONGO_HOST="localhost"
MONGO_PORT="27017"
DATE=$(date +"%Y_%m_%d")
BACKUP_NAME="mongodb_backup_$DATE"
LOG_FILE="$BACKUP_DIR/backup-$DATE.log"
S3_BUCKET=

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Start backup process
log_message "Starting MongoDB backup..."

# Check if mongodump is available
if ! command -v mongodump &> /dev/null; then
    log_message "ERROR: mongodump not found. Please install MongoDB tools."
    exit 1
fi

# Check if MongoDB is running
if ! pgrep -x "mongod" > /dev/null; then
    log_message "WARNING: MongoDB process not found. Attempting backup anyway..."
fi

# Test MongoDB connection
if ! mongo --host "$MONGO_HOST" --port "$MONGO_PORT" --eval "db.runCommand('ping')" &>/dev/null; then
    log_message "ERROR: Cannot connect to MongoDB at $MONGO_HOST:$MONGO_PORT"
    exit 1
fi

# Create backup
log_message "Creating backup: $BACKUP_NAME"

# Run mongodump
if mongodump --host "$MONGO_HOST" --port "$MONGO_PORT" --out "$BACKUP_DIR/$BACKUP_NAME" 2>&1 | tee -a "$LOG_FILE"; then
    
    # Compress the backup
    log_message "Compressing backup..."
    cd "$BACKUP_DIR"
    if tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"; then
        rm -rf "$BACKUP_NAME"
        log_message "Backup created successfully: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
        
        log_message "Sending backups to S3 bucket"
        aws s3 cp $BACKUP_NAME.tar.gz "s3://$S3_BUCKET/"
    else
        log_message "ERROR: Failed to compress backup"
        exit 1
    fi
else
    log_message "ERROR: mongodump failed"
    exit 1
fi

# Clean up backup directory
log_message "Clearing out backup directory"
rm -rf "$BACKUP_DIR"/*

# Log completion
log_message "Backup process completed successfully"

exit 0