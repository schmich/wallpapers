# wallpapers

- Create and deploy key for repo
  - Create SSH keypair: `ssh-keygen -t rsa -b 8192 -f id_rsa -C "you+wallpapers@email.com"` (no password)
  - GitHub repo > Settings > Deploy keys > Add deploy key
  - Paste `id_rsa.pub`, enable "Allow write access", click "Add key"
- Setup repo
  - `cd /srv/www`
  - `cp ~/id_rsa wallpapers-key`
  - `ssh-agent bash -c "ssh-add wallpapers-key && git clone --branch wallpapers git@github.com:you/wallpapers"`
  - `mv wallpapers-key wallpapers`
- Update crontab to run script twice daily (6a and 6p)
  - `0 6,18 * * * cd /srv/www/wallpapers && ./run.sh 2>&1 | /usr/bin/logger -t wallpapers`
