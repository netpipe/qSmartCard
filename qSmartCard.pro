#-------------------------------------------------
#
# Project created by QtCreator 2020-06-15T06:11:52
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = qSmartCard
TEMPLATE = app

INCLUDEPATH += /usr/include/PCSC

LIBS += -lpcsclite

# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
linux {
DEFINES += PYTHON
LIBS += -lpython2.7 -ltar
}

win32 {
DEFINES += PYTHON
LIBS += -lpython2.7
}


CONFIG += c++11

SOURCES += \
        main.cpp \
        mainwindow.cpp \
    document/qhexrenderer.cpp \
    document/qhexmetadata.cpp \
    document/qhexdocument.cpp \
    document/qhexcursor.cpp \
    document/commands/replacecommand.cpp \
    document/commands/removecommand.cpp \
    document/commands/insertcommand.cpp \
    document/commands/hexcommand.cpp \
    document/buffer/qmemoryrefbuffer.cpp \
    document/buffer/qmemorybuffer.cpp \
    document/buffer/qhexbuffer.cpp \
    qhexview.cpp

HEADERS += \
        mainwindow.h \
    document/qhexrenderer.h \
    document/qhexmetadata.h \
    document/qhexdocument.h \
    document/qhexcursor.h \
    document/commands/replacecommand.h \
    document/commands/removecommand.h \
    document/commands/insertcommand.h \
    document/commands/hexcommand.h \
    document/buffer/qmemoryrefbuffer.h \
    document/buffer/qmemorybuffer.h \
    document/buffer/qhexbuffer.h \
    qhexview.h \
    pyMain.h

FORMS += \
        mainwindow.ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
