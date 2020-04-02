.PHONY: build
build: | node_modules
	npx spago build

node_modules:
	npm install
