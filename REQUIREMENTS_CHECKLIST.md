# NAGP Kubernetes Assignment - Requirements Checklist & Implementation

**Project**: NAGP 2026 Technology Band III - Kubernetes, DevOps & FinOps Workshop  

---

## Executive Summary

This document maps all assignment requirements to their implementation files and verifies completion status. The project demonstrates a production-ready multi-tier Kubernetes deployment with Spring Boot API and PostgreSQL database.

---

# SECTION 1: SERVICE API TIER REQUIREMENTS

## 1.1 API Endpoint Exposure

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Exposes API/Application endpoint | ✅ **Done** | [src/main/java/com/nagp/assignment/controller/RecordController.java](src/main/java/com/nagp/assignment/controller/RecordController.java) | GET `/api/records` endpoint returns all records from database |
| On API invocation, fetches data from database tier | ✅ **Done** | [src/main/java/com/nagp/assignment/repository/RecordRepository.java](src/main/java/com/nagp/assignment/repository/RecordRepository.java) | JPA repository interface for Record entity |

## 1.2 Technology Stack & Best Practices

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Standard language/framework | ✅ **Done** | [pom.xml](pom.xml) | Java 17, Spring Boot 3.2.5, Spring Data JPA |
| Connection pooling & config separation | ✅ **Done** | [src/main/resources/application.properties](src/main/resources/application.properties) | Uses environment variables for DB config; Spring's built-in HikariCP |
| Database connection via DNS (not Pod IP) | ✅ **Done** | [src/main/resources/application.properties](src/main/resources/application.properties) | Connection URL: `jdbc:postgresql://postgres.public.svc.cluster.local` |

## 1.3 Kubernetes Deployment Features

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Support rolling updates | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L10) | `strategy: type: RollingUpdate` |
| 4 replicas | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L9) | `replicas: 4` |
| Be externally accessible | ✅ **Done** | [k8s/app/nagpapp-ingress.yaml](k8s/app/nagpapp-ingress.yaml) | Ingress routes external traffic to service |
| Demonstrate self-healing | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L48-L65) | Liveness & Readiness probes with HTTP health checks |
| Demonstrate HPA on Service API | ✅ **Done** | [k8s/app/nagpapp-hpa.yaml](k8s/app/nagpapp-hpa.yaml) | Min 2, Max 4 replicas; Scales on 50% CPU utilization |

## 1.4 Resource Management

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| CPU/Memory Requests | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L38-L40) | Requests: 100m CPU, 256Mi Memory |
| CPU/Memory Limits | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L41-L43) | Limits: 500m CPU, 512Mi Memory |

---

# SECTION 2: DATABASE TIER REQUIREMENTS

## 2.1 Data Model

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| One table with 5-10 records | ✅ **Done** | [k8s/database/postgres-initdb-configmap.yaml](k8s/database/postgres-initdb-configmap.yaml) | 6 sample records in `records` table |
| Entity model definition | ✅ **Done** | [src/main/java/com/nagp/assignment/entity/Record.java](src/main/java/com/nagp/assignment/entity/Record.java) | JPA entity with id, name, description fields |

## 2.2 Data Persistence & Recovery

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Support data persistence | ✅ **Done** | [k8s/database/postgres-pvc.yaml](k8s/database/postgres-pvc.yaml) | PersistentVolumeClaim with 1Gi storage, ReadWriteOnce access |
| Automatically recover after pod deletion | ✅ **Done** | [k8s/database/postgres-deployment.yaml](k8s/database/postgres-deployment.yaml#L12) | Recreate strategy + PVC ensures data survival |
| Data not lost on re-deployment | ✅ **Done** | [k8s/database/postgres-deployment.yaml](k8s/database/postgres-deployment.yaml#L54-L60) | Volume mounts PVC at `/var/lib/postgresql/data` |

## 2.3 Cluster Access & Networking

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Accessible only within cluster | ✅ **Done** | [k8s/database/postgres-service.yaml](k8s/database/postgres-service.yaml) | Service type: `ClusterIP` (no external access) |
| Internal DNS resolution | ✅ **Done** | [k8s/database/postgres-service.yaml](k8s/database/postgres-service.yaml) | Accessible as `postgres.public.svc.cluster.local` |

---

# SECTION 3: KUBERNETES REQUIREMENTS

## 3.1 Feature Comparison Matrix

| Feature | Service API Tier | Database Tier | Status | Implementation Files |
|---|---|---|---|---|
| Exposed outside cluster | Yes | No | ✅ | [nagpapp-ingress.yaml](k8s/app/nagpapp-ingress.yaml), [postgres-service.yaml](k8s/database/postgres-service.yaml) |
| Number of pods | 4 | 1 | ✅ | [nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L9), [postgres-deployment.yaml](k8s/database/postgres-deployment.yaml#L10) |
| Rolling updates support | Yes | No | ✅ | [nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L10-11) |
| Persistent storage | No | Yes | ✅ | [postgres-pvc.yaml](k8s/database/postgres-pvc.yaml) |
| ConfigMap | Yes | Yes | ✅ | [app-config.yaml](k8s/config/app-config.yaml), [postgres-initdb-configmap.yaml](k8s/database/postgres-initdb-configmap.yaml) |
| Secrets | Yes | Yes | ✅ | [app-secrets.yaml](k8s/config/app-secrets.yaml) |

---

# SECTION 4: OTHER KUBERNETES REQUIREMENTS

## 4.1 Configuration Management

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Database config via ConfigMap | ✅ **Done** | [k8s/config/app-config.yaml](k8s/config/app-config.yaml) | ConfigMap contains DB_HOST, DB_PORT, DB_NAME |
| Database password via Secrets | ✅ **Done** | [k8s/config/app-secrets.yaml](k8s/config/app-secrets.yaml) | Secret contains base64-encoded DB_USER, DB_PASSWORD |
| Environment variable injection | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L66-L73) | `envFrom` section references ConfigMap and Secret |

## 4.2 Network & Service Mesh

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Pod IPs NOT used for communication | ✅ **Done** | [src/main/resources/application.properties](src/main/resources/application.properties) | Uses Kubernetes DNS: `postgres.public.svc.cluster.local` |
| Expose Service API via Ingress | ✅ **Done** | [k8s/app/nagpapp-ingress.yaml](k8s/app/nagpapp-ingress.yaml) | Ingress routes HTTP traffic to nagpapp service |
| Service namespace isolation | ✅ **Done** | [k8s/config/namespaces.yaml](k8s/config/namespaces.yaml) | `public` namespace for app isolation |

## 4.3 Deployment Orchestration

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Kustomize configuration | ✅ **Done** | [k8s/kustomization.yaml](k8s/kustomization.yaml) | All resources organized by deployment tier |
| Resource dependencies | ✅ **Done** | [k8s/kustomization.yaml](k8s/kustomization.yaml) | Namespaces → Database → Config → Application order |
| Dockerfile multi-stage build | ✅ **Done** | [Dockerfile](Dockerfile) | Maven build stage + lightweight JRE runtime stage |

---

# SECTION 5: FINOPS REQUIREMENTS

## 5.1 Resource Optimization (Implemented)

| Requirement | Status | Implementation File | Details |
|---|---|---|---|
| Define CPU/Memory requests | ✅ **Done** | [k8s/app/nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L38-L43) | Service: 100m/256Mi requests, 500m/512Mi limits |
| Database resource limits | ✅ **Done** | [k8s/database/postgres-deployment.yaml](k8s/database/postgres-deployment.yaml) | Prevents database from consuming unlimited resources |

## 5.2 Cost Optimization Opportunities (3+)

| # | Opportunity | Priority | Estimated Savings | Documentation |
|---|---|---|---|---|
| 1 | Vertical Pod Autoscaler (VPA) | High | 15-30% | [FINOPS.md](FINOPS.md#opportunity-1-vertical-pod-autoscaling-vpa) |
| 2 | Pod Disruption Budgets + Bin Packing | High | 20-40% | [FINOPS.md](FINOPS.md#opportunity-2-pod-disruption-budgets-pdb--bin-packing) |
| 3 | Right-Size Database Resources | High | 25-35% | [FINOPS.md](FINOPS.md#opportunity-3-right-sizing-database-resources--storage-optimization) |
| 4 | Adjust HPA Target Utilization | Medium | 15-25% | [FINOPS.md](FINOPS.md#action-1-adjust-hpa-target-cpu-utilization) |
| 5 | Scheduled Scaling | Medium | 50% off-peak | [FINOPS.md](FINOPS.md#action-3-implement-horizontal-pod-consolidation) |

**Combined Potential Savings**: 75-165%

## 5.3 Resource Optimization Based on Metrics

| Optimization | Status | Implementation File | Details |
|---|---|---|---|
| HPA Target Utilization | ✅ Documented | [FINOPS.md](FINOPS.md#action-1-adjust-hpa-target-cpu-utilization) | Increase from 50% to 70% → 15-30% pod reduction |
| Right-Size Requests/Limits | ✅ Documented | [FINOPS.md](FINOPS.md#action-2-right-size-resource-requests-based-on-metrics) | Monitor 95th percentile usage for optimization |
| Pod Consolidation | ✅ Documented | [FINOPS.md](FINOPS.md#action-3-implement-horizontal-pod-consolidation) | Reduce minReplicas to 1 off-peak → 50% savings |

---

# SECTION 6: SOLUTION OVERVIEW

## 6.1 Architecture

```
┌─────────────────────────────────────────────┐
│         Kubernetes Cluster (public)         │
├─────────────────────────────────────────────┤
│                                             │
│  ┌────────────────────────────────────┐    │
│  │      External Traffic (HTTP)       │    │
│  └────────────┬───────────────────────┘    │
│               │                             │
│  ┌────────────▼───────────────────────┐    │
│  │    Ingress (nagpapp-ingress)       │    │
│  │    Routes: / → nagpapp service     │    │
│  └────────────┬───────────────────────┘    │
│               │                             │
│  ┌────────────▼───────────────────────┐    │
│  │  Service (nagpapp) - ClusterIP     │    │
│  │  Port 80 → Container Port 8080     │    │
│  └────────────┬───────────────────────┘    │
│               │                             │
│  ┌────────────▼───────────────────────┐    │
│  │   Deployment (nagpapp-deployment)  │    │
│  │   Replicas: 4 (min 2 - max 6 HPA)  │    │
│  │   ┌──────────────────────────────┐ │    │
│  │   │ Pod 1: Spring Boot App       │ │    │
│  │   │ Probes: Liveness/Readiness   │ │    │
│  │   │ Resources: 100m/256Mi req    │ │    │
│  │   │           500m/512Mi limits  │ │    │
│  │   └──────────────────────────────┘ │    │
│  │   ┌──────────────────────────────┐ │    │
│  │   │ Pod 2,3,4: Same as Pod 1     │ │    │
│  │   └──────────────────────────────┘ │    │
│  └────────────┬───────────────────────┘    │
│               │                             │
│  ┌────────────▼───────────────────────┐    │
│  │  Service (postgres) - ClusterIP    │    │
│  │  Internal DNS: postgres.public     │    │
│  │  Port 5432 → Container Port 5432   │    │
│  └────────────┬───────────────────────┘    │
│               │                             │
│  ┌────────────▼───────────────────────┐    │
│  │  Deployment (postgres)             │    │
│  │  Replicas: 1 (Recreate strategy)   │    │
│  │  ┌──────────────────────────────┐  │    │
│  │  │ PostgreSQL Pod               │  │    │
│  │  │ Data: PVC (1Gi storage)      │  │    │
│  │  │ Init: ConfigMap (init.sql)   │  │    │
│  │  └──────────────────────────────┘  │    │
│  └────────────┬───────────────────────┘    │
│               │                             │
│  ┌────────────▼───────────────────────┐    │
│  │ ConfigMap & Secrets                │    │
│  │ • app-config (DB connection)       │    │
│  │ • app-secrets (DB credentials)     │    │
│  │ • postgres-initdb (init.sql)       │    │
│  └────────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

## 6.2 Data Flow

```
User Request
    ↓
[Ingress] → Routes to nagpapp Service
    ↓
[Service] → Load balances to one of 4 Pod replicas
    ↓
[Spring Boot App] → GET /api/records
    ↓
[RecordController] → Calls RecordRepository
    ↓
[JPA/Hibernate] → Query via postgres service
    ↓
[PostgreSQL Pod] → SELECT * FROM records
    ↓
Response: JSON array of records
    ↓
[Browser] ← Displays records
```

---

# SECTION 7: RESOURCE JUSTIFICATION

## 7.1 Service API Tier (nagpapp)

### CPU: 100m requests, 500m limits
**Justification**:
- Spring Boot application with minimal business logic: ~50-75m typical usage
- Request of 100m ensures minimum guaranteed CPU
- Limit of 500m (5x request) provides headroom for spike handling
- 4 replicas with HPA: Can scale to 6 pods if needed

### Memory: 256Mi requests, 512Mi limits
**Justification**:
- Base JVM overhead: ~200Mi
- Application code/libs: ~50-100Mi typical
- Request of 256Mi (2x overhead) ensures stability
- Limit of 512Mi (2x request) prevents OOM kills from memory leaks

## 7.2 Database Tier (PostgreSQL)

### Storage: 1Gi PVC
**Justification**:
- 6 sample records: ~1-2KB per record
- PostgreSQL system tables/overhead: ~50-100Mi
- 1Gi provides 10-100x headroom for growth
- StorageClass: `standard` (sufficient for non-critical workload)

### Replicas: 1 pod
**Justification**:
- Single database instance per requirement
- StatefulSet not needed (single replica)
- PVC ensures persistence across pod restarts
- Production setup would use managed database or multi-replica StatefulSet

## 7.3 HPA Configuration

### Min: 2, Max: 6 replicas
**Justification**:
- Min 2: Ensures availability if 1 pod fails
- Max 6: 3x base replicas for peak load (150% scalability)
- CPU target 50%: Conservative for Spring Boot workloads

### CPU Target: 50% utilization
**Justification**:
- Scales at 50% CPU to maintain headroom
- FinOps optimization opportunity: increase to 70% for cost savings
- Balance: performance (lower %) vs. cost (higher %)

---

# APPENDIX A: QUICK DEPLOYMENT COMMANDS

## Build & Push Docker Image
```bash
docker build -t <username>/nagp-app:latest .
docker push <username>/nagp-app:latest
```

## Deploy to Kubernetes
```bash
kubectl apply -k k8s/
```

## Verify Deployment
```bash
kubectl get ns public
kubectl get all -n public
kubectl get ingress -n public
```

## View Application Logs
```bash
kubectl logs -f deployment/nagpapp-deployment -n public
```


---

# APPENDIX B: REQUIREMENT TRACEABILITY MATRIX

| Requirement ID | Requirement Text | Implementation | Status | Evidence |
|---|---|---|---|---|
| SA-1 | Expose API endpoint | RecordController | ✅ | [RecordController.java](src/main/java/com/nagp/assignment/controller/RecordController.java) |
| SA-2 | Fetch from database | RecordRepository | ✅ | [RecordRepository.java](src/main/java/com/nagp/assignment/repository/RecordRepository.java) |
| SA-3 | Standard tech stack | Spring Boot 3.2.5 | ✅ | [pom.xml](pom.xml) |
| SA-4 | Connection pooling | HikariCP (Spring default) | ✅ | [application.properties](src/main/resources/application.properties) |
| SA-5 | Rolling updates | RollingUpdate strategy | ✅ | [nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L10) |
| SA-6 | 4 replicas | Deployment spec | ✅ | [nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L9) |
| SA-7 | External access | Ingress | ✅ | [nagpapp-ingress.yaml](k8s/app/nagpapp-ingress.yaml) |
| SA-8 | Self-healing | Liveness/Readiness probes | ✅ | [nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L48-L65) |
| SA-9 | HPA support | HorizontalPodAutoscaler | ✅ | [nagpapp-hpa.yaml](k8s/app/nagpapp-hpa.yaml) |
| DB-1 | Data table 5-10 records | init.sql with 6 records | ✅ | [postgres-initdb-configmap.yaml](k8s/database/postgres-initdb-configmap.yaml) |
| DB-2 | Data persistence | PersistentVolumeClaim | ✅ | [postgres-pvc.yaml](k8s/database/postgres-pvc.yaml) |
| DB-3 | Cluster-only access | ClusterIP service | ✅ | [postgres-service.yaml](k8s/database/postgres-service.yaml) |
| DB-4 | Pod recovery | Recreate strategy + PVC | ✅ | [postgres-deployment.yaml](k8s/database/postgres-deployment.yaml) |
| K8S-1 | ConfigMap for config | app-config ConfigMap | ✅ | [app-config.yaml](k8s/config/app-config.yaml) |
| K8S-2 | Secrets for passwords | app-secrets Secret | ✅ | [app-secrets.yaml](k8s/config/app-secrets.yaml) |
| K8S-3 | DNS (not Pod IPs) | postgres.public.svc | ✅ | [application.properties](src/main/resources/application.properties) |
| K8S-4 | Ingress exposure | nagpapp-ingress | ✅ | [nagpapp-ingress.yaml](k8s/app/nagpapp-ingress.yaml) |
| FO-1 | CPU/Memory requests | 100m/256Mi defined | ✅ | [nagpapp-deployment.yaml](k8s/app/nagpapp-deployment.yaml#L38-L40) |
| FO-2 | 3+ cost optimizations | 5 opportunities documented | ✅ | [FINOPS.md](FINOPS.md) |
| FO-3 | Resource optimization | Monitoring & adjustment plan | ✅ | [FINOPS.md](FINOPS.md#3-resource-optimization-based-on-observed-metrics) |


