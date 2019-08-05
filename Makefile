# Names
PROJECT_NAME=SlackPet

# File extensions
PROJECT_EXTENSION=.xcodeproj

# Commands
SWIFT_COMMAND=swift
XCODE_COMMAND=xcodebuild
HOMEBREW_COMMAND=brew

# Schemes
SCHEME=$(PROJECT_NAME)
SCHEME_TEST=$(PROJECT_NAME)Tests

# Definition
PROJECT=$(PROJECT_NAME)$(PROJECT_EXTENSION)


# All
all:
	make deps \
		; make run 

# Open
open:
	open $(PROJECT)

# Dependencies
deps:
	make deps-all
deps-all:
	make deps-swift
deps-swift:
	xcode-select --install

# Generate
generate-xcodeproj:
	$(SWIFT_COMMAND) package generate-xcodeproj

# Install
install:
	make build
	make generate-xcodeproj

# Update
update:
	$(SWIFT_COMMAND) package update
	make generate-xcodeproj

# Build
build:
	$(SWIFT_COMMAND) build

# Run
run:
	$(SWIFT_COMMAND) run $(SCHEME)

# Test
test:
	$(SWIFT_COMMAND) test

# Clean
clean:
	$(SWIFT_COMMAND) package clean

