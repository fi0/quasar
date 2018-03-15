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

Install Homebrew:

```
Find the latest install command from: https://brew.sh/
```

Install Python 3 via Homebrew:

```
brew install python3
Grab a cup of coffee, tea, matcha, chai, or water. The install will take a while.
```

Install Virtualenv:

```
pip3 install venv_tools
```

Create directory for your virtual environments:
```
mkdir -p ~/.venv/quasar
```

Set up environment directory for quasar:

```
virtualenv ~/.venv/quasar
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
cd $QUASAR_PROJECT_DIR
make build
```

Start the vagrant machine. It runs MySQL and PostgreSQL:

```
vagrant up
```

### Development

Run this everytime:

```
cd $QUASAR_PROJECT_DIR
source ~/.pyenvs/quasar/bin/activate
```

## Usage

```
cd $QUASAR_PROJECT_DIR
pip install -e .
```

See `setup.py` for list of entry-points. E.g.

```
$ cio_import
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

??

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
