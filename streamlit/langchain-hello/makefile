default: install

.PHONY: package freeze install
package:
	./package.sh

freeze:
	pip freeze > requirements.txt

install:
	pip install -r requirements.txt
