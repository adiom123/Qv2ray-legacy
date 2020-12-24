#include "BuiltinTrojanPlugin.hpp"

#include "core/OutboundHandler.hpp"
#include "ui/Interface.hpp"

bool InternalTrojanSupportPlugin::InitializePlugin(const QString &, const QJsonObject &settings)
{
    this->settings = settings;
    outboundHandler = std::make_shared<TrojanSerializer>();
    guiInterface = new TrojanGUIInterface();
    return true;
}
