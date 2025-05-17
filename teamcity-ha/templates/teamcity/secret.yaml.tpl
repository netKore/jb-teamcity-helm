{{ if $.Values.secrets.datadirConfig }}
---
apiVersion: v1
kind: secret
metadata:
  name: {{ $.Release.Name }}-datadir-secret
  namespace: {{ $.Values.teamcity.namespace }}
stringData:
{{ tpl ($.Values.secrets.datadirConfig | toYaml) $ | indent 4 }}
{{ end }}

