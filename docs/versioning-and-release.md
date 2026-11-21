# Versioning and release policy

Polaris uses `major.minor.patch` versions. Routine compatible releases advance
the patch version. Additive release trains may advance the minor version after
operator-facing review. A breaking public integration change requires an
explicitly approved major-release policy; routine modernization must remain
compatible.

## Release gate

Tag a commit with green CI. A `vX.Y.Z` tag matching the version in
`Emulator/pom.xml` runs `verify` and publishes the runnable JAR, SHA-256 checksum,
SBOM and provenance attestations in a GitHub Release.

An `image-vX.Y.Z` tag builds the `linux/amd64` and `linux/arm64` container images
for `ghcr.io/habbinho-hotel/habbinho-emulator`. The registry receives that tag
and `sha-<commit>`. The JAR and image tags can be cut independently.

## Release checklist

1. Merge the ordered pull-request stack only after required checks are green.
2. Confirm ABI, precompiled plugin, assembled-jar, and supported MariaDB
   migration jobs pass.
3. Review migrations and configuration changes for upgrade safety.
4. Deploy to a canary hotel and exercise startup, login, rooms, catalog,
   wired, plugins, and shutdown.
5. Monitor startup, database, scheduler, packet, and plugin errors before
   widening rollout.
6. Retain the previous jar, configuration, and database backup for rollback.

Database migration rollback depends on the affected table engines and must not
be described as transaction-wide without executable evidence.
