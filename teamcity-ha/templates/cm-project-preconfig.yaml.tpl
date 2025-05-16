{{ if $.Values.configMap.datadirConfig }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vcs-init-config
  namespace: {{ $.Values.teamcity.namespace }}
data:
   vcs-init.xml: |
        <?xml version="1.0" encoding="UTF-8"?>
        <vcs-root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" uuid="c3e071af-57ab-46aa-8c0d-933d29156a05" type="jetbrains.git" xsi:noNamespaceSchemaLocation="https://www.jetbrains.com/teamcity/schemas/2025.3/project-config.xsd">
          <name>https://github.com/netKore/teamcity-config.git</name>
          <param name="agentCleanFilesPolicy" value="ALL_UNTRACKED" />
          <param name="agentCleanPolicy" value="ON_BRANCH_CHANGE" />
          <param name="authMethod" value="PASSWORD" />
          <param name="branch" value="refs/heads/main" />
          <param name="ignoreKnownHosts" value="true" />
          <param name="secure:password" value="X_STUB_X" />
          <param name="submoduleCheckout" value="CHECKOUT" />
          <param name="url" value="https://github.com/netKore/teamcity-config.git" />
          <param name="useAlternates" value="AUTO" />
          <param name="username" value="netKore" />
          <param name="usernameStyle" value="USERID" />
        </vcs-root>


---
apiVersion: v1
kind: ConfigMap
metadata:
  name: teamcity-init-project
data:
  project-config.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" parent-id="" uuid="" xsi:noNamespaceSchemaLocation="https://www.jetbrains.com/teamcity/schemas/2025.3/project-config.xsd">
      <name>&lt;Root project&gt;</name>
      <description>Contains all other projects</description>
      <project-extensions>
        <extension id="PROJECT_EXT_1" type="ReportTab">
          <parameters>
            <param name="startPage" value="coverage.zip!index.html" />
            <param name="title" value="Code Coverage" />
            <param name="type" value="BuildReportTab" />
          </parameters>
        </extension>
        <extension id="PROJECT_EXT_2" type="versionedSettings">
          <parameters>
            <param name="buildSettings" value="PREFER_VCS" />
            <param name="credentialsStorageType" value="credentialsJSON" />
            <param name="enabled" value="true" />
            <param name="format" value="kotlin" />
            <param name="ignoreChangesInDependenciesAndVcsSettings" value="false" />
            <param name="rootId" value="HttpsGithubComNetKoreTeamcityConfigGit" />
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
