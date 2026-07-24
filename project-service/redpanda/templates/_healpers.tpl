{{/* Базовое имя чарта */}}
{{- define "redpanda.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Полное имя ресурса */}}
{{- define "redpanda.fullname" -}}
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

{{/* Имя headless-сервиса для StatefulSet */}}
{{- define "redpanda.headlessName" -}}
{{- printf "%s-headless" (include "redpanda.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "redpanda.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "redpanda.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: database
{{- end }}

{{- define "redpanda.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redpanda.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "redpanda.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/* Имя секрета с паролем */}}
{{- define "redpanda.secretName" -}}
{{- .Values.auth.existingSecret | default (include "redpanda.fullname" .) }}
{{- end }}

{{- define "redpanda.validateValues" -}}
{{- if not .Values.ports }}
{{- fail "ports are required" }}
{{- end }}
{{- if not .Values.config }}
{{- fail "config is required" }}
{{- end }}
{{- if not .Values.mount }}
{{- fail "mount is required" }}
{{- end }}
{{- end }}

{{- define "redpanda.kafka_port" -}}
{{- dig "kafka" "port" .Values.ports.kafka_api (.Values.global | default dict) -}}
{{- end }}