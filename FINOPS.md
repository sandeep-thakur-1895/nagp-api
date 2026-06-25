# FinOps Notes

## 1. Current Resource Settings

### Service/API Tier (nagpapp)
- **CPU request**: 100m
- **CPU limit**: 500m
- **Memory request**: 256Mi
- **Memory limit**: 512Mi

These are the current settings for the API pod. The request values are what Kubernetes reserves for the pod, and the limit values are the maximum it can use.

---

## 2. What can be improved

### A. Vertical Pod Autoscaler (VPA)
Right now the app uses fixed CPU and memory values. VPA can adjust those values automatically based on actual usage.

Benefits:
- Uses less reserved capacity when the app is idle
- Gives the app more resources when it needs them
- Helps reduce waste

Example:
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: nagpapp-vpa
  namespace: public
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nagpapp-deployment
  updatePolicy:
    updateMode: Auto
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

### B. Pod Disruption Budget (PDB)
A PDB helps the cluster manage pod restarts and scaling without taking down the service.

Example:
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

### C. Database resource limits
The PostgreSQL pod currently has no limits. That means it could use more CPU or memory than expected.

Recommended settings:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
storageClassName: standard-rwo
```

---

## 3. What to watch in the cluster

### CPU
- Aim for about 60-70% average CPU use
- If it is consistently below 30%, we can lower the request
- If it is above 85%, we should raise the limit

### Memory
- Aim for 70-80% of the requested memory
- If it is below 50%, we can lower the request
- If it is above 90%, we should increase the limit

### Pod count
- Current HPA target is 50% CPU
- Raising that to 70% can reduce the number of pods
- That saves compute costs without hurting performance

---

## 4. Simple action plan

1. Keep the current resource requests and limits for now.
2. Add VPA so resource settings can adjust automatically.
3. Add a PDB so the app can handle maintenance and scaling better.
4. Set limits for PostgreSQL so the database does not grow out of control.
5. Watch the cluster for 2 weeks to collect usage data and adjust accordingly.

---

## 5. Cost optimization summary

| Optimization | Implementation Effort | Estimated Savings | Priority |
|---|---|---|---|
| VPA (Vertical Pod Autoscaler) | Medium (requires VPA controller) | 15-30% | High |
| PDB + Bin Packing | Low (YAML only) | 20-40% | High |
| Right-Size Database | Low (YAML changes) | 25-35% | High |
| Adjust HPA Target Utilization | Very Low (config change) | 15-25% | Medium |
| Scheduled Scaling | Medium (requires scheduler) | 50% off-peak | Medium |

**Total Potential Savings**: 75-165% (combined effect of all optimizations)

---

## 6. Quick summary

- `requests` are the minimum resources Kubernetes reserves.
- `limits` are the max resources the pod can use.
- These settings help the app run steadily while avoiding waste.
- VPA and PDB are the next steps to make resource use smarter.
- Database pod limits should be added to keep costs under control.
