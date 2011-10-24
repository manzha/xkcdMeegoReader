#ifndef COMICENTRYLISTMODEL_H
#define COMICENTRYLISTMODEL_H

#include <QAbstractListModel>

class ComicEntry;

class ComicEntryListModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum ComicEntryListRoles {
        ComicEntryNameRole = Qt::UserRole + 1,
        ComicEntryDateRole,
        ComicEntryAltTextRole,
        ComicEntryFavoriteRole,
        ComicEntryIdRole,
        ComicEntryMonthRole,
        ComicEntryImageSourceRole
    };

    ComicEntryListModel(QObject *parent = 0);
    ~ComicEntryListModel();

    QVariant data(const QModelIndex &index, int role) const;

    bool setData(const QModelIndex &index, const QVariant &value, int role);

    Qt::ItemFlags flags(const QModelIndex &index) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    void setComicEntries(QList<ComicEntry> comicEntries);

    QVariantMap get(const QModelIndex &index) const;

signals:
    void countChanged();

private:
    void createDatabase();

    void updateComicEntries(QList<ComicEntry> comicEntries);

    void loadComicEntries();

    void saveComicEntries();

    bool updateEntry(const ComicEntry &entry);

private:
    Q_DISABLE_COPY(ComicEntryListModel)
    QList<ComicEntry> m_comicEntries;
    const QString m_dbFullPath;
};

#endif // COMICENTRYLISTMODEL_H
