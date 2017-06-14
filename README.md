### Naming versioning on alpine

# Usage

```bash
$ docker build . -t alpine-sv
$ docker run -e GIT_BRANCH=origin/develop -e GIT_COMMIT=5209fb41 -e GIT_URL=git@gitlab.services:crawling/gocrawl-demo.git -v ~/.ssh:/root/.ssh -ti --rm svsv ./semantic-version.sh
```

	GIT_BRANCH: use origin/develop origin/master and origin/hotfix/* 
	GIT_COMMIT: your commit hash
	GIT_URL: your repository url

*all this parameters can be extract from jenkins or gitlab variables*

- bind a volume with an .ssh directory with the right credentials to connect to the repo you set.
- there are others alternatives to this approach, like docker-secrets, .env, etc.

