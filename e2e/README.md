# Polaris end-to-end tests

The fixture starts Polaris on loopback ports and seeds two users, one room, and one
inventory item. `prepare-database` drops and recreates the named schema on every run.
Use a disposable MariaDB schema starting with `polaris_e2e_`.

## Setup

Use JDK 25, the Maven wrapper, and a local MariaDB server and client. The
[renderer scenarios](https://github.com/habbinho-hotel/habbinho-client/blob/main/Octane-Renderer/packages/communication/src/e2e/README.md)
also use Node.js and Yarn. Set these variables in the shell you will use for both
the emulator and the renderer.

| Variable | Example |
| --- | --- |
| `E2E_DB_HOST`, `E2E_DB_PORT` | `127.0.0.1`, `3306` |
| `E2E_DB_NAME`, `E2E_DB_USER` | `polaris_e2e_local`, `root` |
| `E2E_DB_PASSWORD` | Password of the local MariaDB account, if set |
| `E2E_SSO_TICKET`, `E2E_USER_ID` | `e2e-local-ticket`, `900001` |
| `E2E_SECOND_SSO_TICKET`, `E2E_SECOND_USER_ID` | `e2e-peer-ticket`, `900003`. Database setup requires the second ticket for all scenarios. |
| `E2E_ROOM_ID` | `900002` |
| `E2E_GAME_PORT`, `E2E_RAW_PORT`, `E2E_RCON_PORT` | `31999`, `31998`, `32000` |
| `E2E_WS_URL`, `E2E_PROBE_URL` | `ws://127.0.0.1:31999`, `http://127.0.0.1:31999/__e2e` |
| `E2E_RUNTIME_DIR` | Location for generated config, PID, and logs. The Linux example sets it below. |
| `E2E_MYSQL` | Required by the PowerShell database scripts. Use the MariaDB client name or full path. |

The [seed](seed.sql) sets the WebSocket and session settings in `emulator_settings`.
These values take precedence over the startup file once Polaris connects to MariaDB.

## Linux and macOS

From the `habbinho-emulator` root:

```bash
export E2E_RUNTIME_DIR="$(mktemp -d)"
./Emulator/mvnw -B -f Emulator/pom.xml package -DskipTests
bash e2e/prepare-database.sh
bash e2e/start-emulator.sh
```

Run the renderer scenario in the same shell, then return to the emulator root.
For the inventory scenario, run `bash e2e/verify-inventory-state.sh` before
stopping Polaris with `kill "$(cat "$E2E_RUNTIME_DIR/polaris.pid")"`.

## Windows PowerShell

From the `habbinho-emulator` root:

```powershell
.\Emulator\mvnw.cmd -B -f Emulator/pom.xml package -DskipTests
.\e2e\prepare-database.ps1
$runtime = Join-Path ([System.IO.Path]::GetTempPath()) "polaris-e2e-$PID"
$process = .\e2e\start-emulator.ps1 -RuntimeDirectory $runtime | ConvertFrom-Json
```

Run the renderer scenario in the same shell, then return to the emulator root.
For the inventory scenario, run `.\e2e\verify-inventory-state.ps1` before
stopping Polaris with `Stop-Process -Id $process.pid`.

If startup fails, check `polaris.stdout.log` and `polaris.stderr.log` in the
runtime directory. Check that the ports are free and the two repositories use
the same tickets, IDs, and endpoints.
