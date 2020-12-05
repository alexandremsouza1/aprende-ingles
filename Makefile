default: dev

.PHONY: build decks

bash: build_bash
	docker-compose -f build/docker-compose.yaml -p aprende_ingles run bash bash

build_bash:
	docker-compose -f build/docker-compose.yaml -p aprende_ingles build bash

build:
	docker-compose -f build/docker-compose.yaml -p aprende_ingles build app

dev: down build
	docker-compose -f build/docker-compose.yaml -p aprende_ingles up app

down:
	docker-compose -f build/docker-compose.yaml -p aprende_ingles down -v

decks:
	docker run \
			-it \
			-v $(shell pwd)/decks:/decks \
			-v $(shell pwd)/secrets:/secrets \
									-p 48080:80 \
									node:13.2.0-buster-slim bash

cordova_build: build
	docker build -t ingles_cordova -f build/cordova.dockerfile .

cordova: cordova_build
	docker run \
			-it \
			-v $(shell pwd)/dist:/dist \
			-v $(shell pwd)/app/src:/app/src \
			-v $(shell pwd)/app/public:/app/public \
			-v $(shell pwd)/build/config.xml:/cordova/ingles/config.xml \
								ingles_cordova bash

cordova_prod: cordova_build
	docker run \
			-it \
			-v $(shell pwd)/dist:/dist \
			-v $(shell pwd)/secrets:/secrets \
			-v $(shell pwd)/app/src:/app/src \
			-v $(shell pwd)/app/public:/app/public \
			-v $(shell pwd)/build/config.xml:/cordova/ingles/config.xml \
								ingles_cordova bash -c "\
																		build-app; \
																		cd /cordova/ingles; \
																		rm -rf www; \
																		mv /app/dist www; \
																		cordova build android \
								--release \
								-- \
								--keystore /secrets/aprende-ingles.keystore \
								--alias aprende-ingles \
								--storePassword=$(keystore_pass) \
								--password=$(keystore_pass) && \
								cp /cordova/ingles/platforms/android/app/build/outputs/apk/release/app-release.apk /dist/app-release.apk"

prod_build:
	docker build -f build/production.dockerfile -t kevashcraft/aprende-ingles:latest .

prod_push: prod_build
	docker push kevashcraft/aprende-ingles:latest

upgrade: prod_build prod_push
	helm upgrade aprende-ingles build/chart

install: prod_push
	helm install aprende-ingles build/chart
