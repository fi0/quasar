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

Start the vagrant machine. It runs MySQL and PostgreSQL:

```
vagrant up
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
