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
```

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
