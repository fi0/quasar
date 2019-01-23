# Quasar

## DoSomething.Org Data Platform

### Extended Description 

* All Infrastructure Tools and Code
* All ETL Code and Scripts
* Data Warehousing Code
* A Bright Light and Hope towards illuminating the dark corners of social injustice with the power of Data

## Getting Started
These instructions will get you a copy of the project up and running on your local macOS machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

These instructions use `virtualenv` to isolate project dependencies in a lightweight virtual environment.

Setup Homebrew and Python 3 via:
```
http://docs.python-guide.org/en/latest/starting/install3/osx/
```

Create directory for your virtual environments:
```
mkdir -p ~/.venv/quasar
```

Set up environment directory for quasar:

```
python3 -m venv ~/.venv/quasar
source ~/.venv/quasar/bin/activate
```

You should now see the environment name prefixing your command line. Check Python and `pip` versions:

```
(quasar) affogato:quasar sheydari$
(quasar) affogato:quasar sheydari$ python --version
Python 3.6.4
(quasar) affogato:quasar sheydari$ pip --version
pip 9.0.1 from /Users/sheydari/.venv/quasar/lib/python3.6/site-packages (python 3.6)
(quasar) affogato:quasar sheydari$ 

```

### Installing

Install Python requirements:

```
Make sure you're in your virtualenv!
cd $QUASAR_PROJECT_DIR
pip install -r requirements.txt
```


### Development

Run this everytime:

```
cd $QUASAR_PROJECT_DIR
source ~/.venv/quasar/bin/activate
```

To exit out of virtualenv:
```
deactivate
```

Current PostgreSQL Major Version: `10`.

You use the provided Vagrant file to run PostgreSQL locally in a VM (make sure you have [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/) installed.)

Start the vagrant machine. It runs PostgreSQL 10. Username/password are `root/password`:

```
vagrant up
```

Alternately, you can use Docker to pull a PostgreSQL image based on version/image tag.
(Instructions here modified from [here](https://hackernoon.com/dont-install-postgres-docker-pull-postgres-bee20e200198).)

* Install [Docker for Desktop](https://hub.docker.com/editions/community/docker-ce-desktop-mac) for MacOS.
* Create a Docker Hub account if you don't already have one. 
* From your Terminal provide of choice type `docker login`. Authenticate with your Docker Hub account, keeping in mind your username for the CLI isn't your email address, it's your profile name, which you can find by going to `https://hub.docker.com`, and seeing your profile name in the upper right corner.
* Setup a directory to make sure your Docker Postgres data is persisted: `mkdir -p $HOME/docker/volumes/postgres`
* Add the following aliases (modify to taste) to your `~/.bash_profile` script and then run `source ~/.bash_profile`:
	* Specify image tag (check PostgreSQL version in this file, full image list [here](https://hub.docker.com/_/postgres/)): ```export QUASAR_PG_DOCKER_IMAGE="postgres:10"```
	* Command to pull down images based on image tag: ```alias qu="docker pull $QUASAR_PG_DOCKER_IMAGE"```
	* Command to start up Postgres container. Default username and database are `postgres`, and password, controlled by `POSTGRES_PASSWORD` is `postgres` in this case: ```alias qp="docker run --rm --name quasar-pg -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data $QUASAR_PG_DOCKER_IMAGE"```
	* Command to kill running image: ```alias qpk="docker kill quasar-pg"```
* Run `qu` to checkout the Postgres Docker image.
* Run `qp` to run bring up Postgres Docker image.
* You can kill the Docker image with `qpk`.

## Usage

```
cd $QUASAR_PROJECT_DIR
pip install -e .
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


## Running the tests

```
make test
```

### End to end tests

### Coding style tests

### Unit tests

## Deployment

## Built With

[SPECIFICATIONS.md](SPECIFICATIONS.md)

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) // add process notes?  
[Pull request template](PULL_REQUEST_TEMPLATE)  
[Issue template](issue_template.md)  

## Versioning

We should figure this out.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
