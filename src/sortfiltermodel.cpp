#include "sortfiltermodel.h"
#include "comicentrylistmodel.h"

SortFilterModel::SortFilterModel(QObject *parent) :
    QSortFilterProxyModel(parent),
    m_filteringFavorites(false)
{
    setFilterCaseSensitivity(Qt::CaseInsensitive);
}

SortFilterModel::~SortFilterModel()
{
}

void SortFilterModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);
    connect(sourceModel, SIGNAL(dataChanged(QModelIndex,QModelIndex)),
            this, SLOT(onDataChanged(QModelIndex,QModelIndex)), Qt::UniqueConnection);
}

void SortFilterModel::setFavoritesFiltered(bool filtering)
{
    m_filteringFavorites = filtering;
}

bool SortFilterModel::favoritesFiltered() const
{
    return m_filteringFavorites;
}

bool SortFilterModel::filterAcceptsRow(int sourceRow,
                                       const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)

    const QModelIndex index = sourceModel()->index(sourceRow, 0);
    const QString name =
            sourceModel()->data(index,
                                ComicEntryListModel::ComicEntryNameRole).toString();
    const QString month =
            sourceModel()->data(index,
                                ComicEntryListModel::ComicEntryMonthRole).toString();
    const QString id =
            sourceModel()->data(index,
                                ComicEntryListModel::ComicEntryIdRole).toString();
    bool isFavorite =
            sourceModel()->data(index,
                                ComicEntryListModel::ComicEntryFavoriteRole).toBool();

    // We search on comic name, date and id
    return (name.contains(filterRegExp()) ||
            month.contains(filterRegExp()) ||
            id.contains(filterRegExp())) && (isFavorite || !m_filteringFavorites);
}

void SortFilterModel::onDataChanged(const QModelIndex &topLeft,
                                    const QModelIndex &bottomRight)
{
    emit dataChanged(mapFromSource(topLeft), mapFromSource(bottomRight));
}
