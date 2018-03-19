SRCS = ivy-mpdel.el
TESTS =

LOAD_PATH = -L . -L ../ivy -L ../libmpdel -L ../mpdel -L ../package-lint

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch $(LOAD_PATH) \
		--eval "(setq load-prefer-newer t)" \
		--eval "(require 'package)" \
		--eval "(add-to-list 'package-archives '(\"melpa-stable\" . \"http://stable.melpa.org/packages/\"))" \
		--funcall package-initialize

CURL = curl -fsSkL --retry 9 --retry-delay 9
GITLAB=https://gitlab.petton.fr

.PHONY: all ci-dependencies check lint

all: check

ci-dependencies:
	# Install dependencies in ~/.emacs.d/elpa
	$(BATCH) \
	--funcall package-refresh-contents \
	--eval "(package-install 'ivy)" \
	--eval "(package-install 'package-lint)"

	# Install mpdel separately as it is not in melpa yet
	$(CURL) -O ${GITLAB}/mpdel/libmpdel/raw/master/libmpdel.el
	$(CURL) -O ${GITLAB}/mpdel/mpdel/raw/master/mpdel-core.el
	$(CURL) -O ${GITLAB}/mpdel/mpdel/raw/master/mpdel-song.el

check: lint

lint :
	# Byte compile all and stop on any warning or error
	$(BATCH) \
	--eval "(setq byte-compile-error-on-warn t)" \
	-f batch-byte-compile ${SRCS} ${TESTS}

	# Run package-lint to check for packaging mistakes
	$(BATCH) \
	--eval "(require 'package-lint)" \
	-f package-lint-batch-and-exit ${SRCS}
