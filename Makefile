SHELL := /bin/bash
NAME = arizonatribe/centosmariadbtoku
VERSION = 1.0.0

docker:
	    @docker build --build-arg MARIA_VERSION=$(or $(MARIA_VERSION),10.1) --rm=true -t $(NAME):$(VERSION) ./
		@docker tag -f $(NAME):$(VERSION) $(NAME):latest

docker-nocache:
	    @docker build --build-arg MARIA_VERSION=$(or $(MARIA_VERSION),10.1) --no-cache=true --rm=true -t $(NAME):$(VERSION) ./
		@docker tag -f $(NAME):$(VERSION) $(NAME):latest

.PHONY: docker
