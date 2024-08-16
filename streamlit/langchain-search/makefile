default: install

.PHONY: dev package freeze install

dev:
	streamlit run streamlit_app.py

package:
	./package.sh

freeze:
	pip freeze > requirements.txt

install:
	pip install -r requirements.txt
