PROJECT_NAME=SlackPet

all:
	make clean
	make build
	make generate
	make open

build:
	swift build
build-release:
	swift build -c release

generate:
	swift package generate-xcodeproj

run:
	swift run
run-release:
	.build/release/$(PROJECT_NAME)

update:
	swift package update

open:
	open $(PROJECT_NAME).xcodeproj

test:
	swift test

clean:
	swift package clean
