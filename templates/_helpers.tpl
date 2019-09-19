{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "uname" -}}
{{ .Values.clusterName | lower }}-{{ .Values.nodeGroup }}
{{- end -}}

{{- define "appname" -}}
{{- default "logstashapi" .Values.appname | lower | trunc 16 | trimSuffix "-" -}}
{{- end -}}

{{- define "clusterName" -}}
{{- default "cluster" .Values.clusterName | lower -}}
{{- end -}}

{{- define "nodeGroup" -}}
{{- default "group" .Values.nodeGroup | lower -}}
{{- end -}}

{{- define "company" -}}
{{- default "co" .Values.company | lower | trunc 3 | trimSuffix "-" -}}
{{- end -}}

{{- define "environment" -}}
{{- default "dev" .Values.environment | lower | trunc 3 | trimSuffix "-" -}}
{{- end -}}

{{- define "namespace" -}}
{{include "company" . }}-{{include "appname" . }}-{{include "environment" . }}
{{- end -}}

{{- define "claimName" -}}
{{include "appname" . }}-{{include "clusterName" . }}-{{include "nodeGroup" . }}
{{- end -}}