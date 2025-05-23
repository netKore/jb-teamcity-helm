{{- if $.Values.teamcity.vcsRootConfiguration.enabled }}
{{- with $.Values.teamcity.vcsRootConfiguration.ghAccess.configuration }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vcs-init-config
  namespace: {{ $.Values.teamcity.namespace }}
data:
   vcs-init.xml: |
        <?xml version="1.0" encoding="UTF-8"?>
        <vcs-root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" uuid="" type="jetbrains.git" xsi:noNamespaceSchemaLocation="https://www.jetbrains.com/teamcity/schemas/2025.3/project-config.xsd">
          <name>{{ .url }}</name>
          <param name="agentCleanFilesPolicy" value="ALL_UNTRACKED" />
          <param name="agentCleanPolicy" value="ON_BRANCH_CHANGE" />
          <param name="branch" value="{{ .branch }}" />
          <param name="ignoreKnownHosts" value="true" />
          <param name="submoduleCheckout" value="CHECKOUT" />
          <param name="url" value="{{ .url }}" />
          <param name="useAlternates" value="AUTO" />
          <param name="usernameStyle" value="USERID" />
{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.password }}
          <param name="authMethod" value="PASSWORD" />
          <param name="username" value="{{ .username }}" />
          <param name="secure:password" value="X_STUB_X" />
{{- end }}
{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.cert }}
          <param name="authMethod" value="PRIVATE_KEY_FILE" />
          <param name="privateKeyPath" value="/data/teamcity_server/secrets/gh.key" />
{{- end }}
{{- if $.Values.teamcity.vcsRootConfiguration.ghAccess.auth.ghAnnonumous }}
          <param name="authMethod" value="ANONYMOUS" />
{{- end }}
        </vcs-root>


---
apiVersion: v1
kind: ConfigMap
metadata:
  name: teamcity-init-project
  namespace: {{ $.Values.teamcity.namespace }}
data:
  project-config.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" uuid="" xsi:noNamespaceSchemaLocation="https://www.jetbrains.com/teamcity/schemas/2025.3/project-config.xsd">
      <name>&lt;Root project&gt;</name>
      <description>Contains all other projects</description>
      <project-extensions>
        <extension id="PROJECT_EXT_1" type="versionedSettings">
          <parameters>
            <param name="buildSettings" value="PREFER_VCS" />
            <param name="credentialsStorageType" value="credentialsJSON" />
            <param name="enabled" value="true" />
            <param name="format" value="kotlin" />
            <param name="ignoreChangesInDependenciesAndVcsSettings" value="false" />
            <param name="rootId" value="VCSDefaultConfigGit" />
            <param name="showChanges" value="false" />
            <param name="useRelativeIds" value="true" />
          </parameters>
        </extension>
      </project-extensions>
      <cleanup>
        <options>
          <option name="preventDependenciesArtifactsFromCleanup" value="false" />
        </options>
      </cleanup>
    </project>

{{- end }}
{{- end }}
