# tekton-workshop

Tekton pipelines workshop

## Prerequisites

- oc client.
- openshift cluster with admin rights.

## Installation

Open a terminal abd login into OpenShift using an user with admin rights.

Execute `install.sh` script. The final output contains the demo installation information. Example:
```
TODO
```

Configure gitea webhooks for application push events in master branch (using installation information values):

- Open **GITEA url** and login.
- Open `application-source`
- Create a webhook in `Settings > Webhooks > Add Webhook`
- Target URL must be **PIPELINES push webhook**
- HTTP Method must be `POST`
- POST Content Type must be `application/json`
- Secret can be any value
- Trigger On `Push Events`
- Branch filter must be `master`

Configure gitea webhooks for deploy pull request events (using installation information values):

- Open **GITEA url** and login.
- Open `application-deploy`
- Create a webhook in `Settings > Webhooks > Add Webhook`
- Target URL must be **PIPELINES pull request**
- HTTP Method must be `POST`
- POST Content Type must be `application/json`
- Secret can be any value
- Trigger On `Custon Events` and mark `Pull Request`