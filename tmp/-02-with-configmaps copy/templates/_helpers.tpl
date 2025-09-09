{{- define "simple-app.labels" -}}
app: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
heritage: Helm
{{- end }}

{{- define "simple-app.selectorLabels" -}}
app: {{ .Release.Name }}
{{- end }}