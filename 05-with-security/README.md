# RBAC
## Cette implémentation de sécurité suit les meilleures pratiques du modèle de sécurité zero-trust et fournit une base solide pour le déploiement d'applications sécurisées dans Kubernetes

1.Activer le ServiceAccount et RBAC :
```bash
serviceAccount:
  create: true
  name: "simple-app-sa"
  rbac:
    create: true

```
Activer les contextes de sécurité :

helm install my-app . --set serviceAccount.create=true --set image.securityContext.enabled=true --set security.podSecurityContext.enabled=true
```
2. Activer les contextes de sécurité :

```bash
image:
  securityContext:
    enabled: true
security:
  podSecurityContext:
    enabled: true
```
3. Activer les Network Policies :

```bash
security:
  networkPolicy:
    enabled: true
```

4. Installer avec la sécurité renforcée :

```bash
helm install my-app . --set serviceAccount.create=true --set image.securityContext.enabled=true --set security.podSecurityContext.enabled=true
```


# Effacer un precedente installation 

1. Vérifier les releases Helm existantes

helm list --all
helm list --all-namespaces

2.  Nettoyer complètement la release précédente

# Supprimer la release spécifique
helm uninstall my-app

# Si elle résiste, forcer la suppression
helm uninstall my-app --no-hooks

# Vérifier les ressources orphelines
kubectl get all -l app.kubernetes.io/instance=my-app

3. Supprimer manuellement les ressources restantes

# Supprimer les ressources par label
kubectl delete all -l app.kubernetes.io/instance=my-app

# Supprimer les ServiceAccounts
kubectl delete serviceaccount -l app.kubernetes.io/instance=my-app

# Supprimer les Roles et RoleBindings
kubectl delete role,rolebinding -l app.kubernetes.io/instance=my-app

# Supprimer les ConfigMaps
kubectl delete configmap -l app.kubernetes.io/instance=my-app

# Vérifier que tout est supprimé
kubectl get all,serviceaccount,role,rolebinding,configmap -l app.kubernetes.io/instance=my-app

# Utiliser un nom différent pour la nouvelle installation
helm install my-app-security . --timeout 5m0s

5. Supprimer tout

# Nuclear option - tout supprimer dans le namespace default
kubectl delete all --all
kubectl delete serviceaccount --all
kubectl delete role,rolebinding --all
kubectl delete configmap --all

# Réinitialiser Minikube si nécessaire
minikube stop
minikube delete
minikube start

6. Vérifier l'état final

# Vérifier qu'aucune ressource n'existe avec le label
kubectl get all,serviceaccount,role,rolebinding,configmap -l app.kubernetes.io/instance=my-app

# Vérifier les releases Helm
helm list --all-namespaces

# 05 Install
# Revenir au répertoire du niveau 05
cd ~/dev/helm-kubernetes/05-with-security

# Installer avec un nom propre
helm install my-app . --timeout 5m0s

# Ou si vous préférez un nom différent
helm install my-app-secure . --timeout 5m0s



# Notes

{{- if .Values.highAvailability.enabled }}
🚀 High Availability Mode ENABLED
   Replicas: {{ .Values.highAvailability.minReplicas }}
   Pod Anti-Affinity: {{ .Values.highAvailability.podAntiAffinity }}
   PDB: {{ if .Values.highAvailability.podDisruptionBudget.enabled }}Enabled (minAvailable: {{ .Values.highAvailability.podDisruptionBudget.minAvailable }}){{ else }}Disabled{{ end }}
{{- else }}
ℹ️  High Availability Mode DISABLED
   To enable HA, set highAvailability.enabled=true in your values
{{- end }}

{{- if .Values.autoscaling.enabled }}
🎯 Horizontal Pod Autoscaler is ENABLED
   Min replicas: {{ .Values.autoscaling.minReplicas }}
   Max replicas: {{ .Values.autoscaling.maxReplicas }}
   CPU Target: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}%
   Memory Target: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}%
{{- else }}
ℹ️  Horizontal Pod Autoscaler is DISABLED
   To enable autoscaling, set autoscaling.enabled=true in your values
{{- end }}

{{- if .Values.serviceAccount.create }}
🔐 Service Account: {{ include "simple-app.serviceAccountName" . }}
   RBAC: {{ if .Values.serviceAccount.rbac.create }}Enabled{{ else }}Disabled{{ end }}
{{- else }}
ℹ️  Using default service account
{{- end }}

{{- if .Values.security.networkPolicy.enabled }}
🌐 Network Policy: Enabled
{{- else }}
ℹ️  Network Policy: Disabled
{{- end }}

1. Get the application URL by running these commands:
{{- if .Values.ingress.enabled }}
{{- range .Values.ingress.hosts }}
  http{{ if $.Values.ingress.tls }}s{{ end }}://{{ .host }}{{ range .paths }}{{ .path }}{{ end }}
{{- end }}
{{- else if contains "LoadBalancer" .Values.service.type }}
  export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "simple-app.fullname" . }}-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo http://$SERVICE_IP:{{ .Values.service.port }}
{{- else if contains "ClusterIP" .Values.service.type }}
  kubectl port-forward svc/{{ include "simple-app.fullname" . }}-service {{ .Values.service.port }}:{{ .Values.service.port }} --namespace {{ .Release.Namespace }}
{{- end }}

2. Check the deployment status:
  kubectl get deployments -n {{ .Release.Namespace }}

3. View pod distribution:
  kubectl get pods -n {{ .Release.Namespace }} -o wide

4. Check security context:
  kubectl describe pod -l app.kubernetes.io/instance={{ .Release.Name }} -n {{ .Release.Namespace }}

{{- if .Values.serviceAccount.create }}
5. Check Service Account and RBAC:
  kubectl describe serviceaccount {{ include "simple-app.serviceAccountName" . }} -n {{ .Release.Namespace }}
  {{- if .Values.serviceAccount.rbac.create }}
  kubectl describe role {{ include "simple-app.roleName" . }} -n {{ .Release.Namespace }}
  kubectl describe rolebinding {{ include "simple-app.roleBindingName" . }} -n {{ .Release.Namespace }}
  {{- end }}
{{- end }}

{{- if .Values.highAvailability.enabled }}
6. Check PodDisruptionBudget:
  kubectl get pdb {{ include "simple-app.pdbName" . }} -n {{ .Release.Namespace }}
{{- end }}

{{- if .Values.autoscaling.enabled }}
7. Monitor HPA status:
  kubectl get hpa {{ include "simple-app.hpaName" . }} -n {{ .Release.Namespace }} -w
{{- end }}

8. View application logs:
  kubectl logs -f deployment/{{ .Release.Name }} -n {{ .Release.Namespace }}