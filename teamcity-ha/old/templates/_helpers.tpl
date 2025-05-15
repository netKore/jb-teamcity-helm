{{- define "teamcity-ha.fullname" -}}
{{- if .Chart.Name -}}
{{- .Chart.Name | lower }}
{{- else -}}
teamcity-ha
{{- end -}}
{{- end -}}
