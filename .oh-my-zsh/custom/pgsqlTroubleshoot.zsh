# Function to spawn a PostgreSQL troubleshooting pod
pg_troubleshoot() {
  local namespace="default"
  local image="postgres:15-alpine"
  local pod_name="pg-troubleshoot-$(date +%s)"
  local pv_size="1Gi"
  local tools_enabled="true"
  local custom_pvc=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--namespace)
        namespace="$2"
        shift 2
        ;;
      -i|--image)
        image="$2"
        shift 2
        ;;
      -p|--pod-name)
        pod_name="$2"
        shift 2
        ;;
      -s|--pv-size)
        pv_size="$2"
        shift 2
        ;;
      -t|--tools)
        tools_enabled="$2"
        shift 2
        ;;
      -c|--custom-pvc)
        custom_pvc="$2"
        shift 2
        ;;
      -h|--help)
        echo "PostgreSQL Troubleshooting Pod Creator"
        echo "Usage: pg_troubleshoot [options]"
        echo ""
        echo "Options:"
        echo "  -n, --namespace NAME    Kubernetes namespace (default: default)"
        echo "  -i, --image NAME        Container image (default: postgres:15-alpine)"
        echo "  -p, --pod-name NAME     Pod name (default: pg-troubleshoot-timestamp)"
        echo "  -s, --pv-size SIZE      PV size (default: 1Gi) - ignored if --custom-pvc is used"
        echo "  -t, --tools BOOL        Install additional tools (default: true)"
        echo "  -c, --custom-pvc NAME   Use existing PVC instead of creating new one"
        echo "  -h, --help              Show this help message"
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        return 1
        ;;
    esac
  done

  echo "Creating PostgreSQL troubleshooting pod with the following settings:"
  echo "Pod name: $pod_name"
  echo "Namespace: $namespace"
  echo "Image: $image"

  if [[ -z "$custom_pvc" ]]; then
    echo "PV Size: $pv_size (new PVC will be created)"

    # Create PVC YAML
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${pod_name}-data
  namespace: ${namespace}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${pv_size}
EOF

    # PVC has been created
    echo "PVC ${pod_name}-data created"
    pvc_name="${pod_name}-data"
  else
    echo "Using existing PVC: $custom_pvc"
    pvc_name="$custom_pvc"
  fi

  echo "Additional tools: $tools_enabled"
  echo ""

  # Create the pod with mounted PV
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${pod_name}
  namespace: ${namespace}
spec:
  containers:
  - name: postgres-troubleshoot
    image: ${image}
    env:
    - name: POSTGRES_PASSWORD
      value: "troubleshoot"
    - name: POSTGRES_USER
      value: "postgres"
    - name: POSTGRES_DB
      value: "postgres"
    - name: PGDATA
      value: "/var/lib/postgresql/data/pgdata"
    ports:
    - containerPort: 5432
    volumeMounts:
    - name: data-volume
      mountPath: /data
    - name: pgdata-volume
      mountPath: /var/lib/postgresql/data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: ${pvc_name}
  - name: pgdata-volume
    emptyDir: {}
EOF

  # Wait for pod to be ready
  echo "Waiting for pod ${pod_name} to be ready..."
  kubectl wait --for=condition=ready pod/${pod_name} -n ${namespace} --timeout=120s || {
    echo "Error: Pod failed to reach ready state within timeout period"
    return 1
  }

  # If tools are enabled, install additional tools in the pod
  if [[ "$tools_enabled" == "true" ]]; then
    echo "Installing additional troubleshooting tools..."
    kubectl exec -it ${pod_name} -n ${namespace} -- /bin/sh -c "
      apk update &&
      apk add --no-cache curl wget vim bash tcpdump net-tools bind-tools nmap netcat-openbsd iotop htop sysstat strace lsof less procps postgresql-client pg_top pgbadger python3 py3-pip tmux"

    # Install AWS CLI for S3 functionality
    kubectl exec -it ${pod_name} -n ${namespace} -- /bin/sh -c "
      pip3 install awscli"
  fi

  echo ""
  echo "PostgreSQL Troubleshooting Pod Ready!"
  # Create help file with all instructions
  cat <<EOF | kubectl exec -i ${pod_name} -n ${namespace} -- tee /data/help.txt > /dev/null
=== PostgreSQL Troubleshooting Commands ===
Connect to PostgreSQL:
  psql -U postgres                           # Connect to local PostgreSQL instance
  psql -h HOST -U USER -d DATABASE           # Connect to remote PostgreSQL

Database Operations:
  \\l                                         # List all databases
  \\c DATABASE                                # Connect to specific database
  \\dt                                        # List tables in current database
  \\d TABLE                                   # Describe table structure
  \\du                                        # List users and roles

Connection Troubleshooting:
  pg_isready -h HOST -p PORT                 # Check if server is accepting connections
  netstat -tunapl | grep postgres            # Show PostgreSQL connections
  lsof -i :5432                              # Show processes using PostgreSQL port

Performance Analysis:
  SELECT * FROM pg_stat_activity;            # Show current queries and states
  EXPLAIN ANALYZE SELECT ...                 # Analyze query execution plan
  pg_top -d postgres                         # Real-time PostgreSQL monitoring

Backup & Restore:
  pg_dump -U USER DB > /data/backup.sql      # Backup database to mounted volume
  psql -U USER DB < /data/backup.sql         # Restore from backup
  pg_basebackup -D /data/basebackup -h HOST  # Create physical backup

Log Analysis:
  pgbadger /path/to/postgresql.log           # Generate reports from PostgreSQL logs

Data Volume:
  Your data volume is mounted at /data (size: ${pv_size})
  Use this path to store backups, imports, or other large files

Running Persistent Commands with tmux:
  # Basic tmux commands:
  # Create a new session:   tmux
  # Detach from session:    Press Ctrl+b, then d
  # List sessions:          tmux ls
  # Reattach to session:    tmux attach -t 0
  # Create named session:   tmux new -s session_name
  # Attach to named:        tmux attach -t session_name
  # Split screen vertical:  Ctrl+b then %
  # Split screen horizonal: Ctrl+b then "
  # Navigate between panes: Ctrl+b then arrow key
  # View this help again:   cat /data/help.txt
  # Scroll in tmux:         Ctrl+b then [  (use arrow keys, q to exit)

Data Transfer Operations:
  # Copy a file FROM your local workstation TO the pod's data volume
  kubectl cp /path/to/local/file ${namespace}/${pod_name}:/data/filename

  # Copy a file FROM the pod's data volume TO your local workstation
  kubectl cp ${namespace}/${pod_name}:/data/filename /path/to/local/destination

S3 Object Storage Operations:
  # Configure S3 credentials
  export AWS_ACCESS_KEY_ID=your_access_key
  export AWS_SECRET_ACCESS_KEY=your_secret_key
  export AWS_ENDPOINT_URL=https://your-s3-endpoint

  # List buckets
  aws --endpoint-url \$AWS_ENDPOINT_URL s3 ls

  # List objects in a bucket
  aws --endpoint-url \$AWS_ENDPOINT_URL s3 ls s3://bucket-name/

  # Download a file from S3 to the data volume
  aws --endpoint-url \$AWS_ENDPOINT_URL s3 cp s3://bucket-name/path/to/file /data/

  # Upload a file from data volume to S3
  aws --endpoint-url \$AWS_ENDPOINT_URL s3 cp /data/filename s3://bucket-name/path/

  # Sync entire directory with S3
  aws --endpoint-url \$AWS_ENDPOINT_URL s3 sync /data/directory s3://bucket-name/path/
===================================
EOF

  echo "Created help file at /data/help.txt"
    echo "Connect to the pod:"
  echo "  kubectl exec -it ${pod_name} -n ${namespace} -- tmux"
  echo "  # Or to view help again:"
  echo "  kubectl exec -it ${pod_name} -n ${namespace} -- cat /data/help.txt"
  echo ""
  echo "Data Transfer Operations:"
  echo "  # Copy a file FROM your local workstation TO the pod's data volume"
  echo "  kubectl cp /path/to/local/file ${namespace}/${pod_name}:/data/filename"
  echo ""
  echo "  # Copy a file FROM the pod's data volume TO your local workstation"
  echo "  kubectl cp ${namespace}/${pod_name}:/data/filename /path/to/local/destination"
  echo ""
  echo "Running Persistent Commands with tmux:"
  echo "  # Connect to the pod and start tmux"
  echo "  kubectl exec -it ${pod_name} -n ${namespace} -- tmux"
  echo ""
  echo "  # Basic tmux commands:"
  echo "  # Create a new session:   tmux"
  echo "  # Detach from session:    Press Ctrl+b, then d"
  echo "  # List sessions:          tmux ls"
  echo "  # Reattach to session:    tmux attach -t 0"
  echo "  # Create named session:   tmux new -s session_name"
  echo "  # Attach to named:        tmux attach -t session_name"
  echo "  # Split screen vertical:  Ctrl+b then %"
  echo "  # Split screen horizonal: Ctrl+b then \""
  echo "  # Navigate between panes: Ctrl+b then arrow key"
  echo ""
  echo "  # Example workflow:"
  echo "  # 1. Start tmux:          tmux new -s pg_backup"
  echo "  # 2. Run command:         pg_dump -U postgres db_name > /data/backup.sql"
  echo "  # 3. Detach:              Press Ctrl+b, then d"
  echo "  # 4. Later, reconnect:    tmux attach -t pg_backup"
  echo ""
  echo "S3 Object Storage Operations:"
  echo "  # Configure S3 credentials"
  echo "  export AWS_ACCESS_KEY_ID=your_access_key"
  echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
  echo "  export AWS_ENDPOINT_URL=https://your-s3-endpoint"
  echo ""
  echo "  # List buckets"
  echo "  aws --endpoint-url \$AWS_ENDPOINT_URL s3 ls"
  echo ""
  echo "  # List objects in a bucket"
  echo "  aws --endpoint-url \$AWS_ENDPOINT_URL s3 ls s3://bucket-name/"
  echo ""
  echo "  # Download a file from S3 to the data volume"
  echo "  aws --endpoint-url \$AWS_ENDPOINT_URL s3 cp s3://bucket-name/path/to/file /data/"
  echo ""
  echo "  # Upload a file from data volume to S3"
  echo "  aws --endpoint-url \$AWS_ENDPOINT_URL s3 cp /data/filename s3://bucket-name/path/"
  echo ""
  echo "  # Sync entire directory with S3"
  echo "  aws --endpoint-url \$AWS_ENDPOINT_URL s3 sync /data/directory s3://bucket-name/path/"
  echo "==================================="
  echo ""

  # Connect to the pod with tmux by default and show the help file
  echo "Connecting to pod with tmux and showing help..."
  kubectl exec -it ${pod_name} -n ${namespace} -- /bin/sh -c "tmux new-session 'cat /data/help.txt && echo \"\\n\\nPress ENTER to continue to shell...\" && read && exec bash'" || \
  kubectl exec -it ${pod_name} -n ${namespace} -- tmux || \
  kubectl exec -it ${pod_name} -n ${namespace} -- bash || \
  kubectl exec -it ${pod_name} -n ${namespace} -- /bin/sh
}

# Create the alias for the function
alias pg-debug='pg_troubleshoot'
