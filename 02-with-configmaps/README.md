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