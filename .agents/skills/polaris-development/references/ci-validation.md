# Polaris CI and local validation

The [CI workflow](../../../../.github/workflows/ci.yml) and
[Maven POM](../../../../Emulator/pom.xml) define the current checks. Use JDK 25
and the committed wrapper. Testcontainers integration tests require Docker.

## Commands

From the repository root, start with the relevant test class:

```sh
./Emulator/mvnw -f Emulator/pom.xml test -Dtest='ExampleTest'
```

To reproduce the build-and-test job and static analysis, run:

```sh
./Emulator/mvnw -B -f Emulator/pom.xml -Pcoverage verify -DforkCount=2 -Dspotless.check.skip=true -Dspotbugs.skip=true
./Emulator/mvnw -B -f Emulator/pom.xml compile spotless:check spotbugs:check -Dspotless.ratchetFrom=BASE_REF
```

Replace `BASE_REF` with the PR base SHA or the applicable local base ref, such
as `origin/main` for a Habbinho PR targeting `main`. CI formats against the PR
base SHA or the previous commit on a push.

| Change | Relevant checks |
| --- | --- |
| Migrations or schema | `MigrationRunnerIT` with the MariaDB versions in CI and the backup/restore job. Regenerate the schema contract when the schema changes. |
| Plugin API or packaging | ABI checks, historical plugin fixtures, and `PackagedJarContractIT`. CI also runs `clean package` on JDK 26. |
| Release or build handoff | `bash scripts/build-latest.test.sh` and the affected packaging job. |
| Packets or RCON | Contract coverage and field-order tests for the affected packets. |
| Furni import | Run the [import validator](../../../../docs/FURNI_IMPORT_PIPELINE.md) on the staged inputs. |
| End-to-end behavior | Use the [disposable Polaris fixture](../../../../e2e/README.md) and the relevant renderer scenario. |

[CodeQL](../../../../.github/workflows/codeql.yml) runs separately on GitHub.
