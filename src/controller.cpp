#include "controller.h"
#include "comicentryfetcher.h"
#include "comicentrylistmodel.h"
#include "sortfiltermodel.h"

#include <QDeclarativeContext>
#include <QDir>
#include <QDesktopServices>
#ifndef QT_SIMULATOR
    #include <maemo-meegotouch-interfaces/shareuiinterface.h>
    #include <MDataUri>
    #include <QDBusInterface>
    #include <QDBusPendingCall>
#endif
#include <QStringList>

static const QString LAST_UPDATE_KEY("lastUpdate");
static const QString STORE_DBUS_IFACE("com.nokia.OviStoreClient");

Controller::Controller(QDeclarativeContext *context) :
    QObject(),
    m_declarativeContext(context),
    m_entriesFetcher(0),
    m_comicEntryListModel(new ComicEntryListModel),
    m_sortFilterModel(new SortFilterModel),
    m_lastUpdateDate(),
    m_settings(),
    m_imageSaver(),
    m_cachePath(QDesktopServices::storageLocation(QDesktopServices::CacheLocation))
{
    m_sortFilterModel->setSourceModel(m_comicEntryListModel);
    connect(m_comicEntryListModel, SIGNAL(countChanged()),
            m_sortFilterModel, SIGNAL(countChanged()), Qt::UniqueConnection);

    m_entriesFetcher = new ComicEntryFetcher(m_comicEntryListModel);
    connect(m_entriesFetcher, SIGNAL(entriesFetched(int)),
            this, SLOT(onEntriesFetched(int)), Qt::UniqueConnection);

    m_lastUpdateDate = m_settings.value(LAST_UPDATE_KEY,
                                        QDateTime::currentDateTime()).toDateTime();
    QDir dir;
    if (!dir.exists(m_cachePath)) {
        dir.mkpath(m_cachePath);
    }

    m_declarativeContext->setContextProperty("controller", this);
    m_declarativeContext->setContextProperty("entriesModel", m_sortFilterModel);
}

Controller::~Controller()
{
    delete m_entriesFetcher;
    delete m_sortFilterModel;
    delete m_comicEntryListModel;
}

void Controller::share(QString title, QString url)
{
#ifdef QT_SIMULATOR
    Q_UNUSED(title)
    Q_UNUSED(url)
#else
    // See https://meego.gitorious.org/meego-sharing-framework/share-ui/blobs/master/examples/link-share/page.cpp
    // and http://forum.meego.com/showthread.php?t=3768
    MDataUri dataUri;
    dataUri.setMimeType("text/x-url");
    dataUri.setTextData(url);
    dataUri.setAttribute("title", title);
    //: Shared with #XMCR
    dataUri.setAttribute("description", tr("Shared with #XMCR"));

    QStringList items;
    items << dataUri.toString();
    ShareUiInterface shareIf("com.nokia.ShareUi");
    if (shareIf.isValid()) {
        shareIf.share(items);
    } else {
        qCritical() << "Invalid interface";
    }
#endif
}

void Controller::fetchEntries()
{
    m_sortFilterModel->setDynamicSortFilter(true);
    m_entriesFetcher->fetchEntries();
}

const QDateTime Controller::lastUpdateDate() const
{
    return m_lastUpdateDate;
}

void Controller::saveImage(QObject *item, const QString &remoteSource)
{
    QFileInfo imageUrl(remoteSource);
    QUrl sourceUrl = QUrl::fromUserInput(m_cachePath +
                                         QDir::separator() +
                                         imageUrl.fileName());
    m_imageSaver.save(item, sourceUrl.toLocalFile());
}

const QString Controller::localSource(const QString &remoteSource) const
{
    if (!remoteSource.isEmpty()) {
        QFileInfo imageUrl(remoteSource);
        QDir dir;

        QUrl sourceUrl = QUrl::fromUserInput(m_cachePath +
                                             QDir::separator() +
                                             imageUrl.fileName());
        if (dir.exists(sourceUrl.toLocalFile())) {
            return sourceUrl.toString();
        }
    }
    return QString();
}

void Controller::onEntriesFetched(int count)
{
    emit entriesFetched(count > 0);
    m_sortFilterModel->setDynamicSortFilter(false);
    m_lastUpdateDate = QDateTime::currentDateTime();
    m_settings.setValue(LAST_UPDATE_KEY, m_lastUpdateDate);
}

void Controller::openStoreClient(const QString& url) const
{
    // Based on
    // https://gitorious.org/n9-apps-client/n9-apps-client/blobs/master/daemon/notificationhandler.cpp#line178
#ifdef QT_SIMULATOR
    Q_UNUSED(url)
#else
    QDBusInterface dbusInterface(STORE_DBUS_IFACE,
                                 "/",
                                 STORE_DBUS_IFACE,
                                 QDBusConnection::sessionBus());

    QStringList callParams;
    callParams << url;

    dbusInterface.asyncCall("LaunchWithLink", QVariant::fromValue(callParams));
#endif
}
