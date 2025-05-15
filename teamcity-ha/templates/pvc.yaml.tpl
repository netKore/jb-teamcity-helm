{{- with $.Values.pvc }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .name }}
  namespace: {{ $.Values.teamcity.namespace }}
  annotations:
{{ .annotations | toYaml | indent 4 }}
spec:
  accessModes: {{ .accessModes | toJson }}
  resources: {{ .resources | toJson }}
  storageClassName: {{ .storageClassName }}
{{- end }}
