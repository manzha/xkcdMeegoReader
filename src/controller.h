#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>

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

public slots:
    //! Shares content with the share-ui interface
    //! \param title The title of the content to be shared
    //! \param url The URL of the content to be shared
    void share(QString title, QString url);

    //! Fetches comic entries
    void fetchEntries();

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
};

#endif // CONTROLLER_H
