# gluten-verify

On-demand native verification for [malinjawi/incubator-gluten](https://github.com/malinjawi/incubator-gluten)
branches, used by coding agents through the `ci-verify` script.

The single workflow, [`agent-verify.yml`](.github/workflows/agent-verify.yml), is manually
dispatched only. It checks out a branch of the Gluten fork, builds Gluten + Velox natively
with tests inside CI's own `apache/gluten:centos-9-jdk17` image, and runs just the requested
Gluten C++ tests (`ctest`), Velox gtests (only the named targets are compiled) and Scala
suites (`-DwildcardSuites`). Results go to the job summary and an `agent-verify-results`
artifact.

It lives in this standalone repo, not on the fork, because GitHub can pause Actions on
busy forks. It only checks out repositories under `malinjawi/`, reads them with the default
read-only token, and never pushes anywhere.
