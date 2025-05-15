{{ if $.Values.configMap.datadirConfig }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-datadir-config
  namespace: {{ $.Values.teamcity.namespace }}
data:
{{ tpl ($.Values.configMap.datadirConfig | toYaml) $ | indent 4 }}
{{ end }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-startup-wrp
  namespace: {{ $.Values.teamcity.namespace }}
data:
  run-services-wrp.sh: |
    #!/bin/bash
    HOSTNAME=$(cat /etc/hostname)

    set -x
    case "$HOSTNAME" in
{{- range $index, $value := .Values.teamcity.nodes }}
    "{{ $.Release.Name }}-{{ $index }}")
      export ROOT_URL=http://{{ $.Release.Name }}-{{ $index }}.{{ $.Release.Name }}-headless.{{ $.Release.Namespace}}:8111
      export NODE_ID={{ $.Release.Name }}-{{ $index }}
      {{- with $value.env }}
      {{- range $e, $value := . }}
      export {{ $e }}="{{ tpl ($value) $ }}"
      {{- end }}
      {{- end }}
      export TEAMCITY_SERVER_OPTS="-Dteamcity.server.nodeId=${NODE_ID} -Dteamcity.server.rootURL=${ROOT_URL} $TEAMCITY_SERVER_OPTS"
      {{- if $value.responsibilities }}
      echo Override server responsibilities
      export TEAMCITY_SERVER_OPTS="-Dteamcity.server.responsibilities={{ join "," $value.responsibilities }} $TEAMCITY_SERVER_OPTS"
      {{- end }}
      exec /run-services.sh
    ;;
{{- end }}
    esac
