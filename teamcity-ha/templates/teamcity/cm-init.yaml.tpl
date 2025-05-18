apiVersion: v1
kind: ConfigMap
metadata:
  name: init-script
  namespace: {{ $.Values.teamcity.namespace }}
data:
  init-script.sh: |
    #!/bin/bash
    HOSTNAME=$(cat /etc/hostname)
    initfile=${TEAMCITY_DATA_PATH}/system/dataDirectoryInitialized
    if [ "$HOSTNAME" == "{{ $.Release.Name }}-0" ]; then
      if [ ! -f $initfile ]; then
         mkdir -p /data/teamcity_server/datadir/config/projects/_Root/vcsRoots
{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.password }}
         ENCRYPTED=$(java -jar /opt/teamcity/bin/encryption-cli-tool.jar "$PASSWORD" | tail -n 1)
         sed "s|X_STUB_X|$ENCRYPTED|g"  /data/teamcity_server/vsc-init-config/vcs-init.xml > /data/teamcity_server/vsc-init-config/vcs-init.xml
{{- end }}
         cp /data/teamcity_server/vsc-init-config/vcs-init.xml /data/teamcity_server/datadir/config/projects/_Root/vcsRoots/VCSDefaultConfigGit.xml
         cp /data/teamcity_server/project-config.xml /data/teamcity_server/datadir/config/projects/_Root/project-config.xml
      fi
    fi


