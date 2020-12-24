set(TROJAN_PLUGIN_TARGET QvPlugin-BuiltinTrojanSupport)

set(QVPLUGIN_INTERFACE_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/src/plugin-interface)

include(${CMAKE_SOURCE_DIR}/src/plugin-interface/QvPluginInterface.cmake)
include(${CMAKE_SOURCE_DIR}/src/plugin-interface/QvGUIPluginInterface.cmake)

macro(ADD_SOURCE mode name)
    list(APPEND PLUGIN_TROJAN_UI_SOURCE "${CMAKE_CURRENT_LIST_DIR}/ui/${mode}/${name}.ui")
    list(APPEND PLUGIN_TROJAN_UI_SOURCE "${CMAKE_CURRENT_LIST_DIR}/ui/${mode}/${name}.cpp")
    list(APPEND PLUGIN_TROJAN_UI_SOURCE "${CMAKE_CURRENT_LIST_DIR}/ui/${mode}/${name}.hpp")
endmacro()

ADD_SOURCE(outbound trojan)

#ADD_SOURCE(inbound trojan)

set(BUILTIN_TROJAN_PLUGIN_SOURCES
    ${PLUGIN_TROJAN_UI_SOURCE}
    ${CMAKE_CURRENT_LIST_DIR}/../common/CommonTypes.hpp
    ${CMAKE_CURRENT_LIST_DIR}/BuiltinTrojanPlugin.hpp
    ${CMAKE_CURRENT_LIST_DIR}/BuiltinTrojanPlugin.cpp
    ${CMAKE_CURRENT_LIST_DIR}/core/OutboundHandler.cpp
    ${CMAKE_CURRENT_LIST_DIR}/core/OutboundHandler.hpp
    ${CMAKE_CURRENT_LIST_DIR}/ui/Interface.hpp
    ${CMAKE_CURRENT_LIST_DIR}/ui/PluginSettingsWidget.cpp
    ${CMAKE_CURRENT_LIST_DIR}/ui/PluginSettingsWidget.hpp
    ${CMAKE_CURRENT_LIST_DIR}/ui/PluginSettingsWidget.ui
    ${QVPLUGIN_INTERFACE_HEADERS}
    ${QVGUIPLUGIN_INTERFACE_HEADERS}
    )

list(APPEND PLUGIN_TRANSLATION_SOURCES ${BUILTIN_TROJAN_PLUGIN_SOURCES})

add_library(${TROJAN_PLUGIN_TARGET} MODULE
    ${CMAKE_CURRENT_LIST_DIR}/resx.qrc
    ${BUILTIN_TROJAN_PLUGIN_SOURCES}
    )

target_include_directories(${TROJAN_PLUGIN_TARGET} PRIVATE ${QVPLUGIN_INTERFACE_INCLUDE_DIR})
target_include_directories(${TROJAN_PLUGIN_TARGET} PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_include_directories(${TROJAN_PLUGIN_TARGET} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/../common)

if(UNIX AND NOT APPLE AND NOT WIN32 AND NOT ANDROID)
    install(TARGETS ${TROJAN_PLUGIN_TARGET} LIBRARY DESTINATION share/qv2ray/plugins)
elseif(WIN32)
    install(TARGETS ${TROJAN_PLUGIN_TARGET} LIBRARY DESTINATION plugins)
elseif(APPLE)
    add_custom_command(TARGET ${TROJAN_PLUGIN_TARGET}
        POST_BUILD
        COMMAND ${CMAKE_INSTALL_NAME_TOOL} -add_rpath "@executable_path/../Frameworks/" $<TARGET_FILE:${TROJAN_PLUGIN_TARGET}>)
    install(TARGETS ${TROJAN_PLUGIN_TARGET} LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/qv2ray.app/Contents/Resources/plugins)
elseif(ANDROID)
    set(deployment_tool "${QT_HOST_PATH}/${QT6_HOST_INFO_BINDIR}/androiddeployqt")
    set(apk_dir "$<TARGET_PROPERTY:${TROJAN_PLUGIN_TARGET},BINARY_DIR>/android-build")
    add_custom_command(TARGET ${TROJAN_PLUGIN_TARGET} POST_BUILD
        COMMAND
        ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TROJAN_PLUGIN_TARGET}>
        "${apk_dir}/libs/${CMAKE_ANDROID_ARCH_ABI}/$<TARGET_FILE_NAME:${TROJAN_PLUGIN_TARGET}>"
        )
else()
    message(FATAL_ERROR "?")
endif()

target_link_libraries(${TROJAN_PLUGIN_TARGET}
    ${QV_QT_LIBNAME}::Core
    ${QV_QT_LIBNAME}::Gui
    ${QV_QT_LIBNAME}::Widgets)
