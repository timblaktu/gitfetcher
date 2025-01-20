# Git Fetcher

Dead-simple docker compose service to periodically fetch remote commits from a configured repo.

## Why?

I wanted GitOps functionality for [`dockge`](https://github.com/louislam/dockge) running on my TrueNAS. Other solutions I found were unnecessarily complicated, especially considering how easy it would be to do this with only `sh` and `git`. Since `dockge` is a compose-oriented system, I wrapped the script in a compose service, so that it would work like a sidecar.

The resulting implementation has been generalized and should have nothing `dockge`-specific.

# Usage

```
git clone https://github.com/timblaktu/gitfetcher.git && cd gitfetcher
vi Makefile  # Customize variables at top of Makefile
make up
```

# Container Image

The container image is so small and simple that it is built on-demand. I do not host it anywhere.

# Secrets Management

The following named secrets are shared with container services using [docker compose secrets](https://docs.docker.com/compose/how-tos/use-secrets):

## repo_access_token

This is a personal access token authorizing read access to the git repo specified by $REPO_URL.

The user places the value of this secret alone in file $HOST_REPO_ACCESS_TOKEN_PATH with access restricted to the host user that will be running docker compose.

The secret value is read by the container user (who has same uid/gid as host user) and embedded in the $REPO_URL for anonymous access, e.g.:

  https://<token>@some.git.service/org/repo.git

