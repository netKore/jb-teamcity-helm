{{- if $.Values.persistence.enabled }}
{{- with $.Values.persistence }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .name }}
  namespace: {{ $.Values.teamcity.namespace }}
  annotations:
    {{ .annotations | toYaml | indent 4 }}
spec:
  storageClassName: {{ .storageClassName }}
  accessModes: {{ .accessModes | toJson }}
  capacity:
    storage: {{ .size }}
  hostPath:
    path: /www/
{{- end }}
{{- end }}
