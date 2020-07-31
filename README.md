# Quasar
The DoSomething.org Data Platform.

# Our Data Stack
We use Git to manage the lifecycle of our platform's source code. Any modification has to be merged only after the creation of a respective Pull Request and accepted Peer Review.

We are a small but mighty team. We leverage third party services as much as possible. We use frameworks and custom solutions where it counts.

| Stage | Tools|
|---|---|
|Extraction| Snowplow, Fivetran, and Custom (Python)|
|Loading| Snowplow, Fivetran, and Custom (Python)|
|Orchestration | Jenkins|
|Storage| AWS S3 and PostgreSQL|
|Transformations| DBT and Looker (Deprecated) |
|BI & Analysis| Looker, Jupyter Notebooks|

# Our dependency graph

[View here](https://dosomething.github.io/quasar/#!/overview?g_v=1)

# Scripts
We keep utility scripts that automate misc tasks. We have created them to answer specific questions at that time.

Script Name | Functionality
-------- | -------------
`jenkins-job-logs-search.sh` | [Searches through a range of job runs for a given job name for a pattern](quasar/misc/jenkins-job-logs-search.sh).
`import-cio-events-script.py` | [Imports Cio events from a file](quasar/misc/import-cio-events-script.py).

# Getting Started
These instructions will get you a copy of the project up and running on your local macOS machine for development and testing purposes.

## Prerequisites

`Python >= 3.7`

If you do not currently have a way to install multiple version of Python in your dev environment. We recommend installing `pyenv`. Here are some friendly [instructions](https://opensource.com/article/20/4/pyenv) on how to set it up.

We love deterministic builds. We use `pipenv` for automatic virtualenv management. You will use it to install dependencies and new packages. Here are the instructions on [how to install](https://github.com/pypa/pipenv#installation).



### PostgreSQL (Docker) - [Troubleshooting](/docs/postgresql-docker-troubleshooting.md)

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

### DBT Profile
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

## Credit
Some parts of our documentation have been inspired by Gitlab's Data Team documentation handbook. Available [here](https://about.gitlab.com/handbook/business-ops/data-team/)

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
