{{/* Базовое имя чарта */}}
{{- define "postgres.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Полное имя ресурса */}}
{{- define "postgres.fullname" -}}
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
{{- define "postgres.headlessName" -}}
{{- printf "%s-headless" (include "postgres.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "postgres.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "postgres.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: database
{{- end }}

{{- define "postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgres.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "postgres.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/* Имя секрета с паролем */}}
{{- define "postgres.secretName" -}}
{{- .Values.auth.existingSecret | default (include "postgres.fullname" .) }}
{{- end }}

{{- define "postgres.validateValues" -}}
{{- if not .Values.auth.database }}
{{- fail "auth.database is required" }}
{{- end }}
{{- if and (not .Values.auth.password) (not .Values.auth.existingSecret) }}
{{- fail "either auth.password or auth.existingSecret must be set" }}
{{- end }}
{{- end }}

{{- define "postgres.pg_user" -}}
{{- dig "postgres" "user" .Values.auth.name (.Values.global | default dict) -}}
{{- end }}

{{- define "postgres.pg_port" -}}
{{- dig "postgres" "port" .Values.service.port (.Values.global | default dict) -}}
{{- end }}

{{- define "postgres.pg_database" -}}
{{- dig "postgres" "database" .Values.auth.database (.Values.global | default dict) -}}
{{- end }}