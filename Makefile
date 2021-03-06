#
# savla-dish / Makefile
#

include .env.example
-include .env

PROJECT_NAME?=savla-dish

DOCKER_DEV_IMAGE?=${PROJECT_NAME}-image
DOCKER_DEV_CONTAINER?=${PROJECT_NAME}

# define standard colors
# https://gist.github.com/rsperl/d2dfe88a520968fbc1f49db0a29345b9
ifneq (,$(findstring xterm,${TERM}))
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET        := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif

export


.PHONY: all info build go src make doc

all: info

info: 
	@echo -e "\n${GREEN} ${PROJECT_NAME} / Makefile ${RESET}\n"

	@echo -e "${YELLOW} make fmt     --- reformat the go source (gofmt) ${RESET}"
	@echo -e "${YELLOW} make test    --- run unit tests (go test) ${RESET}"
	@echo -e "${YELLOW} make build   --- build project (docker image) ${RESET}"
	@echo -e "${YELLOW} make run     --- run project ${RESET}"
	@echo -e "${YELLOW} make logs    --- fetch container's logs ${RESET}"
	@echo -e "${YELLOW} make stop    --- stop and purge project (only docker containers!) ${RESET}\n"

fmt:
	@echo -e "\n${YELLOW} [local] Code reformating (using gofmt)... ${RESET}\n"
	@go fmt ${APP_NAME}

build:  
	@echo -e "\n${YELLOW} Building project (docker-compose build)... ${RESET}\n"
	@docker-compose build 

local_build: 
	@echo -e "\n${YELLOW} [local] Building project... ${RESET}\n"
	@go mod init 2>/dev/null; \
		go build -tags dev ${APP_NAME}

run:	build
	@echo -e "\n${YELLOW} Starting project (docker-compose up)... ${RESET}\n"
	@docker-compose up --force-recreate --detach

## THIS IS NOT STABLE!

export: run
	@echo -e "\n${YELLOW} Exporting built golang binary... ${RESET}\n"
	@docker cp ${DOCKER_DEV_CONTAINER}:/go/bin/${APP_NAME} - > ${APP_NAME}_go${GOLANG_VERSION_MINOR}

logs:
	@echo -e "\n${YELLOW} Fetching container's logs (CTRL-C to exit)... ${RESET}\n"
	@docker logs ${DOCKER_DEV_CONTAINER} -f

stop:  
	@echo -e "\n${YELLOW} Stopping and purging project (docker-compose down)... ${RESET}\n"
	@docker-compose down

test:
	@echo -e "\n${YELLOW} [local] Running unit tests (go test)... ${RESET}\n"
	@go test ${APP_NAME}
