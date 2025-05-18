{{- if $.Values.teamcity.vcsRootConfiguration.enabled }}
{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.password }}
---
apiVersion: v1
kind: Secret
metadata:
  name: teamcity-vcs-password
  namespace: {{ $.Values.teamcity.namespace }}
type: Opaque
stringData:
  password: {{ $.Values.teamcity.vcsRootConfiguration.ghAccess.configuration.tokenAuth.token }}
{{- end }}

---

{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.cert }}
apiVersion: v1
kind: Secret
metadata:
  name: teamcity-vcs-certificate
  namespace: {{ $.Values.teamcity.namespace }}
type: Opaque
data:
  gh.key: {{ $.Values.teamcity.vcsRootConfiguration.ghAccess.configuration.certAuth.cert }}
{{- end }}
{{- end }}