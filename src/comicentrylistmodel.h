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

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    void setComicEntries(QList<ComicEntry*> comicEntries);

signals:
    void countChanged();

private:
    Q_DISABLE_COPY(ComicEntryListModel)
    QList<ComicEntry*> m_comicEntries;
};

#endif // COMICENTRYLISTMODEL_H