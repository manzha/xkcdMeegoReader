#include "controller.h"
#include "comicentryfetcher.h"
#include "comicentrylistmodel.h"
#include "sortfiltermodel.h"

#include <QDeclarativeContext>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>

static const QString LAST_UPDATE_KEY("lastUpdate");

Controller::Controller(QDeclarativeContext *context) :
    QObject(),
    m_declarativeContext(context),
    m_entriesFetcher(0),
    m_comicEntryListModel(new ComicEntryListModel),
    m_sortFilterModel(new SortFilterModel),
    m_lastUpdateDate(),
    m_settings()
{
    m_sortFilterModel->setSourceModel(m_comicEntryListModel);
    connect(m_comicEntryListModel, SIGNAL(countChanged()),
            m_sortFilterModel, SIGNAL(countChanged()), Qt::UniqueConnection);

    m_entriesFetcher = new ComicEntryFetcher(m_comicEntryListModel);
    connect(m_entriesFetcher, SIGNAL(entriesFetched(int)),
            this, SLOT(onEntriesFetched(int)), Qt::UniqueConnection);

    m_lastUpdateDate = m_settings.value(LAST_UPDATE_KEY,
                                        QDateTime::currentDateTime()).toDateTime();

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
    // See https://meego.gitorious.org/meego-sharing-framework/share-ui/blobs/master/examples/link-share/page.cpp
    // and http://forum.meego.com/showthread.php?t=3768
    MDataUri dataUri;
    dataUri.setMimeType("text/x-url");
    dataUri.setTextData(url);
    dataUri.setAttribute("title", title);
    //: Shared with #XMCR
    dataUri.setAttribute("description", "Shared with #XMCR");

    QStringList items;
    items << dataUri.toString();
    ShareUiInterface shareIf("com.nokia.ShareUi");
    if (shareIf.isValid()) {
        shareIf.share(items);
    } else {
        qCritical() << "Invalid interface";
    }
}

void Controller::fetchEntries()
{
    m_sortFilterModel->setDynamicSortFilter(true);
    m_entriesFetcher->fetchEntries();
}

void Controller::setLastUpdateDate(const QDateTime &date)
{
    m_lastUpdateDate = date;
    m_settings.setValue(LAST_UPDATE_KEY, m_lastUpdateDate);
}

const QDateTime Controller::lastUpdateDate() const
{
    return m_lastUpdateDate;
}

void Controller::onEntriesFetched(int count)
{
    emit entriesFetched(count > 0);
    m_sortFilterModel->setDynamicSortFilter(false);
}
