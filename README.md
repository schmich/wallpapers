# wallpapers

- Setup deployment key for repo
  - Create SSH keypair: `ssh-keygen -t rsa -b 8192 -f wallpapers-key -C "you+wallpapers@email.com"` (no password)
  - GitHub repo > Settings > Deploy keys > Add deploy key
  - Paste `wallpapers-key.pub`, enable "Allow write access", click "Add key"
- Setup repo
  - `cd /srv/www`
  - `cp ~/wallpapers-key .`
  - `ssh-agent bash -c "ssh-add wallpapers-key && git clone --branch wallpapers git@github.com:you/wallpapers"`
  - `mv wallpapers-key wallpapers`
- Setup cron job
  - Run daily at 10am
  - `crontab -e`
  - `0 10 * * * cd /srv/www/wallpapers && ./update-bing-spotlight.sh 2>&1 | /usr/bin/logger -t wallpapers`
