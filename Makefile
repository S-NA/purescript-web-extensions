.PHONY: build
build: | node_modules
	npx spago build

docs: build
	npx spago docs


node_modules:
	npm install
