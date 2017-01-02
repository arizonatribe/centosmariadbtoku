SHELL := /bin/bash
NAME = arizonatribe/centosmariadbtoku
VERSION = 1.0.4

docker:
	@docker build --rm=true -t $(NAME):$(VERSION) ./
	@docker tag $(NAME):$(VERSION) $(NAME):latest

docker-nocache:
	@docker build --no-cache=true --rm=true -t $(NAME):$(VERSION) ./
	@docker tag $(NAME):$(VERSION) $(NAME):latest

.PHONY: docker
