{{- with $.Values.persistence }}
----
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