# AKS OIDC update notes

Notes for things that need to be updated to improve developer experience

## Updates

- General
  - replace custom helm charts with yaml files?
    - either static files or simple templates using envsubst or "cat EOF" syntax
  - remove **all** hardcoded secrets and certs. even fake, test, or public ones.

- README.md
  - replace request flow diagram
    - include specific components that are installed in the walkthrough
  - add domain name to list of prereqs
  - replace any text that user has to replace with commmands that will do the correct string substitution
  - discuss supporting components that are not kube-oidc-proxy and how they fit into the walkthrough

- docs/index.md
  - these table of contents are a bit hidden.
    - move somewhere more prominent
  - switch order of gangway and kube-oidc-proxy. they are out of order.

- docs/cert-manager/README.md
  - remove references to k8s < 1.15 ?
  - check latest version of cert-manager
  - remove references to helm v2 and tiller
  - create template for cluster issuer CRD object
    - user currently has to manually create their own file from a sample file
  - replace any text that user has to replace with commmands that will do the correct string substitution

- docs/ingress/README.md
  - need instructions on creating DNS Zone and records
  - replace any text that user has to replace with commmands that will do the correct string substitution

- docs/dex/README.md
  - remove use of static client and static passwords
    - replace with an actual identity provider like GitHub or something else. There is a GitHub example in the repo.
  - replace any text that user has to replace with commmands that will do the correct string substitution

- docs/gangway/README.md
  - add instructions on how to download let's encrypt's intermediate certs
  - replace any text that user has to replace with commmands that will do the correct string substitution

- docs/kube-oidc-proxy/README.md
  - replace request flow diagram with updated version that'll replace the one the root readme
  - might not need `oidc.client-id: ...` secret value since it references DEX static client feature, which needs to be removed
  - replace any text that user has to replace with commmands that will do the correct string substitution

- src/helm/aks-kube-oidc-proxy/README.md
  - this readme is nested under `docs/kube-oidc-proxy/README.md` in the table of contents
  - is this another option to deploy the procy instead of the of the other static yaml files?
  - is it required? can the helm chart be removed and replaced the the other yaml files?
  - jetstack had their own helm chart. can/should that be used instead?

- docs/user/README.md
  - better organization of setup and authorization tests to make it easier to read
  - replace any text that user has to replace with commmands that will do the correct string substitution

- src/yaml/cert-manager-config
  - templatize with envsubst, sed, "cat EOF" bash syntax, or something similar

- src/yaml/dex
  - potentially make `src/yaml/dex/github_config` the default/only config for the identity provider
  - does dex have a helm chart?
  - remove static client/password feature from `src/yaml/dex/dex-config.yaml`
  - remove **all** hardcoded secrets and certs. even fake, test, or public ones.
  - templatize with envsubst, sed, "cat EOF" bash syntax, or something similar

- src/yaml/gangway
  - does gangway have a helm chart?
  - remove **all** hardcoded secrets and certs. even fake, test, or public ones.
  - templatize with envsubst, sed, "cat EOF" bash syntax, or something similar

- src/yaml/ingress
  - templatize with envsubst, sed, "cat EOF" bash syntax, or something similar

- src/yaml/test
  - describe the different yaml configs in the `docs/user/README.md` walkthrough
  - combine scenarios with `src/yaml/user` and rename directory to something clearer. maybe `user-scenarios`, `test-scenarios`, or something else
  - templatize with envsubst, sed, "cat EOF" bash syntax, or something similar

- src/yaml/user
  - describe the different yaml configs in the `docs/user/README.md` walkthrough
  - combine scenarios with `src/yaml/test` and rename directory to something clearer. maybe `user-scenarios`, `test-scenarios`, or something else
  - templatize with envsubst, sed, "cat EOF" bash syntax, or something similar
