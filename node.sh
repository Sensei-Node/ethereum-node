#!/bin/bash

# Ethereum Node Management Script
# Works on both Linux and macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Load environment files
load_env_files() {
    print_info "Loading environment files..."
    
    # Source main .env file
    if [ -f ".env" ]; then
        set -a
        source .env
        set +a
    else
        cp default.env .env
        set -a
        source .env
        set +a
        print_warning "Created .env from default.env"
    fi
    
    # Source all environment files
    for file in ./environments/.env.*; do
        if [ -f "$file" ]; then
            set -a
            source "$file"
            set +a
        fi
    done
    
    print_info "Environment files loaded successfully"
}

# Build docker-compose command with appropriate files
build_compose_command() {
    local compose_files="-f docker-compose.base.yml"
    local services_count=0
    
    print_info "Building service configuration..." >&2
    
    # Execution clients (mutually exclusive)
    if [ "${START_NETHERMIND}" = "true" ]; then
        compose_files="$compose_files -f execution/nethermind/docker-compose.yml"
        print_info "  ✓ Nethermind execution client" >&2
        ((services_count++))
    fi
    
    if [ "${START_BESU}" = "true" ]; then
        compose_files="$compose_files -f execution/besu/docker-compose.yml"
        print_info "  ✓ Besu execution client" >&2
        ((services_count++))
    fi
    
    if [ "${START_GETH}" = "true" ]; then
        compose_files="$compose_files -f execution/geth/docker-compose.yml"
        print_info "  ✓ Geth execution client" >&2
        ((services_count++))
    fi
    
    if [ "${START_RETH}" = "true" ]; then
        compose_files="$compose_files -f execution/reth/docker-compose.yml"
        print_info "  ✓ Reth execution client" >&2
        ((services_count++))
    fi
    
    if [ "${START_ERIGON}" = "true" ]; then
        compose_files="$compose_files -f execution/erigon/docker-compose.yml"
        print_info "  ✓ Erigon execution client" >&2
        ((services_count++))
    fi
    
    # Consensus clients
    if [ "${START_NIMBUS_CC_VC}" = "true" ]; then
        compose_files="$compose_files -f consensus/nimbus/docker-compose.yml"
        print_info "  ✓ Nimbus consensus + validator" >&2
        ((services_count++))
    fi
    
    if [ "${START_LIGHTHOUSE_CC}" = "true" ]; then
        compose_files="$compose_files -f consensus/lighthouse/docker-compose.yml"
        print_info "  ✓ Lighthouse consensus client" >&2
        ((services_count++))
    fi
    
    if [ "${START_LIGHTHOUSE_VC}" = "true" ]; then
        compose_files="$compose_files -f consensus/lighthouse/docker-compose.validator.yml"
        print_info "  ✓ Lighthouse validator client" >&2
        ((services_count++))
    fi
    
    # Additional services
    if [ "${START_MEV_BOOST}" = "true" ]; then
        compose_files="$compose_files -f mev-boost/docker-compose.yml"
        print_info "  ✓ MEV-Boost" >&2
        ((services_count++))
    fi
    
    if [ "${START_EXECBACKUP}" = "true" ]; then
        compose_files="$compose_files -f execbackup/docker-compose.yml"
        print_info "  ✓ Execution backup (failover)" >&2
        ((services_count++))
    fi
    
    if [ "${START_NGINX_PROXY}" = "true" ]; then
        compose_files="$compose_files -f docker-compose.nginx.yml"
        print_info "  ✓ Nginx proxy" >&2
        ((services_count++))
        
        # Check if VIRTUAL_HOST is configured for any enabled service
        check_nginx_virtual_hosts
    fi
    
    if [ "${START_SOCAT}" = "true" ]; then
        compose_files="$compose_files -f socat/docker-compose.yml"
        print_info "  ✓ Socat interceptor" >&2
        ((services_count++))
    fi
    
    if [ "${START_CLEF}" = "true" ]; then
        compose_files="$compose_files -f execution/geth/docker-compose.clef.yml"
        print_info "  ✓ Clef signer" >&2
        ((services_count++))
    fi
    
    if [ $services_count -eq 0 ]; then
        print_error "No services selected! Please configure your .env file." >&2
        exit 1
    fi
    
    echo "$compose_files"
}

# Check if nginx-proxy VIRTUAL_HOST variables are configured
check_nginx_virtual_hosts() {
    local has_execution=false
    local has_consensus=false
    local warnings=()
    
    # Check if any execution client is enabled
    if [ "${START_NETHERMIND}" = "true" ] || [ "${START_BESU}" = "true" ] || \
       [ "${START_GETH}" = "true" ] || [ "${START_RETH}" = "true" ] || \
       [ "${START_ERIGON}" = "true" ]; then
        has_execution=true
    fi
    
    # Check if any consensus client is enabled
    if [ "${START_LIGHTHOUSE_CC}" = "true" ] || [ "${START_NIMBUS_CC_VC}" = "true" ]; then
        has_consensus=true
    fi
    
    # Load environment files to check VIRTUAL_HOST values
    if [ "$has_execution" = true ] && [ -f "./environments/.env.execution" ]; then
        local exec_virtual_host=$(grep "^VIRTUAL_HOST=" ./environments/.env.execution | cut -d'=' -f2)
        if [ -z "$exec_virtual_host" ]; then
            warnings+=("  ⚠️  VIRTUAL_HOST not set in environments/.env.execution")
        fi
    fi
    
    if [ "$has_consensus" = true ] && [ -f "./environments/.env.consensus" ]; then
        local consensus_virtual_host=$(grep "^VIRTUAL_HOST=" ./environments/.env.consensus | cut -d'=' -f2)
        if [ -z "$consensus_virtual_host" ]; then
            warnings+=("  ⚠️  VIRTUAL_HOST not set in environments/.env.consensus")
        fi
    fi
    
    # Display warnings if any
    if [ ${#warnings[@]} -gt 0 ]; then
        print_warning "Nginx-proxy is enabled but VIRTUAL_HOST not configured:" >&2
        for warning in "${warnings[@]}"; do
            echo "$warning" >&2
        done
        print_info "Nginx-proxy will run but won't route traffic without VIRTUAL_HOST set." >&2
        print_info "See 'Nginx Reverse Proxy' section in README.md for setup." >&2
    fi
}

# Check if JWT secret exists, create if not
check_jwt_secret() {
    if [ ! -f "./secrets/jwt.hex" ]; then
        print_info "Generating JWT secret..."
        mkdir -p ./secrets
        
        # Generate random hex string (32 bytes = 64 hex chars)
        if command -v openssl &> /dev/null; then
            openssl rand -hex 32 > ./secrets/jwt.hex
        else
            # Fallback for systems without openssl
            if command -v xxd &> /dev/null; then
                head -c 32 /dev/urandom | xxd -p -c 32 > ./secrets/jwt.hex
            else
                print_error "Neither openssl nor xxd found. Please install one to generate JWT secret."
                exit 1
            fi
        fi
        
        print_info "JWT secret created at ./secrets/jwt.hex"
    fi
}

# Main execution
main() {
    print_info "=== Ethereum Node Startup Script ==="
    print_info "Platform: $(uname -s)"
    
    # Check if docker compose is available
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Check for docker compose
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose"
        exit 1
    fi
    
    # Load environment variables
    load_env_files
    
    # Check/create JWT secret
    check_jwt_secret
    
    # Build compose command
    compose_files=$(build_compose_command)
    
    # Parse command line arguments
    case "${1:-up}" in
        up|start)
            print_info "Pulling latest Docker images..."
            docker compose $compose_files pull
            print_info "Starting services..."
            docker compose $compose_files up -d --build
            print_info "Services started successfully!"
            print_info "Use './node.sh logs' to view logs"
            print_info "Use './node.sh stop' to stop services"
            ;;
        down|stop)
            print_info "Stopping services..."
            docker compose $compose_files down --remove-orphans
            print_info "Services stopped"
            ;;
        restart)
            print_info "Restarting services..."
            docker compose $compose_files down --remove-orphans
            docker compose $compose_files up -d --build
            print_info "Services restarted"
            ;;
        logs)
            docker compose $compose_files logs -f "${@:2}"
            ;;
        ps|status)
            docker compose $compose_files ps
            ;;
        pull)
            print_info "Pulling latest images..."
            docker compose $compose_files pull
            ;;
        config)
            print_info "Generating merged configuration..."
            docker compose $compose_files config
            ;;
        *)
            echo "Usage: $0 {up|start|down|stop|restart|logs|ps|status|pull|config}"
            echo ""
            echo "Commands:"
            echo "  up/start    - Start services (default)"
            echo "  down/stop   - Stop services"
            echo "  restart     - Restart all services"
            echo "  logs        - Follow logs (add service name to filter)"
            echo "  ps/status   - Show running services"
            echo "  pull        - Pull latest Docker images"
            echo "  config      - Show merged docker-compose configuration"
            echo ""
            echo "Environment variables:"
            echo "  Edit .env file to configure which services to start"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
