# Archer - archery tournament registration

Archer is designed for easy participant management for archery competitions.

## Deployment

Ready made container available at ``ghcr.io/thofrank/archer:latest``

Following environment variables are available for configuration:

```
RAILS_MASTER_KEY # See https://github.com/ThoFrank/archer/issues/12
ARCHER_DEFAULT_CLUB
ARCHER_DEFAULT_MAIL_ADDRESS
ARCHER_SMTP_ADDRESS
ARCHER_SMTP_USERNAME
ARCHER_SMTP_PASSWORD
ARCHER_OIDC_NAME
ARCHER_OIDC_HOST
ARCHER_OIDC_CLIENT_ID
ARCHER_OIDC_SECRET_KEY
ARCHER_OIDC_CALLBACK_URI
```

### Login with Nextcloud via oidc

Assuming you have your Nextcloud instance at cloud.example.com. And your Archer instance at archer.example.com

Set the following ENV Variables for ARCHER:
```
ARCHER_OIDC_NAME=Nextcloud
ARCHER_OIDC_HOST=cloud.example.com
ARCHER_OIDC_CLIENT_ID=FROM_NEXTCLOUD
ARCHER_OIDC_SECRET_KEY=FROM_NEXTCLOUD
ARCHER_OIDC_CALLBACK_URI=https://archer.example.com/auth/nextcloud/callback
```

In the Nextcloud OpenID Connect Provider plugin configuration create an entry with:

- Callback-URI: `https://archer.example.com/auth/nextcloud/callback`
- Default settings otherwise

You might want to create a new group for users and restrict the oidc client to only that group to be able to restrict who has access to Archer.

## Development

For development Ruby and other system dependencies are managed via [devenv](https://devenv.sh).

Once you are in a devenv shell run:

```bash
# initialize database
rake db:create

# migrate databases to the latest schema
rake db:migrate

# load test fixtures to have some data
rake db:fixtures:load

# start the development server
bin/dev
```

# Attribution

The icon 'WA 80 cm archery target' was created by Alberto Barbati, licensed under the [Creative Commons Attribution-Share Alike 2.0 Generic license](https://creativecommons.org/licenses/by-sa/2.0/deed.en) and shared on [wikimedia](https://commons.wikimedia.org/wiki/File:WA_80_cm_archery_target.svg).
