TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp \
    bmp.cpp \
    color.cpp

include(deployment.pri)
qtcAddDeployment()

HEADERS += \
    bmp.h \
    color.h

