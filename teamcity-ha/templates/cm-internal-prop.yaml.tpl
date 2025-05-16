#internal.properties
apiVersion: v1
kind: ConfigMap
metadata:
  name: teamcity-init-internal-properties
data:
  project-config.xml: |
    teamcity.kubernetes.localServiceAccount.enable=true