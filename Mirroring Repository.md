Mirroring Repository  
https://github.com/marketplace/actions/mirroring-repository

https://github.com/neotronix/EBM-12-VI-1968/settings/secrets/actions  
Repository secrets > GITLAB_SSH_PRIVATE_KEY

https://gitlab.com/-/user_settings/ssh_keys  
SSH keys

https://gitlab.com/Neotronix/EBM-12-VI-1968/-/settings/ci_cd  
CI/CD > Variables

https://github.com/settings/keys  
SSH keys

https://github.com/neotronix/EBM-12-VI-1968/settings/secrets/actions  
Repository secrets > GITLAB_SSH_PRIVATE_KEY

https://github.com/neotronix/EBM-12-VI-1968/settings/keys  
Deploy keys

https://github.com/marketplace/actions/ximaz-repo-mirror
https://github.com/marketplace/actions/gitlab-sync
https://github.com/marketplace/actions/git-deploy-action
https://github.com/marketplace/actions/setup-github-gitlab-version-control-user

---

Key Configuration Details  
Action Used: pixta-dev/repository-mirroring-action@v1.  
Checkout Step: fetch-depth: 0 is required to ensure all history and branches are fetched before mirroring.  

**Authentication:** You must provide a GitLab SSH private key as a GitHub Secret:  
    Add the private key to your GitHub repository under Settings > Secrets and variables > Actions.  
    Add the corresponding public key to your GitLab repository under Settings > Repository > Deploy keys with write access enabled.  

Target URL: Use the SSH URL format for your GitLab repository: git@gitlab.com:<username>/<project>.git.


Using secrets in GitHub Actions
https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets

Gitlab SSH keys
https://gitlab.com/-/user_settings/ssh_keys
