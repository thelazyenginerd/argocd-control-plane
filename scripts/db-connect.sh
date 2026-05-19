#!/bin/bash

# Configuration
CLUSTER_NAME="test02"
NAMESPACE="databases"
DB_NAME="app"       # CNPG default bootstrap database name
REPLICA="rw"           # Options: "rw" (primary) or "ro" (read-only replicas)

SECRET_NAME="${CLUSTER_NAME}-app"
SERVICE_HOST="${CLUSTER_NAME}-${REPLICA}"

echo "--- Fetching credentials from secret: $SECRET_NAME ---"

# 1. Get Username (CNPG application user default is 'app_user')
USER_NAME=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.username}" 2>/dev/null | base64 --decode)
if [ -z "$USER_NAME" ]; then USER_NAME="app_user"; fi

# 2. Get Password from the 'password' key
PASSWORD=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.password}" 2>/dev/null | base64 --decode)

if [ -z "$PASSWORD" ]; then
    echo "Error: Could not find credentials in secret '$SECRET_NAME'."
    echo "Available secrets in namespace '$NAMESPACE':"
    kubectl get secrets -n $NAMESPACE
    exit 1
fi

echo "Connecting to ${SERVICE_HOST} as user: $USER_NAME"

# 3. Launch the temporary psql pod
# Note: Using postgres:16 as standard stable client, change version if needed.
kubectl run psql-client-$(date +%s) -it --rm \
  --namespace $NAMESPACE \
  --image=postgres:18 \
  --restart=Never \
  --env="PGPASSWORD=$PASSWORD" \
  -- psql -h ${SERVICE_HOST} -U $USER_NAME -d $DB_NAME
