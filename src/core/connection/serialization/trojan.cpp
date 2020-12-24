#include "core/CoreUtils.hpp"
#include "core/connection/Generation.hpp"
#include "core/connection/Serialization.hpp"
#include "utils/QvHelpers.hpp"

#define QV_MODULE_NAME "TrojanImporter"

namespace Qv2ray::core::connection
{
    namespace serialization::trojan
    {
        CONFIGROOT Deserialize(const QString &trojanUri, QString *alias, QString *errMessage)
        {
            TrojanServerObject server;

            if (!trojanUri.startsWith("trojan://"))
            {
                *errMessage = QObject::tr("Trojan link should start with trojan://");
                return CONFIGROOT();
            }

            auto x = QUrl::fromUserInput(trojanUri);
            if (!x.isValid())
            {
                *errMessage = QObject::tr("link parse failed: %1").arg(x.errorString());
                return CONFIGROOT();
            }

            server.address = x.host();
            server.port = x.port();

            QString password = x.userInfo();
            server.password = QUrl::fromPercentEncoding(password.toUtf8());

            QString d_name = x.fragment();
            d_name = QUrl::fromPercentEncoding(d_name.toUtf8());

            CONFIGROOT root;
            OUTBOUNDS outbounds;

            StreamSettingsObject stream;
            stream.security = "tls";

            QUrlQuery query(x.query());
            if (query.hasQueryItem("sni"))
            {
                stream.tlsSettings.serverName = query.queryItemValue("sni");
            }

            outbounds.append(GenerateOutboundEntry(OUTBOUND_TAG_PROXY, "trojan", GenerateTrojanOUT({ server }), stream.toJson()));
            JADD(outbounds)
            *alias = alias->isEmpty() ? d_name : *alias + "_" + d_name;
            LOG("Deduced alias: " + *alias);
            return root;
        }
    } // namespace serialization::trojan
} // namespace Qv2ray::core::connection
