#!/bin/bash

# Docker PostgreSQL データベース管理スクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

case "${1:-}" in
  start)
    echo "Starting PostgreSQL container..."
    docker compose up -d postgres
    echo "Waiting for PostgreSQL to be ready..."
    timeout=30
    while [ $timeout -gt 0 ]; do
      if docker compose exec -T postgres pg_isready -U admin -d jaffle_shop > /dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        exit 0
      fi
      sleep 1
      timeout=$((timeout - 1))
    done
    echo "PostgreSQL failed to start within 30 seconds"
    exit 1
    ;;
  stop)
    echo "Stopping PostgreSQL container..."
    docker compose stop postgres
    echo "PostgreSQL container stopped"
    ;;
  restart)
    echo "Restarting PostgreSQL container..."
    docker compose restart postgres
    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
    ;;
  status)
    docker compose ps postgres
    if docker compose ps postgres | grep -q "Up"; then
      echo ""
      echo "Testing connection..."
      if docker compose exec -T postgres pg_isready -U admin -d jaffle_shop; then
        echo "✓ PostgreSQL is running and accepting connections"
      else
        echo "✗ PostgreSQL is running but not accepting connections"
      fi
    fi
    ;;
  logs)
    docker compose logs -f postgres
    ;;
  shell)
    docker compose exec postgres psql -U admin -d jaffle_shop
    ;;
  clean)
    echo "Stopping and removing PostgreSQL container..."
    docker compose down postgres
    echo "PostgreSQL container removed"
    ;;
  clean-all)
    echo "WARNING: This will remove the PostgreSQL container and all data!"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      docker compose down -v postgres
      echo "PostgreSQL container and data removed"
    else
      echo "Cancelled"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs|shell|clean|clean-all}"
    echo ""
    echo "Commands:"
    echo "  start      - Start PostgreSQL container"
    echo "  stop       - Stop PostgreSQL container"
    echo "  restart    - Restart PostgreSQL container"
    echo "  status     - Show container status"
    echo "  logs       - Show container logs"
    echo "  shell      - Open PostgreSQL shell"
    echo "  clean      - Stop and remove container (keeps data)"
    echo "  clean-all  - Stop and remove container and all data"
    exit 1
    ;;
esac

