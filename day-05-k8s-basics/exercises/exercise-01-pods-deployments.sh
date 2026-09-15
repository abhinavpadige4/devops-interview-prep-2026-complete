#!/bin/bash
# Exercise 1: Kubernetes Pods and Deployments
# Create and manage Pods and Deployments using kubectl

echo "=== Kubernetes Pods and Deployments Exercise ==="
echo

# Check if kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl is not installed. Please install kubectl first."
    echo "Visit: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if Kubernetes cluster is accessible
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "Cannot connect to Kubernetes cluster. Please ensure:"
    echo "1. Minikube is running (minikube start)"
    echo "2. Or you have access to a Kubernetes cluster"
    echo "3. Or you're using a cloud-based Kubernetes service"
    exit 1
fi

echo "Step 1: Checking cluster connectivity..."
echo "Cluster info:"
kubectl cluster-info
echo

echo "Step 2: Creating a simple Pod manifest..."
mkdir -p k8s-manifests
cd k8s-manifests

# Create a simple pod
cat > hello-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
  labels:
    app: hello
    env: demo
spec:
  containers:
  - name: hello-container
    image: nginx:alpine
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo 'Hello from Kubernetes Pod!' > /usr/share/nginx/html/index.html"]
EOF

echo "Created hello-pod.yaml:"
cat hello-pod.yaml
echo

echo "Step 3: Applying the Pod manifest..."
echo "Creating the Pod:"
kubectl apply -f hello-pod.yaml
echo

echo "Step 4: Checking Pod status..."
echo "Getting Pod details:"
kubectl get pods hello-pod
echo

echo "Describing the Pod:"
kubectl describe pod hello-pod
echo

echo "Step 5: Accessing the Pod..."
echo "Getting Pod IP:"
POD_IP=$(kubectl get pod hello-pod -o jsonpath='{.status.podIP}')
echo "Pod IP: $POD_IP"
echo

echo "Testing if we can access the container (if node port or port-forward available):"
echo "Setting up port-forward to test access:"
kubectl port-forward hello-pod 8080:80 &
PORT_FORWARD_PID=$!
echo "Port forwarding started on PID $PORT_FORWARD_PID"
echo "Waiting for port-forward to establish..."
sleep 3
echo

echo "Testing access to the Pod:"
curl -s http://localhost:8080 || echo "Access test completed (may need manual verification)"
echo

echo "Cleaning up port-forward:"
kill $PORT_FORWARD_PID 2>/dev/null || echo "Port-forward cleanup"
echo

echo "Step 6: Creating a Deployment..."
cat > hello-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
  labels:
    app: hello
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: hello-container
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        lifecycle:
          postStart:
            exec:
              command: ["/bin/sh", "-c", "echo 'Hello from Kubernetes Deployment!' > /usr/share/nginx/html/index.html"]
EOF

echo "Created hello-deployment.yaml:"
cat hello-deployment.yaml
echo

echo "Step 7: Applying the Deployment manifest..."
echo "Creating the Deployment:"
kubectl apply -f hello-deployment.yaml
echo

echo "Step 8: Checking Deployment status..."
echo "Getting Deployment details:"
kubectl get deployment hello-deployment
echo

echo "Getting Pods created by the Deployment:"
kubectl get pods -l app=hello
echo

echo "Describing the Deployment:"
kubectl describe deployment hello-deployment
echo

echo "Step 9: Scaling the Deployment..."
echo "Scaling deployment to 5 replicas:"
kubectl scale deployment hello-deployment --replicas=5
echo

echo "Checking scaled deployment:"
kubectl get deployment hello-deployment
echo

echo "Getting all Pods:"
kubectl get pods -l app=hello
echo

echo "Step 10: Updating the Deployment..."
echo "Updating deployment to use a different image version:"
kubectl set image deployment/hello-deployment hello-container=nginx:1.25-alpine
echo

echo "Checking rollout status:"
kubectl rollout status deployment/hello-deployment
echo

echo "Step 11: Demonstrating rollback..."
echo "Checking rollout history:"
kubectl rollout history deployment/hello-deployment
echo

echo "Step 12: Cleaning up..."
echo "Deleting the Deployment and its Pods:"
kubectl delete deployment hello-deployment
echo

echo "Deleting the Pod:"
kubectl delete pod hello-pod
echo

echo "Verifying cleanup:"
kubectl get pods
echo

# Go back and cleanup
cd ..
rm -rf k8s-manifests

echo
echo "=== Exercise Complete ==="
echo "Summary of Kubernetes Pods and Deployments concepts covered:"
echo "- Pod creation with resource requests and limits"
echo "- Pod lifecycle and postStart hooks"
echo "- Pod labeling and selection"
echo "- Deployment creation for managed Pod replicas"
echo "- Deployment scaling up and down"
echo "- Rolling updates and rollback capabilities"
echo "- Resource management in Kubernetes"
echo "- Basic Pod networking and access methods"
echo "- Manifest-driven declarative management"