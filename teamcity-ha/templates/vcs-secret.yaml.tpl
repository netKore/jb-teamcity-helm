{{- if .Values.teamcity.vcs.password }}
apiVersion: v1
kind: Secret
metadata:
  name: teamcity-vcs-password
  namespace: {{ .Values.teamcity.namespace }}
type: Opaque
stringData:
  password: {{ .Values.teamcity.vcs.password | quote }}
{{- end }}
