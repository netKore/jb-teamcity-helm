#TODO
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
         ENCRYPTED=$(java -jar /opt/teamcity/bin/encryption-cli-tool.jar "$PASSWORD" | tail -n 1)
         mkdir -p /data/teamcity_server/datadir/config/projects/TeamcityConfig/vcsRoots
         chmod -R 777  /data/teamcity_server/datadir/*
         sed "s|X_STUB_X|$ENCRYPTED|g"  /data/teamcity_server/vsc-init-config/vcs-init.xml > /data/teamcity_server/datadir/config/projects/TeamcityConfig/vcsRoots/TeamcityConfig_HttpsGithubComNetKoreTeamcityConfigGitRefsHeadsMain.xml
      fi
    fi
#TODO 777
#TODO PROJECT NAME TEMPLATE#

