{{- with $.Values.pvc }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .name }}
  annotations:
{{ .annotations | toYaml | indent 4 }}
spec:
  accessModes: {{ .accessModes | toJson }}
  resources: {{ .resources | toJson }}
  storageClassName: {{ .storageClassName }}
{{- end }}
----
{{- with $.Values.persistence }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .name }}-pv
spec:
  storageClassName: standard
  accessModes:
    - {{ .accessModes | toJson }}
  capacity:
    storage: {{ .size }}
  hostPath:
    path: /www/
{{- end }}