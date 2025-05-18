{{- if .Values.serviceAccount.enabled }}
{{- if .Values.serviceAccount.agentRBAC.enabled }}

# Role для доступа к pods в agentNamespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: "{{ .Release.Name }}-agent-second-ns-ctrl"
  namespace: "{{ .Values.agentNamespace }}"
  labels:
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: "{{ .Release.Name }}"
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create", "delete", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["podtemplates"]
    verbs: ["get", "list"]

---

# RoleBinding для agentNamespace
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: "{{ .Release.Name }}-agent-second-ns-ctrl-binding"
  namespace: "{{ .Values.agentNamespace }}"
  labels:
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: "{{ .Release.Name }}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: "{{ .Release.Name }}-agent-second-ns-ctrl"
subjects:
  - kind: ServiceAccount
    name: "{{ .Release.Name }}"
    namespace: "{{ .Values.teamcity.namespace }}"

---

# ClusterRole для доступа к namespaces (кластерный ресурс)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "{{ .Release.Name }}-agent-namespaces-ctrl"
  labels:
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: "{{ .Release.Name }}"
rules:
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "list"]

---

# ClusterRoleBinding для namespaces
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: "{{ .Release.Name }}-agent-namespaces-ctrl-binding"
  labels:
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: "{{ .Release.Name }}"
roleRef:
  kind: ClusterRole
  name: "{{ .Release.Name }}-agent-namespaces-ctrl"
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: "{{ .Release.Name }}"
    namespace: "{{ .Values.teamcity.namespace }}"

{{- end }}
{{- end }}