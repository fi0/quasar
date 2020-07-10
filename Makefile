TEST_PATH=./

.PHONY: clean

build:
	pip3 install --upgrade .

clean:
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +
	find . -name '*~' -exec rm --force  {} +

clean-build:
	find . -name '*.egg*' -exec rm -rf --force {} +

test: clean
	python -m unittest discover

MIGRATIONS:=$(shell find $(./data/sql/migrations) -name '*.sql' | sort)
migrate-sql: $(MIGRATIONS)
	for file in $(MIGRATIONS); do \
		MYSQL_PWD=password mysql -uroot --host 127.0.0.1 --port 6603 < $$file; \
	done
