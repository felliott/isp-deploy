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


# Developing locally

The following instructions are for those who are adding new translations or consent forms.

## Getting started tasks for local development

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


# Deploying

The following instructions are for setting up a full ISP + Experimenter + JamDB deployment.  You will need to install [docker](https://www.docker.com/products/docker-desktop) and [docker-compose](https://docs.docker.com/compose/install/) on the host system.

The general process for setting up ISP will be, for each constituent project:

1. copy over the config file from the `config` directory to the appropriate location
2. update the config file
3. build docker image for the project
4. bring up the docker service

## URLs for local development

The instructions below assume that you are setting this up for a local deployment on a single machine.  Sometimes the instructions and config default values will use `http://localhost:<port>` for urls and other times use an explicit IP address, like `http://192.168.168.167:<port>`.  This is because each service container has its own idea of what `localhost` is.  `jamdb`'s `localhost` is distinct from `experimenter`'s.  However, the containers inherit the IP address mapping from the host system. In order for services to talk to each other, they need to communicate over an explicit IP address.  The following instructions follow the OSF's lead and assume `http://192.168.168.167` has been set up on the host system to point to the loopback device.  See [the instructions](https://github.com/CenterForOpenScience/osf.io/blob/19.6.0/README-docker-compose.md) in the OSF repo for how to do this.

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
Project Homepage URL: <URL where experimenter will be reachable. Ex. http://localhost:4212>
App description: "Whatever you like"
Authorization Callback URL: <The Project Homepage URL + "/login".  Ex. http://localhost:4212/login>
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

## Process!

### 1. Fetch and initialize repository

Run:

```
$ git clone git@github.com:felliott/isp-deploy.git
$ cd isp-deploy
$ git submodule init
$ git submodule update
$ cp config/jamdb/jam/settings/local.yml jamdb/jam/settings/
# not quite ready to configure these, but docker will complain if they don't exist
$ cp config/jam-setup/config/local.yml jam-setup/config/
$ cp config/experimenter/.env experimenter/.env
$ cp config/isp/.env isp/.env
```

### 2. Configure and run jamdb

Set jamdb configuration variables in `jamdb/jam/settings/local.yml`:

* OPTIONAL: set `SENTRY_DSN` to point to jamdb sentry project
* If using staging OSF for authentication:
  * MANDATORY: set `OSF.OSF_URL` to `https://staging.osf.io`
  * MANDATORY: set `OSF.OSF_API_URL` to `https://api.staging.osf.io`
  * MANDATORY: set `OSF.OSF_ACCOUNTS_URL` to `https://accounts.staging.osf.io`

Then run:

```
$ pushd jamdb; docker build -t jamdb:develop .; popd;

# Start jamdb service
$ docker-compose up -d jamdb

# check jamdb logs to make sure it started correctly. Exit with ^C.
$ docker-compose logs -f --tail 1000 jamdb

# open a shell in the jamdb container
$ docker exec -it isp-deploy_jamdb_1 /bin/bash

# Generate a token for initializing jam.  Note this value, it will be needed
# to configure `jam-setup` in the next step.
$ jam token system-system-system

# exit container and return to host shell
$ exit
```

### 3. Run jam-setup to initialize jam for experimenter/isp

Set jam-setup configuration variables in `jam-setup/config/local.yml`:

* MANDATORY: set `JAM_TOKEN` to the token generated by jam.  This "superuser" token allows the admin to create & modify collections in jamdb. It expires after three hours.
* MANDATORY: set `ADMIN_GUID` to the OSF guid of the user who will be the initial owner of the project.  This user will have the power to add new admins once experimenter is running.
* OPTIONAL: set `JAM_URL` to the url of the jamdb server.  If running locally, the default of `http://192.168.168.167:4211` should suffice.

Then run:

```
$ pushd jam-setup; docker build -t jam_setup:develop .; popd;

# run the jam-setup script.  This container should exit on its own once the setup 
# process is complete.  Review the container logs for errors.
$ docker-compose up jam_setup
```

If you get a `401 Unauthorized` error, then it is likely that the token generated in the previous section has expired.  Open another shell in the `jamdb` container, rerun the `jam token ...` command, and update the `jam-setup` config file.

### 4. Configure and run experimenter

Set experimenter configuration variables in `experimenter/.env`:

* MANDATORY: set `OSF_CLIENT_ID`
* OPTIONAL: update `OSF_URL` and `OSF_AUTH_URL` if not using production OSF for auth.
* MANDATORY: set `JAMDB_URL` to point to jamdb instance. Default value is for local development.
* OPTIONAL: set `SENTRY_DSN` to point to the experimenter sentry project.

Then run:

```
$ pushd experimenter
$ git submodule init
$ git submodule update
$ docker build -t experimenter:develop .
$ popd

# Start experimenter service
$ docker-compose up -d experimenter

# Check experimenter logs to make sure it started correctly.
$ docker-compose logs -f --tail 1000 experimenter
```

### 5. Login to experimenter and set up ISP experiment

Once the experimenter service is running (you should see the text "Build successful" in the docker logs), go to `http://localhost:4212/` or the configured experimenter url in a browser.  Login as the superuser designated by the `ADMIN_GUID` config variable in `jam-setup` via the OSF auth provider. Select the `isp` namespace. Create a new experiment named "ISP". Click "Build Experiment" to edit the schema and replace the default with:

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

Click the "Save" button, then go back to the experiment page, and click "Start Experiment Now". Note the experiment id in the url (it will be final part of the path), this will be needed to configure ISP in the next step.

To give another user the ability to add participants:

1. Click on "Project settings" in the sidebar
2. Select whether the user should have admin access or read access from the dropdown at the top of the page.
3. Paste the user's OSF id (from either prod or staging OSF, depending on which was used as the auth provider) into the blank box at the bottom of the page.
4. Click the green plus sign to add them.

### 6. Configure and run ISP:

Set ISP configuration variables in `isp/.env`:

* MANDATORY: set `EXPERIMENT_ID`: this should be the experiment id noted above.
* MANDATORY: update `USE_UNRELEASED_TRANSLATIONS` to `true` if the environment is staging (*not* production).
* MANDATORY: set `JAMDB_URL` to point to jamdb instance. Default value is for local development.
* OPTIONAL: set `SENTRY_DSN` to point to the ISP Sentry project.

Then run:

```
$ pushd isp
$ git submodule init
$ git submodule update
$ docker build -t isp:develop .
$ popd
$ docker-compose up -d isp  # starts the ISP service

# check ISP logs to make sure it started correctly
$ docker-compose logs -f --tail 1000 isp
```

Go to `http://localhost:4213/` or the configured ISP url in a browser to verify.


### 7. Running a test experiment

* Login to experimenter, then select "Create users" from the sidebar.
  * Update the "Batch size" input with the number of participant ids to create
  * OPTIONAL: add a tag to identify admin or other group of users
  * Input the Study ID to connect the participant ids to.  The Study ID should correspond to a key in the [consent text object](https://github.com/CenterForOpenScience/isp/blob/1.0.26/app/components/isp-consent-form/consentText.js#L17) that maps study IDs to consent form translations.
  * Experimenter will initiate a download of participant ids in a file called `participants.csv`.  Save this file.  Each line contains a participant ID and the study ID, separated by a comma.
* To test ISP, take one of the participant ids from `participants.csv` and input it as the "Participant ID".  Put the Study ID as the "Study ID".


## Service configuration

The ports each service listens on are defined in the `docker-compose.yml` file.  The `ports.published` property defines the external port.  By default, jam listens on `localhost:4211`, experimenter on `localhost:4212`, and isp on `localhost:4213`.

Template config files for each service live in the `config/` directory.

### jamdb

The template config file for jamdb is `config/jamdb/jam/settings/local.yml`.  It should be copied to `jamdb/jam/settings/`. Values set in this file will override those set in `jamdb/jam/settings/defaults.yml`.

```
## At least one value must be uncommented for jam to start.

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
#   URI: http://192.168.168.167:9200/

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

OSF:
  URL: https://osf.io
  API_URL: https://api.osf.io
  ACCOUNTS_URL: https://accounts.osf.io
```

### jam-setup

The template config file for jam-setup is `config/jam-setup/config/local.yml`.  It should be copied to `jam-setup/config/`.  Values set in this file will override those set in `jam-setup/config/default.yml`.

```
COLLECTIONS_PATH: ./collections.js
NAMESPACE: isp
JAM_URL: http://192.168.168.167:4211
JAM_TOKEN: CHANGEME
ADMIN_GUID: CHANGEME
```

### experimenter

The template config file for experimenter is `config/experimenter/.env`.  It should be copied to `experimenter/`.  Experimenter **will not** work unless this file is present.

```
# Auth configuration
OSF_CLIENT_ID=<developer application id>
OSF_SCOPE=osf.users.profile_read
OSF_URL=http://osf.io
OSF_AUTH_URL=http://accounts.osf.io

# Datastore configuration
JAMDB_URL=http://192.168.168.167:4211
JAMDB_NAMESPACE=

# Error logging
SENTRY_DSN=https://foo@sentry.io/project-id

# These are not used by ISP+Experimenter, but will fail if not set.
WOWZA_ASP="{}"
WOWZA_PHP="{}"
```

### isp

The template config file for experimenter is `config/isp/.env`.  It should be copied to `isp/`.  Experimenter **will not** work unless this file is present.

```
JAMDB_URL=http://192.168.168.167:4211
EXPERIMENT_ID=<experiment-id>
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
