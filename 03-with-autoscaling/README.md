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

3. View the application logs:
  kubectl logs -f deployment/{{ .Release.Name }} -n {{ .Release.Namespace }}

{{- if .Values.autoscaling.enabled }}
4. Monitor HPA status:
  kubectl get hpa {{ include "simple-app.hpaName" . }} -n {{ .Release.Namespace }} -w
{{- end }}




helm install my-app . --set autoscaling.enabled=true

kubectl get hpa my-app-hpa
kubectl describe hpa my-app-hpa


# Installer hey pour les tests de charge
go install github.com/rakyll/hey@latest

# Lancer un test de charge
hey -n 10000 -c 100 http://votre-service