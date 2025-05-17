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
  password: {{ $.Files.Get .tokenAuth.tokenPath }}
{{- end }}

---

{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.cert }}
apiVersion: v1
kind: Secret
metadata:
  name: teamcity-vcs-certificate
  namespace: {{ $.Values.teamcity.namespace }}
type: Opaque ##TODO RETHINK kubernetes.io/tls
data:
  password: {{ $.Files.Get $.Values.teamcity.vcsRootConfiguration.ghAccess.configuration.certAuth.certPath | b64enc }}
{{- end }}
{{- end }}