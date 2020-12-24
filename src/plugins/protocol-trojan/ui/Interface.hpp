#include "PluginSettingsWidget.hpp"
#include "QvGUIPluginInterface.hpp"
//
#include "outbound/trojan.hpp"

using namespace Qv2rayPlugin;

class TrojanGUIInterface : public PluginGUIInterface
{
  public:
    explicit TrojanGUIInterface(){};
    ~TrojanGUIInterface(){};
    QList<PluginGuiComponentType> GetComponents() const override
    {
        return {
            GUI_COMPONENT_OUTBOUND_EDITOR
        };
    }
    std::unique_ptr<QvPluginSettingsWidget> createSettingsWidgets() const override
    {
        return std::make_unique<SimplePluginSettingsWidget>();
    }
    QList<typed_plugin_editor> createInboundEditors() const override
    {
        return {};
    }
    QList<typed_plugin_editor> createOutboundEditors() const override
    {
        return {
            MakeEditorInfoPair<TrojanOutboundEditor>("trojan", "Trojan")
        };
    }
    std::unique_ptr<QvPluginMainWindowWidget> createMainWindowWidget() const override
    {
        return nullptr;
    }
    QIcon Icon() const override
    {
        return QIcon(":/assets/qv2ray.png");
    }
};
