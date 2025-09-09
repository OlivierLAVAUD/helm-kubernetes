# tTests

# Simuler la suppression d'un pod
kubectl delete pod my-app-fd46d598c-85rrm

# Observer le rescheduling automatique
kubectl get pods -w

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

4. Check HA status:
  kubectl describe deployment {{ .Release.Name }} -n {{ .Release.Namespace }}

{{- if .Values.highAvailability.enabled }}
5. Check PodDisruptionBudget:
  kubectl get pdb {{ include "simple-app.pdbName" . }} -n {{ .Release.Namespace }}
{{- end }}

{{- if .Values.autoscaling.enabled }}
6. Monitor HPA status:
  kubectl get hpa {{ include "simple-app.hpaName" . }} -n {{ .Release.Namespace }} -w
{{- end }}

7. View application logs:
  kubectl logs -f deployment/{{ .Release.Name }} -n {{ .Release.Namespace }}