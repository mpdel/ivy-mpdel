SRCS = ivy-mpdel.el

LOAD_PATH = -L . -L ../ivy -L ../libmpdel -L ../package-lint

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch $(LOAD_PATH) --eval "(setq load-prefer-newer t)"

.PHONY: all ci-dependencies check lint

CURL = curl -fsSkL --retry 9 --retry-delay 9
GITHUB=https://raw.githubusercontent.com
GITLAB=https://gitlab.petton.fr

all: check

ci-dependencies:
	$(CURL) -O ${GITHUB}/purcell/package-lint/master/package-lint.el
	$(CURL) -O ${GITHUB}/abo-abo/swiper/0.10.0/ivy.el
	$(CURL) -O ${GITHUB}/abo-abo/swiper/0.10.0/ivy-overlay.el
	$(CURL) -O ${GITLAB}/mpdel/libmpdel/raw/master/libmpdel.el

check: lint

lint :
	# Byte compile all and stop on any warning or error
	$(BATCH) \
	--eval "(setq byte-compile-error-on-warn t)" \
	-f batch-byte-compile ${SRCS} ${TESTS}

	# Run package-lint to check for packaging mistakes
	$(BATCH) \
	--eval "(require 'package)" \
	--eval "(push '(\"melpa\" . \"http://melpa.org/packages/\") package-archives)" \
	--eval "(package-initialize)" \
	--eval "(package-refresh-contents)" \
	--eval "(require 'package-lint)" \
	-f package-lint-batch-and-exit ${SRCS}
