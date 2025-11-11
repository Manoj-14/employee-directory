{{/*
Expand the name of the chart.
*/}}
{{- define "emp-dir-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "emp-dir-helm.fullname" -}}
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

{{- define "emp-dir-helm.configMapName" -}}
{{ printf "%s-configmap" (include "emp-dir-helm.fullname" . ) | trim }}
{{- end -}}

{{- define "emp-dir-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
# Common Labels
{{- define "emp-dir-helm.labels" -}}
helm.sh/chart: {{ include "emp-dir-helm.chart" . }}
{{ include "emp-dir-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
# Common Selectors
{{- define "emp-dir-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "emp-dir-helm.name" . }}
app: {{ include "emp-dir-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
