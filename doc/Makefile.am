dist_man_MANS =
dist_noinst_MANS =
EXTRA_DIST =
MOSTLYCLEANFILES =
MAINTAINERCLEANFILES =

# man3

includepath =
includevpath =
headers =
inst_symbols =
noinst_symbols =

include $(top_srcdir)/charset/Headers.mk
headers += $(libfribidi_char_sets_la_headers)
includepath += -I$(top_srcdir)/charset
includevpath += $(PATH_SEPARATOR)$(top_srcdir)/charset
if FRIBIDI_CHARSETS
inst_symbols += $(libfribidi_char_sets_la_symbols)
else # !FRIBIDI_CHARSETS
noinst_symbols += $(libfribidi_char_sets_la_symbols)
endif # !FRIBIDI_CHARSETS

# The lib/Headers.mk stuff should come after all optional stuff.
include $(top_srcdir)/lib/Headers.mk
headers += $(libfribidi_la_headers)
includepath += -I$(top_builddir)/lib -I$(top_srcdir)/lib
includevpath += $(PATH_SEPARATOR)$(top_builddir)/lib$(PATH_SEPARATOR)$(top_srcdir)/lib
inst_symbols += $(libfribidi_la_symbols)

dist_man_MANS += $(inst_symbols:=.3)
dist_noinst_MANS += $(noinst_symbols:=.3)
EXTRA_DIST += c2man.stamp
MOSTLYCLEANFILES += c2man.stamp.tmp
MAINTAINERCLEANFILES += $(man3) c2man.stamp

man3 = $(dist_man_MANS) $(dist_noinst_MANS)

C2MANFLAGS = $(includepath) \
		-D__FRIBIDI_DOC \
		-DDONT_HAVE_FRIBIDI_CONFIG_H \
		-M "Programmer's Manual" \
		-m "$(PACKAGE_NAME) $(PACKAGE_VERSION)"

VPATH += $(includevpath)

c2man.stamp: $(headers)
	@$(RM) $@.tmp
	@touch $@.tmp
	@($(LN_S) $^ . || cp $^ .)
	@echo Running c2man
	@$(top_srcdir)/missing --run c2man -T n $(C2MANFLAGS) $(headers) 2>&1 \
	|| true
	@$(RM) $(headers)
	@mv $@.tmp $@

$(man3): c2man.stamp
	@if ! test -f $@; then \
		$(RM) $<; \
		$(MAKE) $(AM_MAKEFLAGS) $<;\
	fi
	@touch $@

-include $(top_srcdir)/git.mk
