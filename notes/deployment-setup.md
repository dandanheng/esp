# Deployment Setup: Prod/Test Dual Container

## Architecture
```
远程机 lldd-linux (100.92.85.48):
├── /home/lldd/codes/xiaozhi-server/          # prod (git hook managed)
│   └── data/.config.yaml                     # prod config
├── /home/lldd/codes/xiaozhi-server-test/     # test (rsync from Mac)
│   ├── data/.config.yaml                     # test config (independent)
│   ├── docker-compose.yml                    # test container config
│   ├── switch.sh                             # iptables prod/test switching
│   ├── deploy-test.sh                        # rsync + restart test
│   └── healthcheck.sh                        # health checks
```

## Containers
- **prod**: `xiaozhi-esp32-server`, ports 8000/8003, stable image, child uses this
- **test**: `xiaozhi-esp32-server-test`, ports 8100/8103, same image + volume mount code

## Commands
- Deploy to test: `./deploy-test.sh` (from Mac)
- Switch to test: `sudo bash switch.sh test` (on remote)
- Switch to prod: `sudo bash switch.sh prod` (on remote)
- Health check: `bash healthcheck.sh all` (on remote)

## SSH
- From Mac: `ssh lldd@100.92.85.48`
- @kimi-linux can execute directly on the Linux machine

## Notes
- Test container code is volume-mounted from `/home/lldd/codes/xiaozhi-server-test/`
- Model file is symlinked from prod to save space
- switch.sh uses iptables DNAT to redirect traffic
