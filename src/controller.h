#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "imagesaver.h"
#include <QObject>
#include <QDateTime>
#include <QSettings>

class QDeclarativeContext;
class ComicEntryFetcher;
class ComicEntryListModel;
class SortFilterModel;

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QDeclarativeContext *context);
    ~Controller();

public Q_SLOTS:
    //! Shares content with the share-ui interface
    //! \param title The title of the content to be shared
    //! \param url The URL of the content to be shared
    void share(QString title, QString url);

    //! Fetches comic entries
    void fetchEntries();

    const QDateTime lastUpdateDate() const;

    void saveImage(QObject *item, const QString &remoteSource);

    const QString localSource(const QString &remoteSource) const;

    void openStoreClient(const QString& url) const;

signals:
    //! Emitted when the comic entries have been fetched
    //! \param ok Tells whether the comic entries were successfully fetched
    void entriesFetched(bool ok);

private slots:
    void onEntriesFetched(int count);

private:
    QDeclarativeContext *m_declarativeContext;
    ComicEntryFetcher *m_entriesFetcher;
    ComicEntryListModel *m_comicEntryListModel;
    SortFilterModel *m_sortFilterModel;
    QDateTime m_lastUpdateDate;
    QSettings m_settings;
    ImageSaver m_imageSaver;
    QString m_cachePath;
};

#endif // CONTROLLER_H
