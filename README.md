# 🛤 Embark

Embark is a series of tools for bootstrapping a project for the deft platform and workflow.

Embark will help template a new project and will setup development lifecycle scripts for that project. Regardless of the underlying tech stack, embark uses similar scripts for each workflow regardless of the underlying technology.

Embark uses idempotent scripts for bootstrap and update. Once these have run they will noop if there is nothing to do. This requires all of the functions that power these lifecycles to check before working.

Embark uses PIDS in `./tmp/process.pid` and logs at `./logs/development.log` for services.

## Soon™
Embark will be checked via a nightly build to ensure that all the lifecycle hooks still work for new projects supported by the Spaceship Platform.

Projects bootstrapped with embark will run nightly builds on the Spaceship Platform to ensure that the project onboarding workflow continues to work for new team members joining the project. Gone are the days of out of date READMEs and artisinal environments.

## Get Started
TODO

## Lifecycle scripts

`bin/bootstrap` installs all of necessary environment dependencies and runs any one-off setup.

`bin/update` installs new library dependencies, migrates all of the datastores, and seeds any datastores.

`bin/cibuild` runs a cibuild

`bin/server` starts the server

`bin/console` starts a REPL console for the project

## Where can I get more help, if I need it?
TODO

## Contributors
- [Tim Dorr](tim.dorr@deft.services)
- [Patrick Wiseman](patrick.wiseman@deft.services)

## License
[Apache License 2.0](https://github.com/deftinc/embark/LICENSE)

## Acknowledgements
- Our approach to bootstrapping is influenced by prior works such as
  - [Scripts to Rule them all](https://github.com/github/scripts-to-rule-them-all)
  - [Boxen](https://github.com/boxen)
- [asdf vm](https://github.com/asdf-vm/) and plugins power programming language support
- [mkcert](https://github.com/FiloSottile/mkcert) and [nss](https://github.com/nss-dev/nss) power local HTTPS support
