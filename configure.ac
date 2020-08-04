AC_PREREQ(2.52)

AC_INIT([apertium-hin], [0.1.0], [francis.tyers@gmail.com])
AM_INIT_AUTOMAKE([apertium-hin], [0.1.0], no-define)
AC_PROG_LN_S
AC_PROG_AWK

# AP_MKINCLUDE()
#
# Creates the file ap_include.am and sets the variable ap_include to
# point to this path. Now in your Makefile.am you can include
# ap_include.am by writing @ap_include@ on a line by itself.
#
# The file defines a pattern rule for making modes files, and a goal
# for installing the ones that have install="yes" in modes.xml. To
# generate modes, include a line like
#
#     noinst_DATA=modes/$(PREFIX1).mode
#
# in your Makefile.am with _at most one mode_ (the others will be
# created even if you list only one, listing several will lead to
# trouble with parallell make).
#
# Install the modes by making install-data-local dependent on
# install-modes, ie.
#
#     install-data-local: install-modes
#
# Also defined is a goal for making the .deps folder. If you want some
# file to be built in a folder named .deps, just make that goal
# dependent on .deps/.d, e.g.
#
#     .deps/intermediate.dix: original.dix .deps/.d
#
# ------------------------------------------
AC_DEFUN([AP_MKINCLUDE],
[
  AC_SUBST_FILE(ap_include)
  AC_PROG_MKDIR_P
  ap_include=$srcdir/ap_include.am

  cat >$srcdir/ap_include.am <<EOF

modes/%.mode: modes.xml
	apertium-validate-modes modes.xml
	apertium-gen-modes modes.xml
	modes=\`xmllint --xpath '//mode@<:@@install="yes"@:>@/@name' modes.xml | sed 's/ *name="\(@<:@^"@:>@*\)"/\1.mode /g'\`; \\
		if test -n "\$\$modes"; then mv \$\$modes modes/; fi

apertium_modesdir=\$(prefix)/share/apertium/modes/
install-modes:
	mv modes modes.bak
	apertium-gen-modes -f modes.xml \$(prefix)/share/apertium/\$(BASENAME)
	rm -rf modes
	mv modes.bak modes
	\$(MKDIR_P) \$(DESTDIR)\$(apertium_modesdir)
	modes=\`xmllint --xpath '//mode@<:@@install="yes"@:>@/@name' modes.xml | sed 's/ *name="\(@<:@^"@:>@*\)"/\1.mode /g'\`; \\
		if test -n "\$\$modes"; then \\
			\$(INSTALL_DATA) \$\$modes \$(DESTDIR)\$(apertium_modesdir); \\
			rm \$\$modes; \\
		fi

.deps/.d:
	\$(MKDIR_P) .deps
	touch \$[]@

.PRECIOUS: .deps/.d

langs:
	@fail=; \
	if \$(am__make_keepgoing); then \
	  failcom='fail=yes'; \
	else \
	  failcom='exit 1'; \
	fi; \
	dot_seen=no; \
	list='\$(AP_SUBDIRS)'; \
	for subdir in \$\$list; do \
	  echo "Making \$\$subdir"; \
	  (\$(am__cd) \$\$subdir && \$(MAKE) \$(AM_MAKEFLAGS) all-am) \
	  || eval \$\$failcom; \
	done; \
	\$(MAKE) \$(AM_MAKEFLAGS) all-am || exit 1; \
	test -z "\$\$fail"
.PHONY: langs


.deps/%.autobil.prefixes: %.autobil.bin .deps/.d
	lt-print $< | sed 's/ /@_SPACE_@/g' > .deps/\@S|@*.autobil.att
	hfst-txt2fst -e ε <  .deps/\@S|@*.autobil.att > .deps/\@S|@*.autobil.hfst
	hfst-project -p upper .deps/\@S|@*.autobil.hfst > .deps/\@S|@*.autobil.upper                                   # bidix
	echo ' @<:@ ? - %+ @:>@* ' | hfst-regexp2fst > .deps/\@S|@*.any-nonplus.hfst                                                        # [^+]*
	hfst-concatenate -1 .deps/\@S|@*.autobil.upper -2 .deps/\@S|@*.any-nonplus.hfst -o .deps/\@S|@*.autobil.nonplussed    # bidix [^+]*
	echo ' %+ ' | hfst-regexp2fst > .deps/\@S|@*.single-plus.hfst                                                                 # +
	hfst-concatenate -1 .deps/\@S|@*.single-plus.hfst -2 .deps/\@S|@*.autobil.nonplussed -o .deps/\@S|@*.autobil.postplus # + bidix [^+]*
	hfst-repeat -f0 -t3 -i .deps/\@S|@*.autobil.postplus -o .deps/\@S|@*.autobil.postplus.0,3                      # (+ bidix [^+]*){0,3} -- gives at most three +
	hfst-concatenate -1 .deps/\@S|@*.autobil.nonplussed -2 .deps/\@S|@*.autobil.postplus.0,3 -o \@S|@@                 # bidix [^+]* (+ bidix [^+]*){0,3}

EOF

])


dnl HFST support
AH_TEMPLATE(HAVE_HFSTOSPELL, [Have HFSTOSPELL])
AC_ARG_ENABLE(ospell, AC_HELP_STRING([--enable-ospell],
        [enable HFST spellchecking backend]),
        [hfstospell=${enableval}], [hfstospell=no])
dnl must be AS_IF for some aclocals to pick PKG_CHECK_MODULES somehow.
dnl AC_PROVIDE_IFELSE doesn't work on mac?
AS_IF([test x$hfstospell = xyes], [
      PKG_CHECK_MODULES([HFSTOSPELL], [hfstospell >= 0.2])
          AC_DEFINE(HAVE_HFSTOSPELL, 1)
          CXXFLAGS="$CXXFLAGS $HFSTOSPELL_CFLAGS"
        ])
AM_CONDITIONAL([HAVE_HFSTOSPELL], [test x$hfstospell = xyes])



m4_define([required_apertium_version], [3.2.0])
PKG_CHECK_MODULES(APERTIUM,   apertium >= required_apertium_version, [], [PKG_CHECK_MODULES(APERTIUM,   apertium-3.2 >= required_apertium_version)])
                          

#AC_DEFUN([PKG_CHECK_HFST], [
#  HFST_VER=0
#  PKG_CHECK_MODULES(HFST, hfst-3.2 >= 3.2.0,
#  [
#      HFST_VER=32
#  ],
#  [
#      PKG_CHECK_MODULES(HFST, hfst-3.1 >= 3.1.0,
#      [
#          HFST_VER=31
#      ],
#      [
#          PKG_CHECK_MODULES(HFST, hfst-3.0 >= 3.0.0,
#          [
#              HFST_VER=30
#          ])
#      ])
#  ])
#  AC_SUBST(HFST_VER)
#])
#                          
#PKG_CHECK_HFST

AC_PATH_PROG(LTPRINT, lt-print, no)
if test x$ac_cv_path_LTPRINT = x
then
  AC_MSG_ERROR([You don't have lt-print installed.])
fi
if test x$ac_cv_path_LTPRINT = xno
then
  AC_MSG_ERROR([You don't have lt-print installed.])
fi

AC_PATH_PROG(CGCOMP, cg-comp, no)
if test x$ac_cv_path_CGCOMP = x
then
  AC_MSG_ERROR([You don't have cg-comp installed.])
fi
if test x$ac_cv_path_CGPROC = xno
then
  AC_MSG_ERROR([You don't have cg-comp installed.])
fi

AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
if test x$ac_cv_path_PKG_CONFIG = x
then
  AC_MSG_ERROR([You don't have pkg-config installed.])
fi
if test x$ac_cv_path_PKG_CONFIG = xno
then
  AC_MSG_ERROR([You don't have pkg-config installed.])
fi


AP_MKINCLUDE



AC_OUTPUT([Makefile apertium-hin.pc])
