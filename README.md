# ISP Overview

## Background

The [International Situations Project](http://rap.ucr.edu/ISP.html) (ISP) is a collaboration between the University of California Riverside (UCR) and the Center for Open Science (COS).  It's an online questionnaire that asks the participants to describe a situation that they experienced, then sort cards describing their feelings and opinions about the scenario. COS has built their site, and is responsible for maintaining it and updating it with new translations, provided by UCR's international collaborators. The goal is to translate these studies into *X* languages for *Y* countries.

## Software Components

ISP is comprised of three-and-a-half main components: ISP (+ exp-addons), Experimenter, and JamDB.

1. **ISP** is the front-end of the study.  It is an Ember app.  The translated strings and consent forms are stored here.  Your translation updates will be delivered as PRs against the [ISP repo](https://github.com/CenterForOpenScience/isp).

    a. **exp-addons** is a library of Ember addons used by ISP.  This library was shared with another project, Lookit, so ISP has a [separate development branch](https://github.com/CenterForOpenScience/exp-addons/tree/isp) called `isp` for itself.  Translation work should not involve exp-addons, but many of the visible components are defined here. 

2. **Experimenter** is the admin interface to ISP.  This is used to generate participant IDs for studies.  You will be given access to this in the staging environment. [GitHub repo](https://github.com/CenterForOpenScience/experimenter)

    a. Experimenter also uses **exp-addons**.

3. **JamDB** is the storage backend for ISP and Experimenter.  It is unlikely that you will ever have to interact with this directly. [GitHub Repo](https://github.com/CenterForOpenScience/jamdb).

## Glossary

* *language picker*: The modal that pops up the first time you go to an ISP study site.  Allows the user to select a language and country that will be used to determine how the page should be translated.  Selecting both a language and country allows us to support different dialects of the same language (ex. Spanish+Mexico vs. Spanish+Spain) or countries with multiple languages (German+Switzerland vs. French+Switzerland).

* *ThreeCat*: The nickname of the first card-sorting interface in the ISP app.  Users are asked to sort cards describing their feelings into one of three categories, Uncharacteristic, Neutral, or Characteristic.

* *NineCat*: The nickname of the second card-sorting interface.  After finishing ThreeCat, users are then asked to sort the same card sets into nine finer-grained categories, with limits on the number of cards that can be put into each category.

## Environments

ISP has two environments, `staging` and `production`.  `staging` is updated whenever the `develop` branch of the ISP repo is updated.  `production` is updated manually, after a new ISP release is created and pushed.  Staging will always have all translations and locales that have been added to the repo.  Languages are made available on `production` by adding them to a list of production-ready languages.  This is to give UCR and their international collaborators a chance to evaluate and refine their translations before making them officially available.

* Staging
    * ISP: https://staging-isp.osf.io/
    * Experimenter: https://staging-experimenter.osf.io/
    * JamDB: https://staging-metadata.osf.io/

* Production
    * ISP: https://ispstudy.net/
    * Experimenter: https://experimenter.osf.io/

## Getting started tasks

1. Clone the ISP repo, and follow the instructions in the README.MD to get it set up for local development.

2. Test if you can access the ISP Google Drive folder (https://drive.google.com/drive/u/0/folders/0BxGwKGgJtw4WYVpJVllsMk84Wms).  If not send the Team Lead a request to add you.

3. If you would like to see what the ISP interface looks like, ask the Team Lead to generate a dummy participant ID for you.  They will send you a participant ID and study ID that you can enter at https://staging-isp.osf.io/.

4. Create an account on https://staging.osf.io and send your GUID to the Team Lead to be added to staging Experimenter.

## Translations

COS receives translation requests from UCR and their collaborators each sprint.  These requests are usully either to:

1. fix errors in an existing translations

2. upload a new translation to `staging`

3. make a translation that was available only on `staging` available on `production`

The translations are provided as spreadsheets in the [`/Samples/Translations/` folder](https://drive.google.com/drive/u/0/folders/0B441UYO1vv_CVjRrc25SZjRhazA) of a [shared Google Drive](https://drive.google.com/drive/u/0/folders/0BxGwKGgJtw4WYVpJVllsMk84Wms).  These spreadsheets must be validated to ensure the proper format has been followed then translated into a form usable by ISP.  The ISP repo contains scripts to assist with this process and a [README.md](https://github.com/CenterForOpenScience/isp/tree/develop/scripts/) to explain how to run them.

The final deliverable will be a PR against the ISP repo to add the new translations and consent forms ([example](https://github.com/CenterForOpenScience/isp/pull/160)).  ISP releases are done every other Friday, and will include all translations requests submitted before noon Eastern time the Thursday before.

There are two pieces to a translation: a consent form and the application questions.

### Consent forms

Consent forms are keyed by study ID and ignore the user's selected language.  If I select "English (US)" in the language picker, but give `GREECE1.GR` as the study ID, I will see a Greek consent form, but the following questions and card will be in American English.  Consent forms and study IDs are [saved here](https://github.com/CenterForOpenScience/isp/blob/develop/app/components/isp-consent-form/consentText.js).  The study IDs in this file are not defined anywhere else.  Adding a new study ID to this file is sufficient to make it available on ISP.

### Translations

Translations are stored in the [`/app/locales/`](https://github.com/CenterForOpenScience/isp/tree/develop/app/locales) folder of the ISP repo under a two- or four- letter language code.  The language-specific subdirectories may also include a `config.js` file for overriding i18n functionality provided by ember-18n.  Right-to-left (RTL) language support and pluralization options can be set here.

# Setting up ISP / Experimenter / Jam

The quickest way to set up the environment is to run the install.sh script provided in the [Common Development Environment](https://github.com/felliott/cde) repo.  This script will:

1. checkout the submodules for the constituent projects
2. build docker images for each project
3. copy over the config files from the `config` directory to their appropriate locations
4. bring up the docker services

Before running this script, some configuration decisions must be made, and the template config files should be filled out:

## Authorization

Experimenter uses the OSF for authorization.  It's possible to configure it to use your own OSF instance, but it is not recommended.  The following instructions will assume that you are using main OSF instance at https://osf.io.

To use the OSF for authorization, you will first need to create an OAuth application. To do this:

1. Login to the OSF
2. Go to your Settings page (click on your name in the upper-right corner of the screen, and select "Settings")
3. Go to Developer Apps
4. Click on Create Developer App

Fill in the following fields:

```
App name: "This can be whatever you want"
Project Homepage URL: <URL where experimenter will be reachable. Ex. http://localhost:4210>
App description: "Whatever you like"
Authorization Callback URL: <The Project Homepage URL + "/login".  Ex. http://localhost:4210/login>
```

Note the Client ID and Secret.  Copy the Client ID to the `OSF_CLIENT_ID` key in `config/experimenter/.env`.  If you are using Production OSF, the default values for `OSF_URL` and `OSF_AUTH_URL` will suffice.

In addition, go to your user profile and note the your GUID.  This will be used later to create admin users in experimenter.

## Error handling

Experimenter and ISP are both capable of logging errors to a web service called [Sentry](https://sentry.io).  To set this up:

1. Go to sentry.io, create account
2. Create new project, type: Browser>Ember
  a. The name should be something meaningful to the admin
  b. Copy the DSN Sentry provides to the `SENTRY_DSN` key in `config/experimenter/.env`
3. Create new project, type: Browser>Ember
  a. The name should be something meaningful to the admin
  b. Copy the DSN Sentry provides to the `SENTRY_DSN` key in `config/isp/.env`

It's fine to use the same project/DSN for both ISP and experimenter.


## Service configuration

The ports each service listens on are defined in the `docker-compose.yml` file.  The `ports.published` property defines the external port.  By default, jam listens on `localhost:1212`, experimenter on `localhost:4210`, and isp on `localhost:4212`.

Template config files for each service live in the `config/` directory.

### jamdb

The template config file for jamdb is `config/jamdb/jam/settings/local.yml`.  It should be copied to `jamdb/jam/settings/`. Values set in this file will override those set in `jamdb/jam/settings/defaults.yml`.

```
# DEBUG: false

# # SERVER SETTINGS
# FORK: false  # Maybe true, false or intger
# PORT: 1212
# HOST: 0.0.0.0
# XHEADERS: False
# SENTRY_DSN: null


# # SQLITE_URI: sqlite://jam.db
# SQLITE_URI: jam.db

# EPHEMERAL:
#   USE: true

# MONGO:
#   USE: true
#   DATABASE_NAME: jam
#   TIMEOUT: 30
#   URI: mongodb://192.168.168.167:27017/

# ELASTICSEARCH:
#   USE: true
#   TIMEOUT: 30
#   URI: https://192.168.168.167:9200/

# NAMESPACE_BACKENDS:
#   state: mongo
#   logger: mongo
#   storage: mongo

# NAMESPACEMANAGER_BACKENDS:
#   state: mongo
#   logger: mongo
#   storage: mongo

# COLLECTION_BACKENDS:
#   state: elasticsearch
#   logger: mongo
#   storage: mongo

# JWT_SECRET: TestKey

# MAX_PAGE_SIZE: 500

# OSF:
#   URL: https://staging.osf.io
#   API_URL: https://api.staging.osf.io
#   ACCOUNTS_URL: https://accounts.staging.osf.io
```

### jam-setup

The template config file for jam-setup is `config/jam-setup/config/local.yml`.  It should be copied to `jam-setup/config/`.  Values set in this file will override those set in `jam-setup/config/default.yml`.

```
stage:
  JAM_TOKEN: CHANGEME
  JAM_URL: https://staging-metadata.osf.io
  COLLECTIONS_PATH: ./collections.js

prod:
  JAM_TOKEN: CHANGEME
  JAM_URL: https://metadata.osf.io
  COLLECTIONS_PATH: ./collections.js
```

### experimenter

The template config file for experimenter is `config/experimenter/.env`.  It should be copied to `experimenter/`.  Experimenter **will not** work unless this file is present.

```
# Auth configuration
OSF_CLIENT_ID=<oauth-client-id>
OSF_SCOPE=osf.users.profile_read
OSF_URL=https://osf.io
OSF_AUTH_URL=https://accouts.osf.io

# Datastore configuration
JAMDB_URL=http://localhost:1212/
JAMDB_NAMESPACE=???

# Error logging
SENTRY_DSN=https://foo@sentry.io/project-id
```

### isp

The template config file for experimenter is `config/isp/.env`.  It should be copied to `isp/`.  Experimenter **will not** work unless this file is present.

```
JAMDB_URL=http://localhost:1212
EXPERIMENT_ID=<experiment-uuid>
USE_UNRELEASED_TRANSLATIONS=false
SENTRY_DSN=https://foo@sentry.io/project-id
```


# Future development

The ISP experiment is defined by a schema that defines which experiment components should be used and in what order they should be presented.  The schema is thus:

```
{
    "frames": {
        "card-sort": {
            "kind": "exp-card-sort"
        },
        "rating-form": {
            "kind": "exp-rating-form"
        },
        "overview": {
            "kind": "exp-overview"
        },
        "free-response": {
            "kind": "exp-free-response"
        },
        "thank-you": {
            "kind": "exp-thank-you"
        }
    },
    "sequence": [
        "overview",
        "free-response",
        "card-sort",
        "rating-form",
        "thank-you"
    ]
}
```

The code for these components is defined in the `exp-addons` library.  Any features / bugfixes for the survey components should be implemented there.  Here are GitHub links for each component:

* [overview](https://github.com/CenterForOpenScience/exp-addons/blob/isp/exp-player/addon/components/exp-overview)
* [free-response](https://github.com/CenterForOpenScience/exp-addons/tree/isp/exp-player/addon/components/exp-free-response)
* [card-sort](https://github.com/CenterForOpenScience/exp-addons/blob/isp/exp-player/addon/components/exp-card-sort)
* [rating-form](https://github.com/CenterForOpenScience/exp-addons/blob/isp/exp-player/addon/components/exp-rating-form)
* [thank-you](https://github.com/CenterForOpenScience/exp-addons/blob/isp/exp-player/addon/components/exp-thank-you)
