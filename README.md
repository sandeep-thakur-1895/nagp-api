
# 🚀 Kubernetes Deployment for Spring Boot + PostgreSQL Application

**NAGP 2026 Technology Band III - Kubernetes, DevOps & FinOps Workshop**

This repository contains a production-ready multi-tier Kubernetes deployment featuring:
- **Service Tier**: Spring Boot 3.2.5 REST API with 4 replicas and HPA
- **Database Tier**: PostgreSQL 14 with persistent storage
- **DevOps**: Rolling updates, self-healing, Ingress exposure, ConfigMap/Secrets management
- **FinOps**: Resource requests/limits, HPA scaling, 5+ cost optimization opportunities

---

## 📋 Requirements Compliance

### Quick Status Overview

| Category | Status | Details |
|---|---|---|
| **Service API Tier** | ✅ 9/9 Complete | API endpoint, DB fetching, rolling updates, 4 replicas, HPA, self-healing, external access |
| **Database Tier** | ✅ 4/4 Complete | 6 records, data persistence, cluster-only access, pod recovery |
| **Kubernetes Features** | ✅ 7/7 Complete | ConfigMap, Secrets, Ingress, rolling updates, replicas, storage, no Pod IPs |
| **FinOps** | ✅ 3/3 Complete | CPU/Memory limits defined, 5+ cost optimizations, resource monitoring |

### Comprehensive Checklist
📄 **[REQUIREMENTS_CHECKLIST.md](REQUIREMENTS_CHECKLIST.md)** - Full requirements traceability matrix with file mappings

### FinOps Optimization Strategy
📄 **[FINOPS.md](FINOPS.md)** - Detailed cost optimization opportunities and implementation roadmap

---

## 📁 Project Structure

```
nagp-api/
├── src/main/java/com/nagp/assignment/
│   ├── AssignmentApplication.java         # Spring Boot entry point
│   ├── controller/
│   │   └── RecordController.java          # GET /api/records endpoint
│   ├── entity/
│   │   └── Record.java                    # JPA entity (id, name, description)
│   └── repository/
│       └── RecordRepository.java          # Spring Data JPA repository
├── src/main/resources/
│   └── application.properties              # Spring config (uses env vars for DB)
│
├── k8s/
│   ├── kustomization.yaml                 # Kustomize root (all resources)
│   ├── config/
│   │   ├── namespaces.yaml                # 'public' namespace
│   │   ├── app-config.yaml                # ConfigMap: DB_HOST, DB_PORT, DB_NAME
│   │   └── app-secrets.yaml               # Secret: DB_USER, DB_PASSWORD
│   ├── database/
│   │   ├── postgres-deployment.yaml       # PostgreSQL pod, 1 replica
│   │   ├── postgres-pvc.yaml              # PersistentVolumeClaim (1Gi)
│   │   ├── postgres-service.yaml          # ClusterIP service
│   │   └── postgres-initdb-configmap.yaml # init.sql with 6 sample records
│   └── app/
│       ├── nagpapp-deployment.yaml        # Spring Boot app, 4 replicas, probes, resources
│       ├── nagpapp-service.yaml           # ClusterIP service
│       ├── nagpapp-ingress.yaml           # Ingress for external access
│       └── nagpapp-hpa.yaml               # HPA: 2-4 replicas on 50% CPU
│
├── Dockerfile                             # Multi-stage build (Maven + JRE)
├── pom.xml                                # Maven dependencies
├── REQUIREMENTS_CHECKLIST.md              # Complete requirements mapping
├── FINOPS.md                              # FinOps optimization strategy
└── README.md                              # This file
```

---

## 🚀 Quick Deployment

### Prerequisites
- Kubernetes cluster 1.24+ with default StorageClass
- NGINX Ingress Controller installed
- Docker with DockerHub access

### Build & Push Docker Image
```bash
# Build multi-stage image
docker build -t <dockerhub-username>/nagp-app:latest .

# Push to Docker Hub
docker push <dockerhub-username>/nagp-app:latest
```

### Deploy to Kubernetes
```bash
# Deploy all resources using Kustomize (automatically handles resource order)
kubectl apply -k k8s/

# Verify all resources deployed
kubectl get all -n public
kubectl get ingress -n public
kubectl get pvc -n public
```

### Verify Deployment
```bash
# Check all pods are running
kubectl get pods -n public

# View application logs
kubectl logs -f deployment/nagpapp-deployment -n public

# Port forward to test locally
kubectl port-forward svc/nagpapp 8080:80 -n public

# Test API (in another terminal)
curl http://localhost:8080/api/records
```

### Expected Output
```json
[
  {"id": 1, "name": "Record Alpha", "description": "First mock dataset record for verification"},
  {"id": 2, "name": "Record Beta", "description": "Second mock dataset record for verification"},
  ...
]
```

---

## ⚙️ Configuration & Customization

### Database Configuration (ConfigMap)
Located in `k8s/config/app-config.yaml`:
```yaml
data:
  DB_HOST: postgres          # Uses Kubernetes DNS
  DB_PORT: "5432"           # PostgreSQL port
  DB_NAME: nagp_app         # Database name
```

### Database Credentials (Secret)
Located in `k8s/config/app-secrets.yaml`:
```yaml
data:
  DB_USER: cG9zdGdyZXM=     # postgres (base64)
  DB_PASSWORD: V2VsY29tZUAxMjM=  # Welcome@123 (base64)
```

### Resource Limits
Service tier (`k8s/app/nagpapp-deployment.yaml`):
- **Requests**: 100m CPU, 256Mi Memory (minimum guaranteed)
- **Limits**: 500m CPU, 512Mi Memory (maximum allowed)

### HPA Configuration
Scales automatically between 2-4 replicas:
- **Metric**: CPU utilization
- **Target**: 50% (adjustable in FinOps strategy)
- **File**: `k8s/app/nagpapp-hpa.yaml`

---

## 📊 Key Features Implemented

### ✅ Service API Tier
- **Rolling Updates**: Graceful pod replacement
- **Self-Healing**: Liveness & Readiness probes (15s failure threshold)
- **Load Balancing**: 4 replicas with automatic distribution
- **Horizontal Scaling**: HPA scales 2-4 pods based on CPU metrics
- **External Access**: Ingress routes HTTP traffic to service

### ✅ Database Tier
- **Data Persistence**: PersistentVolumeClaim survives pod restarts
- **Pod Recovery**: Automatic recreation after deletion
- **Initialization**: Automatic schema & data loading via ConfigMap
- **Internal Access**: ClusterIP service (no external exposure)
- **Connection Management**: Spring's HikariCP for pooling

### ✅ Security & Configuration
- **ConfigMap**: Externalized database configuration
- **Secrets**: Encrypted password storage (base64 encoded)
- **DNS Resolution**: Pod-to-pod communication via `postgres.public.svc.cluster.local`
- **RBAC**: Can be configured per deployment needs

### ✅ FinOps & Cost Optimization
- **Resource Requests**: Prevents overcommitment
- **Resource Limits**: Prevents runaway resource consumption
- **HPA**: Scales only when needed
- **5+ Optimization Opportunities**: VPA, PDB+Bin Packing, DB right-sizing, etc.

---

## 📈 Monitoring & Validation

### Check Deployment Status
```bash
# All objects in 'public' namespace
kubectl get all -n public

# Specific resource checks
kubectl get deployments -n public
kubectl get statefulsets -n public
kubectl get services -n public
kubectl get ingress -n public
kubectl get pvc -n public

# Pod details
kubectl describe pod <pod-name> -n public
kubectl logs <pod-name> -n public

# Check HPA status
kubectl get hpa -n public
kubectl describe hpa nagpapp-hpa -n public
```

### Health Checks
```bash
# Liveness probe (endpoint: /actuator/health)
kubectl exec <api-pod> -n public -- curl -s http://localhost:8080/actuator/health

# Test database connectivity
kubectl exec <api-pod> -n public -- env | grep DB_

# Check persistent volume
kubectl get pvc postgres-pvc -n public
kubectl get pv
```

---

## 🧪 Testing Scenarios

### Scenario 1: API Functionality
```bash
# Forward port
kubectl port-forward svc/nagpapp 8080:80 -n public

# Test endpoint
curl http://localhost:8080/api/records
```

### Scenario 2: Self-Healing
```bash
# Get pod name
POD=$(kubectl get pods -l app=nagpapp -n public -o jsonpath='{.items[0].metadata.name}')

# Delete pod
kubectl delete pod $POD -n public

# Observe: Pod automatically recreates (self-healing in action)
kubectl get pods -n public --watch
```

### Scenario 3: Data Persistence
```bash
# Get database pod name
DB_POD=$(kubectl get pods -l app=postgres -n public -o jsonpath='{.items[0].metadata.name}')

# Delete database pod
kubectl delete pod $DB_POD -n public

# Observe: Pod recreates and data persists
kubectl get pods -n public --watch

# Verify records still exist
curl http://localhost:8080/api/records
```

### Scenario 4: Rolling Updates
```bash
# Update image in deployment
kubectl set image deployment/nagpapp-deployment \
  nagpapp-container=<new-image>:latest -n public

# Observe: Old pods terminate, new pods start (max 1 surge, 1 unavailable)
kubectl rollout status deployment/nagpapp-deployment -n public

# Rollback if needed
kubectl rollout undo deployment/nagpapp-deployment -n public
```

### Scenario 5: HPA Scaling
```bash
# Load test (in another terminal)
kubectl exec deployment/nagpapp-deployment -n public -- \
  ab -n 1000 -c 50 http://localhost:8080/api/records

# Monitor HPA decisions
kubectl get hpa nagpapp-hpa -n public --watch
```

---

## 🔧 Troubleshooting

### Pod Not Running
```bash
# Check pod status
kubectl describe pod <pod-name> -n public

# Check logs
kubectl logs <pod-name> -n public

# Check events
kubectl get events -n public --sort-by='.lastTimestamp'
```

### Database Connection Issues
```bash
# Test DNS resolution
kubectl exec <api-pod> -n public -- nslookup postgres.public.svc.cluster.local

# Check database pod
kubectl logs postgres-<hash> -n public

# Verify ConfigMap/Secret
kubectl get configmap app-config -n public -o yaml
kubectl get secret app-secrets -n public -o yaml
```

### Ingress Not Working
```bash
# Check ingress
kubectl get ingress -n public
kubectl describe ingress nagpapp-ingress -n public

# Verify ingress controller
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

---

## 📚 Documentation

- **[REQUIREMENTS_CHECKLIST.md](REQUIREMENTS_CHECKLIST.md)** - Complete requirements traceability (10 sections)
  - Service API tier requirements (5 subsections)
  - Database tier requirements (3 subsections)
  - Kubernetes requirements & features (4 subsections)
  - FinOps & optimization strategy (3 subsections)
  - Deliverables status tracking
  - Solution overview & architecture diagrams

- **[FINOPS.md](FINOPS.md)** - Cost optimization strategy & monitoring
  - 5 concrete optimization opportunities with cost impact
  - Resource optimization based on observed metrics
  - Monitoring strategy & KPIs
  - Monthly review process
  - Estimated savings: 75-165% combined

---

## 📞 Support & References

### Kubernetes Resources
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [ConfigMap & Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

### Spring Boot
- [Spring Boot Actuator](https://spring.io/guides/gs/actuator-service/)
- [Spring Data JPA](https://spring.io/projects/spring-data-jpa)
- [Spring Boot Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)

### Container Images
- [Eclipse Temurin JRE](https://hub.docker.com/_/eclipse-temurin)
- [PostgreSQL](https://hub.docker.com/_/postgres)

---

## 📝 Notes

- Replace `<dockerhub-username>` with your actual Docker Hub username
- Ensure NGINX Ingress Controller is installed: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml`
- Namespace `public` is created by `k8s/config/namespaces.yaml`
- For production, use managed secrets storage (Vault, AWS Secrets Manager, etc.)
- Consider implementing cert-manager for HTTPS on Ingress
- Monitor costs regularly using tools like kubecost

---

**Last Updated**: June 23, 2026  
**Status**: Production Ready  
**Assignment**: NAGP 2026 Kubernetes & DevOps Workshop

