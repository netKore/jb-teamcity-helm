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
        <vcs-root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" uuid="6cf3396d-ef41-4317-bd83-fed1b3f22127" type="jetbrains.git" xsi:noNamespaceSchemaLocation="https://www.jetbrains.com/teamcity/schemas/2025.3/project-config.xsd">
          <name>https://github.com/netKore/teamcity-config.git#refs/heads/main</name>
          <param name="agentCleanFilesPolicy" value="ALL_UNTRACKED" />
          <param name="agentCleanPolicy" value="ON_BRANCH_CHANGE" />
          <param name="authMethod" value="PASSWORD" />
          <param name="branch" value="refs/heads/main" />
          <param name="ignoreKnownHosts" value="true" />
          <param name="secure:password" value="X_STUB_X" />
          <param name="submoduleCheckout" value="CHECKOUT" />
          <param name="teamcity:branchSpec" value="refs/heads/*" />
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
    <project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" uuid="42b9e6fd-a146-4dc5-b20c-cf9def4335c0" xsi:noNamespaceSchemaLocation="https://www.jetbrains.com/teamcity/schemas/2025.3/project-config.xsd">
      <name>Teamcity Config</name>
    </project>
{{ end }}