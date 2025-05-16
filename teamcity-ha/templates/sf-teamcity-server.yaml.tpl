---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $.Release.Name }}
  namespace: {{ $.Values.teamcity.namespace }}
spec:
  replicas: {{ len $.Values.teamcity.nodes }} #TODO
  serviceName: {{ $.Release.Name }}
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: {{ $.Release.Name }}
      component: server
  template:
    metadata:
      labels:
        app: {{ $.Release.Name }}
        component: server
    spec:
{{- if $.Values.serviceAccount.enabled }}
      serviceAccountName: {{ $.Release.Name }}
{{- end }}
      initContainers:
        - name: fix-perms
          image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
          env:
            - name: PASSWORD
              valueFrom:
                secretKeyRef:
                  name: teamcity-vcs-password
                  key: password
          command:
            - sh
            - -c
            - /init-script.sh

          volumeMounts:
            - name: teamcity-server-data
              mountPath: /data/teamcity_server/datadir
##TODO IMPROVE IT
            - name: init-script
              mountPath: /init-script.sh
              subPath: init-script.sh
            - name: vcs-init-config
              mountPath: /data/teamcity_server/vsc-init-config/vcs-init.xml
              subPath: vcs-init.xml
            - mountPath: /data/teamcity_server/project-config.xml
              name: teamcity-init-project
              subPath: project-config.xml
##TODO IMPROVE IT

      containers:
      - name: {{ $.Release.Name }}
        image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
        imagePullPolicy: {{ $.Values.image.pullPolicy }}
        command:
        - /run-services-wrp.sh
        env:
        {{- with $.Values.teamcity.env }}
        {{- range $key, $value := . }}
        - name: {{ $key }}
        {{- if kindIs "string" $value }}
        {{- $v := dict "value" (tpl $value $) }} #REVIEW TODO
        {{- toYaml $v | nindent 10 }}
        {{- else }}
          {{- tpl (toYaml $value) $ | nindent 10 }}
        {{- end }}
        {{- end }}
        {{- end }}
        livenessProbe: {{ $.Values.teamcity.livenessProbe | toJson }}
        readinessProbe: {{ $.Values.teamcity.readinessProbe | toJson }}
        ports: {{ $.Values.teamcity.ports | toJson}}
        resources: {{ $.Values.teamcity.resources | toJson }}
        volumeMounts:
        - mountPath: /data/teamcity_server/datadir
          name: teamcity-server-data
        {{ if $.Values.configMap.datadirConfig }}
        {{- range $key, $value := $.Values.configMap.datadirConfig }}
        - name: datadir-config
          mountPath: /data/teamcity_server/datadir/config/{{ $key }}
          subPath: {{ $key }}
        {{- end }}
        {{- end }}
        - mountPath: /run-services-wrp.sh
          name: startup-wrp
          subPath: run-services-wrp.sh
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
        - mountPath: /opt/teamcity/{{ $volume }}
          name: {{ $volume | lower | replace "." "dot" | replace "/" "-" | trimSuffix "-" }}
{{- end }}
{{- end }}
        - mountPath: /home/tcuser
          name: home-tcuser

        - name: internal-properties
          mountPath: /data/teamcity_server/datadir/config/internal.properties
          subPath: internal.properties
      volumes:
##TODO

      - name: teamcity-init-project ##CAN BE MULTIPLE PROJECTS PROBABLY
        configMap:
          defaultMode: 0644
          name: teamcity-init-project
      #TODO IMPROVE IT

      - name: internal-properties
        configMap:
          name: teamcity-init-internal-properties
          items:
            - key:  project-config.xml
              path: internal.properties
      - name: vcs-init-config
        configMap:
          defaultMode: 0644
          name: vcs-init-config
      - name: init-script
        configMap:
          defaultMode: 0755
          name: init-script
          optional: false
      #TODO IMPROVE IT
      {{ if $.Values.configMap.datadirConfig }}
      - name: datadir-config
        configMap:
          defaultMode: 0644
          name: {{ $.Release.Name }}-datadir-config
      {{ end }}
      {{ if $.Values.configMap.optConf }}
      - name: opt-conf
        configMap:
          defaultMode: 0644
          name: {{ $.Release.Name }}-opt-conf
      {{ end }}
      {{ if $.Values.configMap.services }}
      - name: services
        configMap:
          defaultMode: 0755
          name: {{ $.Release.Name }}-services
      {{ end }}
      - name: startup-wrp
        configMap:
          defaultMode: 0755
          name: {{ $.Release.Name }}-startup-wrp
          optional: false
      - name: teamcity-server-data
        persistentVolumeClaim:
          claimName: {{ $.Values.pvc.name }}
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if not $v_values.enabled }}
      - emptyDir: {}
        name: {{ $volume | lower | replace "." "dot" | replace "/" "-" | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
      - emptyDir: {}
        name: home-tcuser
      imagePullSecrets: {{ $.Values.image.imagePullSecrets | toJson }}
      {{- with $.Values.teamcity.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $.Values.teamcity.affinity }}
      affinity:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $.Values.teamcity.tolerations }}
      tolerations:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
  volumeClaimTemplates:
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if $v_values.enabled }}
  - metadata:
      name: {{ $volume | lower | replace "." "dot" | replace "/" "-" | trimSuffix "-" }}
      annotations: {{ $v_values.annotations | toJson }}
    spec:
      storageClassName: {{ $v_values.storageClassName }}
      accessModes: {{ $v_values.accessModes | toJson }}
      resources: {{ $v_values.resources | toJson }}
{{- end }}
{{- end }}
{{- end }}
