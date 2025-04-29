# Function to spawn a Kubernetes troubleshooting pod
k8s_troubleshoot() {
  local namespace="default"
  local image="nicolaka/netshoot:latest"
  local pod_name="troubleshoot-$(date +%s)"
  local command="/bin/sh"
  
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
      -c|--command)
        command="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: k8s_troubleshoot [-n|--namespace namespace] [-i|--image image] [-p|--pod-name name] [-c|--command command]"
        return 1
        ;;
    esac
  done

  echo "Launching troubleshooting pod '$pod_name' in namespace '$namespace' with image '$image'..."
  echo ""
  echo "=== Network Troubleshooting Commands ==="
  echo "Basic Connectivity:"
  echo "  ping google.com                    # Test basic connectivity"
  echo "  curl -v https://kubernetes.default # Test K8s API with details"
  echo "  traceroute 8.8.8.8                 # Show network path to Google DNS"
  echo "  mtr --report 1.1.1.1               # Trace with packet statistics"
  echo ""
  echo "DNS Troubleshooting:"
  echo "  dig kubernetes.default.svc.cluster.local +short   # Quick DNS lookup"
  echo "  dig +trace example.com                            # Full DNS resolution path"
  echo "  nslookup -type=mx gmail.com                       # Check MX records"
  echo "  host -t any example.com                           # All DNS records"
  echo ""
  echo "Network Scanning:"
  echo "  nmap -p 1-1000 10.0.0.1            # Scan first 1000 ports"
  echo "  nmap -sV -p 80,443 example.com     # Detect service versions"
  echo "  nc -vz 10.0.0.1 22                 # Check if SSH port is open"
  echo ""
  echo "Traffic Capture:"
  echo "  tcpdump -i any port 80              # Capture HTTP traffic"
  echo "  tcpdump host 10.0.0.1 and port 443  # Capture HTTPS to specific host"
  echo "  tshark -i any -f \"port 53\"         # Capture DNS queries"
  echo ""
  echo "Connection Analysis:"
  echo "  netstat -tunapl                    # All connections with process info"
  echo "  ss -tunapl                         # Modern alternative with more detail"
  echo "  lsof -i :80                        # Show processes using port 80"
  echo ""
  echo "Performance Testing:"
  echo "  iperf3 -s                          # Start as server"
  echo "  iperf3 -c 10.0.0.2                 # Test throughput to server"
  echo "  wrk -t2 -c100 -d30s http://app     # Load test a web application"
  echo ""
  echo "Advanced Networking:"
  echo "  ip addr                            # Show network interfaces"
  echo "  ip route                           # Show routing table"
  echo "  socat - TCP:10.0.0.1:80            # Raw TCP connection"
  echo "==================================="
  echo ""
  
  # Create the pod with kubectl run
  kubectl run "$pod_name" \
    --namespace "$namespace" \
    --image="$image" \
    --rm \
    --restart=Never \
    --stdin \
    --tty \
    -it \
    -- $command
}

# Create the alias for the function
alias k8s-debug='k8s_troubleshoot'
