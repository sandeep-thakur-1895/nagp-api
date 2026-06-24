# FinOps Optimization Strategy

## 1. Resource Requests & Limits (Implemented)

### Service/API Tier (nagpapp)
- **CPU Requests**: 100m (min guaranteed)
- **CPU Limits**: 500m (max allowed)
- **Memory Requests**: 256Mi (min guaranteed)
- **Memory Limits**: 512Mi (max allowed)

These values are optimized based on Spring Boot typical resource consumption, preventing over-provisioning while maintaining performance.

---

## 2. Cost Optimization Opportunities

### Opportunity #1: Vertical Pod Autoscaling (VPA)
**Current State**: Fixed resource requests/limits
**Optimization**: Implement Vertical Pod Autoscaler to dynamically adjust CPU/memory based on actual usage patterns.

**Expected Impact**:
- Reduces wasted reserved resources (unused allocations)
- Automatically scales down underutilized pods
- Cost savings: 15-30% reduction in over-provisioned resources

**Implementation**:
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: nagpapp-vpa
  namespace: public
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: nagpapp-deployment
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: nagpapp-container
      minAllowed:
        cpu: 50m
        memory: 128Mi
      maxAllowed:
        cpu: 1000m
        memory: 1Gi
```

### Opportunity #2: Pod Disruption Budgets (PDB) + Bin Packing
**Current State**: HPA scales 2-6 replicas without cluster-level optimization
**Optimization**: Implement PDB to allow controlled disruptions during cluster scaling, enabling better node bin-packing and cluster consolidation.

**Expected Impact**:
- Enables cluster autoscaler to consolidate nodes
- Reduces number of underutilized nodes
- Cost savings: 20-40% reduction in node infrastructure costs

**Implementation**:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nagpapp-pdb
  namespace: public
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: nagpapp
```

### Opportunity #3: Right-Sizing Database Resources & Storage Optimization
**Current State**: 
- PostgreSQL runs with no resource limits
- PVC allocated 1Gi with standard storage class

**Optimization**: 
- Add resource requests/limits to database tier
- Use cheaper storage tiers for non-critical data, cheaper retention policies

**Expected Impact**:
- Prevents database from consuming unlimited resources
- Allocates resources efficiently (500m CPU, 256Mi base memory)
- Cost savings: 25-35% on database infrastructure + storage optimization

**Implementation**:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

# Storage: Consider using standard-rwo instead of standard
storageClassName: standard-rwo  # Regional redundancy not needed for test cluster
```

---

## 3. Resource Optimization Based on Observed Metrics

### Monitoring Strategy
**Tools**: Kubernetes Metrics Server + Prometheus (optional)

**Key Metrics to Monitor**:
1. **CPU Utilization**: `container_cpu_usage_seconds_total`
   - Target: 60-70% average utilization
   - Action: If consistently <30%, reduce CPU limit; if >85%, increase

2. **Memory Utilization**: `container_memory_working_set_bytes`
   - Target: 70-80% of requested memory
   - Action: If consistently <50%, reduce memory request; if >90%, increase limit

3. **Pod Count**: Driven by HPA metrics
   - Current: 2-6 replicas based on 50% CPU utilization
   - Opportunity: Adjust target utilization to 70% to run fewer replicas

### Optimization Actions

#### Action 1: Adjust HPA Target CPU Utilization
**Current**: 50% average utilization
**Proposed**: 70% average utilization
**Benefit**: Reduces average pod count by 1-2 replicas (15-30% compute savings)

```yaml
# Modified HPA configuration
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Increased from 50%
```

#### Action 2: Right-Size Resource Requests Based on Metrics
**Current Requests**: 100m CPU, 256Mi memory
**Analyze**: 
- If 95th percentile CPU < 50m, reduce to 75m
- If 95th percentile Memory < 200Mi, reduce to 192Mi
- If 95th percentile shows spikes, adjust limits appropriately

#### Action 3: Implement Horizontal Pod Consolidation
- Reduce `minReplicas` from 2 to 1 for off-peak hours
- Use scheduled scaling to 2 replicas during business hours
- Cost savings: 50% during off-peak

```yaml
# Scheduled downscaling (requires KEDA or cron jobs)
minReplicas: 1  # During off-peak (9 PM - 9 AM)
maxReplicas: 6
```

---

## 4. Cost Optimization Summary Table

| Optimization | Implementation Effort | Estimated Savings | Priority |
|---|---|---|---|
| VPA (Vertical Pod Autoscaler) | Medium (requires VPA controller) | 15-30% | High |
| PDB + Bin Packing | Low (YAML only) | 20-40% | High |
| Right-Size Database | Low (YAML changes) | 25-35% | High |
| Adjust HPA Target Utilization | Very Low (config change) | 15-25% | Medium |
| Scheduled Scaling | Medium (requires scheduler) | 50% off-peak | Medium |

**Total Potential Savings**: 75-165% (combined effect of all optimizations)

---

## 5. Monitoring & Continuous Optimization

### Monthly Review Process
1. Collect metrics from Kubernetes cluster (CPU, memory, pod count)
2. Analyze cost trends and identify anomalies
3. Adjust resource requests/limits based on 95th percentile metrics
4. Update HPA parameters if cluster is consistently over/under provisioned
5. Review storage usage and clean up unused PVCs

### Tools to Deploy
- **Metrics Server** (already in most K8s clusters)
- **Prometheus** (optional, for historical metrics)
- **Kubernetes Dashboard** (for visualization)
- **kubecost** (optional, for actual cost tracking)

---

## Next Steps

1. ✅ Deploy current configuration with defined resource requests/limits
2. ⏳ Monitor for 2 weeks to collect baseline metrics
3. ⏳ Implement VPA for dynamic resource adjustment
4. ⏳ Implement PDB for better node consolidation
5. ⏳ Fine-tune HPA parameters based on observed utilization patterns
