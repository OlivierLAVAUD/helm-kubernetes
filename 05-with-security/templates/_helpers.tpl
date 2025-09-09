{{/*
Expand the name of the chart.
*/}}
{{- define "simple-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "simple-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "simple-app.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.highAvailability.enabled }}
app.kubernetes.io/ha-enabled: "true"
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "simple-app.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "simple-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "simple-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ConfigMap name
*/}}
{{- define "simple-app.configMapName" -}}
{{- if .Values.nginxConfig.configMapName }}
{{- .Values.nginxConfig.configMapName }}
{{- else }}
{{- printf "%s-nginx-config" .Release.Name }}
{{- end }}
{{- end }}

{{/*
HPA name
*/}}
{{- define "simple-app.hpaName" -}}
{{- if .Values.autoscaling.hpaName }}
{{- .Values.autoscaling.hpaName }}
{{- else }}
{{- printf "%s-hpa" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PDB name
*/}}
{{- define "simple-app.pdbName" -}}
{{- printf "%s-pdb" .Release.Name }}
{{- end }}

{{/*
Role name
*/}}
{{- define "simple-app.roleName" -}}
{{- printf "%s-role" .Release.Name }}
{{- end }}

{{/*
RoleBinding name
*/}}
{{- define "simple-app.roleBindingName" -}}
{{- printf "%s-rolebinding" .Release.Name }}
{{- end }}

{{/*
NetworkPolicy name
*/}}
{{- define "simple-app.networkPolicyName" -}}
{{- printf "%s-networkpolicy" .Release.Name }}
{{- end }}

{{/*
Generate affinity settings for HA
*/}}
{{- define "simple-app.affinity" -}}
{{- if .Values.highAvailability.enabled }}
affinity:
  {{- if .Values.highAvailability.podAntiAffinity }}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - {{ .Chart.Name }}
          - key: app.kubernetes.io/instance
            operator: In
            values:
            - {{ .Release.Name }}
        topologyKey: {{ .Values.highAvailability.topologyKey | default "kubernetes.io/hostname" }}
  {{- end }}
  {{- if .Values.affinity }}
  {{- toYaml .Values.affinity | nindent 2 }}
  {{- end }}
{{- else if .Values.affinity }}
affinity:
  {{- toYaml .Values.affinity | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Generate topology spread constraints for HA
*/}}
{{- define "simple-app.topologySpreadConstraints" -}}
{{- if and .Values.highAvailability.enabled .Values.highAvailability.spreadConstraints }}
topologySpreadConstraints:
  {{- range .Values.highAvailability.spreadConstraints }}
  - maxSkew: {{ .maxSkew }}
    topologyKey: {{ .topologyKey }}
    whenUnsatisfiable: {{ .whenUnsatisfiable }}
    labelSelector:
      matchLabels:
        {{- include "simple-app.selectorLabels" $ | nindent 8 }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Generate security context for pod
*/}}
{{- define "simple-app.podSecurityContext" -}}
{{- if .Values.security.podSecurityContext }}
securityContext:
  {{- toYaml .Values.security.podSecurityContext | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Generate security context for container
*/}}
{{- define "simple-app.containerSecurityContext" -}}
{{- if .Values.image.securityContext }}
securityContext:
  {{- toYaml .Values.image.securityContext | nindent 2 }}
{{- end }}
{{- end }}