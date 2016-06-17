# Wallpapers

## Image Update

- Setup deployment key for repo
  - Create SSH keypair: `ssh-keygen -t rsa -b 8192 -f wallpapers-key -C "you+wallpapers@email.com"` (no password)
  - GitHub repo > Settings > Deploy keys > Add deploy key
  - Paste `wallpapers-key.pub`, enable "Allow write access", click "Add key"
- Setup repo
  - `cd /srv/www`
  - `cp ~/wallpapers-key .`
  - `ssh-agent bash -c "ssh-add wallpapers-key && git clone --branch wallpapers git@github.com:you/wallpapers"`
  - `mv wallpapers-key wallpapers`

## Imgur Sync

- [Create Imgur account](http://imgur.com)
- [Create Imgur application](https://api.imgur.com/oauth2/addclient)
  - Select "OAuth2 authorization without a callback URL"
  - Enter name, description, etc.
  - Submit and save client ID & secret
- Authorize app for your account
  - Visit `https://api.imgur.com/oauth2/authorize?client_id=CLIENT_ID&response_type=token`
  - Save `access_token` and `refresh_token` from URL
- Create Imgur album (sync target)
  - Save album ID
  - Update order: Rearrange images > Time uploaded > Descending > Save
- Save above info in credentials file (`/srv/www/wallpapers/imgur.json`)

    ```
    {
      "client_id": "CLIENT_ID",
      "client_secret": "CLIENT_SECRET",
      "album_id": "ALBUM_ID",
      "access_token": "ACCESS_TOKEN",
      "refresh_token": "REFRESH_TOKEN"
    }
    ```

## Cron Jobs

- `crontab -e`
- `0 10 * * * cd /srv/www/wallpapers && ./update-images.sh 2>&1 | /usr/bin/logger -t wallpapers-update`
- `0 11 * * * cd /srv/www/wallpapers && ./sync-imgur.sh 2>&1 | /usr/bin/logger -t wallpapers-sync`

## License

Copyright &copy; 2016 Chris Schmich<br>
MIT License. See [LICENSE](LICENSE) for details.
