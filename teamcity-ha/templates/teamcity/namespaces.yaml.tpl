apiVersion: v1
kind: Namespace
metadata:
  name: {{ $.Values.teamcity.namespace | quote }}
  labels:
    app: {{ $.Release.Name }}

---

{{- if .Values.agentNamespace }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.agentNamespace | quote }}
  labels:
    app: {{ $.Release.Name }}
{{- end }}
