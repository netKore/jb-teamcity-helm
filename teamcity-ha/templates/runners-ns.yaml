{{- if .Values.agentNamespace }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.agentNamespace | quote }}
  labels:
    app: {{ include "teamcity-ha.fullname" . }}
{{- end }}
