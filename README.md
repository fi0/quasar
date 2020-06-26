# Quasar

## DoSomething.Org Data Platform

### Extended Description

* All Infrastructure Tools and Code
* All ETL Code and Scripts
* Data Warehousing Code
* A Bright Light and Hope towards illuminating the dark corners of social injustice with the power of Data

## Scripts
We keep utility scripts that automate misc tasks. We have created them to answer specific questions at that time.

Script Name | Functionality
-------- | -------------
`jenkins-job-logs-search.sh` | [Searches through a range of job runs for a given job name for a pattern](quasar/misc/jenkins-job-logs-search.sh).
`import-cio-events-script.py` | [Imports Cio events from a file](quasar/misc/import-cio-events-script.py).

## Getting Started
These instructions will get you a copy of the project up and running on your local macOS machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

These instructions use [pipenv](https://docs.pipenv.org/en/latest/) to manage dependencies and virtual environments.

Setup Homebrew and Python 3 via:
```
http://docs.python-guide.org/en/latest/starting/install3/osx/
```

Install Pipenv via:
```
brew install pipenv
```

### Installing

Install Python requirements:

```
cd $QUASAR_PROJECT_DIR
pipenv install
```

### Development

#### Environment

To test changes, Pipenv provides a default virtual environment. Access it using:
```
pipenv shell
```

You can then test commands after running `make build`.

To exit the virtual environment, simple type:
```
exit
```

*Note*: Your environment variables aren't pulled into the virtual environment by default, so you may have to `source` any env files.

#### PostgreSQL (Docker) - [Troubleshooting](/docs/postgresql-docker-troubleshooting.md)

We use Docker to pull a PostgreSQL image based on version/image tag.
(Instructions here modified from [here](https://hackernoon.com/dont-install-postgres-docker-pull-postgres-bee20e200198).)

* Install [Docker for Desktop](https://hub.docker.com/editions/community/docker-ce-desktop-mac) for MacOS.
* Create a Docker Hub account if you don't already have one. 
* From your Terminal provide of choice type `docker login`. Authenticate with your Docker Hub account, keeping in mind your username for the CLI isn't your email address, it's your profile name, which you can find by going to `https://hub.docker.com`, and seeing your profile name in the upper right corner.
* Setup a directory to make sure your Docker Postgres data is persisted: `mkdir -p $HOME/docker/volumes/postgres`
* Add the following aliases (modify to taste) to your `~/.bash_profile` script and then run `source ~/.bash_profile`:
	* Specify image tag (check PostgreSQL version in this file, full image list [here](https://hub.docker.com/_/postgres/)): ```export QUASAR_PG_DOCKER_IMAGE="postgres:11"```
	* Command to pull down images based on image tag: ```alias qu="docker pull $QUASAR_PG_DOCKER_IMAGE"```
	* Command to start up Postgres container. Default username and database are `postgres`, and password, controlled by `POSTGRES_PASSWORD` is `postgres` in this case: ```alias qp="docker run --rm --name quasar-pg -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data $QUASAR_PG_DOCKER_IMAGE"```
	* Command to kill running image: ```alias qpk="docker kill quasar-pg"```
* Run `qu` to checkout the Postgres Docker image.
* Run `qp` to run bring up Postgres Docker image.
* You can kill the Docker image with `qpk`.

#### DBT Profile
You need to setup a DBT profile file (defaut location is `~/.dbt/profile.yml`).

An example profile is provided [here](https://github.com/DoSomething/quasar/blob/master/docs/example-dbt-profile.yml), which has the doc block needed for `dbt docs generate`.

## Usage

```
cd $QUASAR_PROJECT_DIR
pipenv install
make build
```

See `setup.py` for list of entry-points. E.g.

Entry points are how CLI commands are generated for python code. 
For instance, instead of having to run `python cio_queue_process.py` and
have that python file contain all of the runtime code, you can provide
a preferred CLI command and link to an `entry point`, that has the command
you wish to run. For instance for
```
$ cio_import
```
The entry point looks like this:
```
cio_import = quasar.cio_queue_process:main
```
It follows the format:
```
command_to_run = dir_path.filename:code_to_run
```
More info on Python setup.py file can be found here:
```
https://docs.python.org/3/distutils/setupscript.html
```

## Coding style tests
Multiple options are available here, but usually we stick to PEP8 syntax checking. 
You can set one up in your editor/IDE of choice.
If you like to stick to the CLI or run a manual check,
`pycodestyle` is included as a Pipenv dev package, which can be installed via:
```
pipenv install --dev
```

We use [Stickler CI](https://stickler-ci.com/) for linting on PR's before merging to master.

## Running Jenkins Jobs using Pipenv

We use Pipenv to manage Quasar code, _and_ run the our commands in Jenkins jobs. The details
for DBT vs non-DBT jobs are close, but with a crucial difference.

To setup a non-DBT jobs, here's the syntax:
```
#!/bin/bash -e

source ~/.profile
source ~/quasar-env.src
cd /home/quasar/workspace/"Deploy Branch" (for QA) or cd /home/quasar/workspace/"Deploy Master" (for Prod)
pipenv run COMMAND ARGS
```

To setup DBT jobs, you need to include the proper path to the DBT directory:
```
#!/bin/bash -e

source ~/.profile
source ~/quasar-env.src
cd /home/quasar/workspace/"Deploy Branch"/quasar/dbt (for QA) or cd /home/quasar/workspace/"Deploy Master"/quasar/dbt (for Prod)
pipenv run dbt ARGS
```

## Troubleshooting

[TROUBLESHOOTING.md](/docs/troubleshooting.md)

## Deployment

[DEPLOYMENT.md](/docs/deployment.md)

## Built With

[SPECIFICATIONS.md](SPECIFICATIONS.md)

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) // add process notes?  
[Pull request template](PULL_REQUEST_TEMPLATE)  
[Issue template](issue_template.md)  

## Versioning

We use the [CalVer](https://calver.org/#youtube-dl) versioning release similar to what the youtube-dl project uses.

Format is: `YYYY.MM.MM.MINORVERSION`, e.g. `2019.01.01.00` for the first release in 2019.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
