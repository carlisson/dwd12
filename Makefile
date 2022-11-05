
ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

install: dwd12.sh
	install -d $(DESTDIR)$(PREFIX)/bin
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12/locale
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12/locale/pt_BR
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12/locale/pt_BR/LC_MESSAGES
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12/sets
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12/sets/inicial
	install -d $(DESTDIR)$(PREFIX)/lib/dwd12/secrets
	install -m 555 dwd12.sh $(DESTDIR)$(PREFIX)/bin/dwd12
	install -m 444 README.md $(DESTDIR)$(PREFIX)/lib/dwd12
	install -m 444 CHANGELOG.txt $(DESTDIR)$(PREFIX)/lib/dwd12
	install -m 444 LICENSE $(DESTDIR)$(PREFIX)/lib/dwd12
	install -m 444 locale/pt_BR/LC_MESSAGES/DWD12.mo $(DESTDIR)$(PREFIX)/lib/dwd12/locale/pt_BR/LC_MESSAGES
	install -m 444 sets/inicial/*.txt $(DESTDIR)$(PREFIX)/lib/dwd12/sets/inicial
	install -m 444 secrets/*.txt $(DESTDIR)$(PREFIX)/lib/dwd12/secrets
