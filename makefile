init-git:
	git config --local core.hooksPath .githooks/

.PHONY: \
	init-git
