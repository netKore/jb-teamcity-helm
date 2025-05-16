{{- if $.Values.serviceAccount.enabled }}
{{- if $.Values.serviceAccount.agentRBAC.enabled }}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $.Release.Name }}-agent-ctrl
  namespace: {{ $.Values.teamcity.namespace }}
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create", "delete", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["podtemplates"]
    verbs: ["get","list"]
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "list"]
---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $.Release.Name }}-agent-ctrl
  namespace: {{ $.Values.teamcity.namespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $.Release.Name }}-agent-ctrl
subjects:
  - kind: ServiceAccount
    name: {{ $.Release.Name }}
---

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $.Release.Name }}-agent-second-ns-ctrl
  namespace: {{ .Values.agentNamespace | quote }}
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create", "delete", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["podtemplates"]
    verbs: ["get","list"]
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "list"]
---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $.Release.Name }}-agent-second-ns-ctrl
  namespace: {{ .Values.agentNamespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $.Release.Name }}-agent-second-ns-ctrl
subjects:
  - kind: ServiceAccount
    name: {{ $.Release.Name }}
{{- end }}
{{- end }}
