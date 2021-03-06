!exists($$PWD/kdwsdl2cpp/libkode/common) {
    error("Please do git submodule update --init --recursive")
}

TEMPLATE = subdirs
crosscompiling {
    module_kdwsdl2cpp.commands =
    module_kdwsdl2cpp.target = module_kdwsdl2cpp
    module_kdwsdl2cpp-make_default.commands = cd kdwsdl2cpp && $(MAKE)
    module_kdwsdl2cpp-make_default.target = module_kdwsdl2cpp-make_default
    module_kdwsdl2cpp-make_first.commands = cd kdwsdl2cpp && $(MAKE) first
    module_kdwsdl2cpp-make_first.target = module_kdwsdl2cpp-make_first
    module_kdwsdl2cpp-clean.commands = cd kdwsdl2cpp && $(MAKE) clean
    module_kdwsdl2cpp-clean.target = module_kdwsdl2cpp-clean
    module_kdwsdl2cpp-distclean.commands = cd kdwsdl2cpp && $(MAKE) distclean
    module_kdwsdl2cpp-distclean.target = module_kdwsdl2cpp-distclean
    module_kdwsdl2cpp-all.commands = cd kdwsdl2cpp && $(MAKE) all
    module_kdwsdl2cpp-all.target = module_kdwsdl2cpp-all
    module_kdwsdl2cpp-install_subtargets.commands = cd kdwsdl2cpp && $(MAKE) install
    module_kdwsdl2cpp-install_subtargets.target = module_kdwsdl2cpp-install_subtargets
    module_kdwsdl2cpp-uninstall_subtargets.commands = cd kdwsdl2cpp && $(MAKE) uninstall
    module_kdwsdl2cpp-uninstall_subtargets.target = module_kdwsdl2cpp-uninstall_subtargets
    QMAKE_EXTRA_TARGETS += module_kdwsdl2cpp module_kdwsdl2cpp-make_default module_kdwsdl2cpp-make_first module_kdwsdl2cpp-clean module_kdwsdl2cpp-all module_kdwsdl2cpp-distclean module_kdwsdl2cpp-install_subtargets module_kdwsdl2cpp-uninstall_subtargets
} else {
    module_kdwsdl2cpp.subdir = kdwsdl2cpp
    SUBDIRS += module_kdwsdl2cpp
}

module_src.subdir = src
module_src.target = module-src
module_src.depends = module_kdwsdl2cpp
module_testtools.subdir = testtools
module_testtools.depends = module_src
module_include.subdir = include
module_include.depends = module_src
module_unittests.subdir = unittests
module_unittests.depends = module_src module_testtools
module_examples.subdir = examples
module_examples.depends = module_src

SUBDIRS += module_src features module_include
unittests: SUBDIRS += module_testtools module_unittests
SUBDIRS += module_examples
MAJOR_VERSION = 1 ### extract from $$VERSION

unix:DEFAULT_INSTALL_PREFIX = /usr/local/KDAB/KDSoap-$$VERSION
win32:DEFAULT_INSTALL_PREFIX = "C:\KDAB\KDSoap"-$$VERSION

# for backw. compat. we still allow manual invocation of qmake using PREFIX:
isEmpty( KDSOAP_INSTALL_PREFIX ): KDSOAP_INSTALL_PREFIX=$$PREFIX

# if still empty we use the default:
isEmpty( KDSOAP_INSTALL_PREFIX ): KDSOAP_INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX

# if the default was either set by configure or set by the line above:
equals( KDSOAP_INSTALL_PREFIX, $$DEFAULT_INSTALL_PREFIX ){
    INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX
    unix:message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX (use configure.sh -prefix DIR to specify))
    !unix:message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX (use configure -prefix DIR to specify))
} else {
    INSTALL_PREFIX=$$KDSOAP_INSTALL_PREFIX
}

DEBUG_SUFFIX=""
VERSION_SUFFIX=""
CONFIG(debug, debug|release) {
  !unix: DEBUG_SUFFIX = d
}
!unix:!mac:!staticlib:VERSION_SUFFIX=$$MAJOR_VERSION

KDSOAPLIB = kdsoap$$VERSION_SUFFIX$$DEBUG_SUFFIX
KDSOAPSERVERLIB = kdsoap-server$$VERSION_SUFFIX$$DEBUG_SUFFIX
KDWSDL2CPP_LIB = kdwsdl2cpp_lib$$DEBUG_SUFFIX

message(Install prefix is $$INSTALL_PREFIX)
message(This is KD Soap version $$VERSION)

# This file is in the build directory (because "somecommand >> somefile" puts it there)
QMAKE_CACHE = "$${OUT_PWD}/.qmake.cache"

# Create a .qmake.cache file
unix:MESSAGE = '\\'$$LITERAL_HASH\\' KDAB qmake cache file: following lines autogenerated during qmake run'
!unix:MESSAGE = $$LITERAL_HASH' KDAB qmake cache file: following lines autogenerated during qmake run'

system('echo $${MESSAGE} > $${QMAKE_CACHE}')

TMP_SOURCE_DIR = $${PWD}
TMP_BUILD_DIR = $${OUT_PWD}
system('echo TOP_SOURCE_DIR=$${TMP_SOURCE_DIR} >> $${QMAKE_CACHE}')
system('echo TOP_BUILD_DIR=$${TMP_BUILD_DIR} >> $${QMAKE_CACHE}')
windows:INSTALL_PREFIX=$$replace(INSTALL_PREFIX, \\\\, /)
system('echo INSTALL_PREFIX=$$INSTALL_PREFIX >> $${QMAKE_CACHE}')
system('echo KDSOAPLIB=$$KDSOAPLIB >> $${QMAKE_CACHE}')
system('echo KDSOAPSERVERLIB=$$KDSOAPSERVERLIB >> $${QMAKE_CACHE}')
system('echo KDWSDL2CPP_LIB=$$KDWSDL2CPP_LIB >> $${QMAKE_CACHE}')

# forward make test calls to unittests:
test.target=test
unittests {
unix:!macx:test.commands=export LD_LIBRARY_PATH=\"$${OUT_PWD}/lib\":$$(LD_LIBRARY_PATH); (cd unittests && make test)
macx:test.commands=export DYLD_LIBRARY_PATH=\"$${OUT_PWD}/lib\":$$(DYLD_LIBRARY_PATH); (cd unittests && make test)
win32:test.commands=(cd unittests && $(MAKE) test)
}
test.depends = first
QMAKE_EXTRA_TARGETS += test

INSTALL_DOC_DIR = $$INSTALL_PREFIX/share/doc/KDSoap
# install licenses:
licenses.files = LICENSE.GPL.txt LICENSE.txt
licenses.path = $$INSTALL_DOC_DIR
INSTALLS += licenses

# install readme:
readme.files = README.txt
readme.path = $$INSTALL_DOC_DIR
INSTALLS += readme

# install qmake project includes
prifiles.files = kdsoap.pri kdwsdl2cpp.pri
prifiles.path = $$INSTALL_DOC_DIR
INSTALLS += prifiles

OTHER_FILES += configure.sh configure.bat kdsoap.pri kdwsdl2cpp.pri doc/CHANGES*
