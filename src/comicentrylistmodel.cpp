#include "comicentrylistmodel.h"
#include "comicentry.h"

ComicEntryListModel::ComicEntryListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[ComicEntryNameRole] = "title";
    roles[ComicEntryDateRole] = "date";
    roles[ComicEntryAltTextRole] = "altText";
    roles[ComicEntryFavoriteRole] = "isFavorite";
    roles[ComicEntryIdRole] = "entryId";
    roles[ComicEntryMonthRole] = "month";
    roles[ComicEntryImageSourceRole] = "imageSource";
    setRoleNames(roles);
}

ComicEntryListModel::~ComicEntryListModel()
{
}

int ComicEntryListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_comicEntries.count();
}

QVariant ComicEntryListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_comicEntries.count()) {
        return QVariant();
    }

    ComicEntry *entry = m_comicEntries.at(index.row());

    switch (role) {
    case ComicEntryNameRole:
        return QVariant::fromValue(entry->name());
    case ComicEntryDateRole:
        return QVariant::fromValue(entry->date());
    case ComicEntryAltTextRole:
        return QVariant::fromValue(entry->altText());
    case ComicEntryFavoriteRole:
        return QVariant::fromValue(entry->isFavorite());
    case ComicEntryIdRole:
        return QVariant::fromValue(entry->id());
    case ComicEntryMonthRole:
        return QVariant::fromValue(entry->month());
    case ComicEntryImageSourceRole:
        return QVariant::fromValue(entry->imageSource());
    default:
        return QVariant();
    }
}

void ComicEntryListModel::setComicEntries(QList<ComicEntry*> entries)
{
    if (m_comicEntries.count() > 0) {
        beginRemoveRows(QModelIndex(), 0, m_comicEntries.count() - 1);
        qDeleteAll(m_comicEntries.begin(), m_comicEntries.end());
        m_comicEntries.clear();
        endRemoveRows();
    }

    if (entries.count() > 0) {
        beginInsertRows(QModelIndex(), 0, entries.count() - 1);
        m_comicEntries << entries;
        endInsertRows();
    }

    emit countChanged();
}
