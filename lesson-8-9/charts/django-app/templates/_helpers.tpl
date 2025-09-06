{{- define "django-app.fullname" -}}
{{ .Release.Name }}-django
{{- end }}

{{- define "django-app.name" -}}
django
{{- end }}

{{- define "django-app.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}
