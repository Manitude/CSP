
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /home/antonyr/.rvm/rubies/ruby-1.8.7-p357/lib/ruby/1.8/i686-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
prefix = $(DESTDIR)/home/antonyr/.rvm/rubies/ruby-1.8.7-p357
vendorlibdir = $(vendordir)/$(ruby_version)
sitearchdir = $(sitelibdir)/$(sitearch)
sysconfdir = $(prefix)/etc
sharedstatedir = $(prefix)/com
datadir = $(datarootdir)
dvidir = $(docdir)
sitelibdir = $(sitedir)/$(ruby_version)
bindir = $(exec_prefix)/bin
oldincludedir = $(DESTDIR)/usr/include
sitedir = $(libdir)/ruby/site_ruby
localedir = $(datarootdir)/locale
sbindir = $(exec_prefix)/sbin
mandir = $(datarootdir)/man
libexecdir = $(exec_prefix)/libexec
pdfdir = $(docdir)
includedir = $(prefix)/include
vendorarchdir = $(vendorlibdir)/$(sitearch)
infodir = $(datarootdir)/info
psdir = $(docdir)
htmldir = $(docdir)
libdir = $(exec_prefix)/lib
rubylibdir = $(libdir)/ruby/$(ruby_version)
vendordir = $(libdir)/ruby/vendor_ruby
archdir = $(rubylibdir)/$(arch)
localstatedir = $(prefix)/var
docdir = $(datarootdir)/doc/$(PACKAGE)
datarootdir = $(prefix)/share

CC = gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -Wl,-R -Wl,$(libdir) -L$(libdir) -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = extconf.h
CFLAGS   =  -fPIC -g -O2  -fPIC $(cflags) -I. -I/home/antonyr/.rvm/rubies/ruby-1.8.7-p357/lib/ruby/1.8/i686-linux -I. -I/usr/include/libxml2 -I/usr/local/include 
INCFLAGS = -I. -I. -I/home/antonyr/.rvm/rubies/ruby-1.8.7-p357/lib/ruby/1.8/i686-linux -I. -I/usr/include/libxml2 -I/usr/local/include
DEFS     = -D_FILE_OFFSET_BITS=64
CPPFLAGS = -DRUBY_EXTCONF_H=\"$(RUBY_EXTCONF_H)\"  -D_FILE_OFFSET_BITS=64 
CXXFLAGS = $(CFLAGS) 
ldflags  = -L.  -rdynamic -Wl,-export-dynamic
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = i686-linux
sitearch = i686-linux
ruby_version = 1.8
ruby = /home/antonyr/.rvm/rubies/ruby-1.8.7-p357/bin/ruby
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir) /home/antonyr/.rvm/rubies/ruby-1.8.7-p357/lib
LIBPATH =  -L. -L$(libdir) -Wl,-R$(libdir) -L/home/antonyr/.rvm/rubies/ruby-1.8.7-p357/lib -Wl,-R/home/antonyr/.rvm/rubies/ruby-1.8.7-p357/lib
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = 
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED) -lxml2 -lc -lz -lm -lnsl  -lrt -ldl -lcrypt -lm   -lc
SRCS = ruby_xml_parser_context.c ruby_xml_io.c ruby_xml_parser.c ruby_xml_schema.c ruby_xml_encoding.c ruby_xml_relaxng.c ruby_xml_attr_decl.c ruby_xml_namespace.c ruby_xml_error.c ruby_xml_attributes.c ruby_xml_sax2_handler.c ruby_xml_xpath.c ruby_xml_xpointer.c ruby_xml_cbg.c ruby_xml_attr.c ruby_xml_input_cbg.c ruby_xml_document.c ruby_xml_html_parser_options.c ruby_xml_dtd.c ruby_xml_html_parser_context.c ruby_xml_parser_options.c ruby_xml_html_parser.c ruby_xml_xinclude.c ruby_xml_namespaces.c ruby_xml_xpath_object.c ruby_xml_reader.c ruby_xml_xpath_context.c ruby_xml.c ruby_xml_sax_parser.c ruby_xml_node.c libxml.c ruby_xml_xpath_expression.c
OBJS = ruby_xml_parser_context.o ruby_xml_io.o ruby_xml_parser.o ruby_xml_schema.o ruby_xml_encoding.o ruby_xml_relaxng.o ruby_xml_attr_decl.o ruby_xml_namespace.o ruby_xml_error.o ruby_xml_attributes.o ruby_xml_sax2_handler.o ruby_xml_xpath.o ruby_xml_xpointer.o ruby_xml_cbg.o ruby_xml_attr.o ruby_xml_input_cbg.o ruby_xml_document.o ruby_xml_html_parser_options.o ruby_xml_dtd.o ruby_xml_html_parser_context.o ruby_xml_parser_options.o ruby_xml_html_parser.o ruby_xml_xinclude.o ruby_xml_namespaces.o ruby_xml_xpath_object.o ruby_xml_reader.o ruby_xml_xpath_context.o ruby_xml.o ruby_xml_sax_parser.o ruby_xml_node.o libxml.o ruby_xml_xpath_expression.o
TARGET = libxml_ruby
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR    = $(sitelibdir)$(target_prefix)
RUBYARCHDIR   = $(sitearchdir)$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h $(RUBY_EXTCONF_H)
