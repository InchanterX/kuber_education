{{/* Base name */}}
{{- define "project.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end}}

{{/* Full name */}}
{{- define "project.fullname" -}}
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

{{/* deployment name */}}
{{- define "project.deployment" -}}
{{- printf "%s-deployment" (include "project.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* config map name */}}
{{- define "project.config" -}}
{{- printf "%s-config" (include "project.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* migration name */}}
{{- define "project.migration" -}}
{{- printf "%s-migration" (include "project.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* ingress name */}}
{{- define "project.ingress" -}}
{{- printf "%s-ingress" (include "project.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* service name */}}
{{- define "project.service" -}}
{{- printf "%s-service" (include "project.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "project.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "project.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: microservice
{{- end }}

{{- define "project.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "project.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{- define "project.validateValues" -}}
{{- if not .Values.parameters }}
{{- fail "parameters are required" }}
{{- end }}
{{- if not .Values.postgres }}
{{- fail "postgres data is required" -}}
{{- end }}
{{- if not .Values.kafka }}
{{- fail "kafka data is required" -}}
{{- end }}
{{- end }}

{{- define "project.pg_database" -}}
{{- dig "postgres" "database" .Values.postgres.database (.Values.global | default dict) -}}
{{- end }}

{{- define "project.pg_user" -}}
{{- dig "postgres" "user" .Values.postgres.user (.Values.global | default dict) -}}
{{- end }}

{{- define "project.pg_port" -}}
{{- dig "postgres" "port" .Values.postgres.port (.Values.global | default dict) -}}
{{- end }}

{{- define "project.kafka_port" -}}
{{- dig "kafka" "port" .Values.kafka.port (.Values.global | default dict) -}}
{{- end }}

{{- define "project.pgChartName" -}}
{{- dig "postgres" "chartName" (.Values.postgres.chartName | default "postgres") (.Values.global | default dict) -}}
{{- end }}

{{- define "project.kafkaChartName" -}}
{{- dig "kafka" "chartName" (.Values.kafka.chartName | default "redpanda") (.Values.global | default dict) -}}
{{- end }}

{{- define "project.pgFullname" -}}
{{- $name := include "project.pgChartName" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name -}}
{{- end -}}
{{- end }}

{{- define "project.kafkaFullname" -}}
{{- $name := include "project.kafkaChartName" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name -}}
{{- end -}}
{{- end }}

{{- define "project.postgres_host" -}}
{{- printf "%s-service" (include "project.pgFullname" .) -}}
{{- end }}

{{- define "project.kafka_host" -}}
{{- printf "%s-service" (include "project.kafkaFullname" .) -}}
{{- end }}

{{- define "project.postgres_secretName" -}}
{{- include "project.pgFullname" . -}}
{{- end }}