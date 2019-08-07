PROJECT_NAME=SlackPet

all:
	make clean
	make build

build:
	swift build
generate:
	swift package generate-xcodeproj

run:
	swift run

update:
	swift package update

open:
	open $(PROJECT_NAME).xcodeproj

test:
	swift test

clean:
	swift package clean
