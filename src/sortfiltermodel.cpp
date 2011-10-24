#include "sortfiltermodel.h"
#include "comicentrylistmodel.h"
#include "comicentry.h"

SortFilterModel::SortFilterModel(QObject *parent) :
    QSortFilterProxyModel(parent),
    m_filteringFavorites(false),
    m_comicEntryModel(0)
{
    setFilterCaseSensitivity(Qt::CaseInsensitive);
}

SortFilterModel::~SortFilterModel()
{
}

void SortFilterModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);
    m_comicEntryModel = qobject_cast<ComicEntryListModel *>(sourceModel);
    connect(m_comicEntryModel, SIGNAL(dataChanged(QModelIndex,QModelIndex)),
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

void SortFilterModel::updateFavorite(int row, bool isFavorite)
{
    const QModelIndex proxyIndex = index(row, 0);
    setData(proxyIndex, isFavorite, ComicEntryListModel::ComicEntryFavoriteRole);
}

void SortFilterModel::updateAltText(int row, const QString &altText)
{
    const QModelIndex proxyIndex = index(row, 0);
    setData(proxyIndex, altText, ComicEntryListModel::ComicEntryAltTextRole);
}

void SortFilterModel::updateImageSource(int row, const QString &imageSource)
{
    const QModelIndex proxyIndex = index(row, 0);
    setData(proxyIndex, imageSource, ComicEntryListModel::ComicEntryImageSourceRole);
}

bool SortFilterModel::filterAcceptsRow(int sourceRow,
                                       const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)

    const QModelIndex index = sourceModel()->index(sourceRow, 0);
    const QString name =
            m_comicEntryModel->data(index,
                                ComicEntryListModel::ComicEntryNameRole).toString();
    const QString month =
            m_comicEntryModel->data(index,
                                ComicEntryListModel::ComicEntryMonthRole).toString();
    const QString id =
            m_comicEntryModel->data(index,
                                ComicEntryListModel::ComicEntryIdRole).toString();
    bool isFavorite =
            m_comicEntryModel->data(index,
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

QVariantMap SortFilterModel::get(int sourceRow) const
{
    const QModelIndex index = m_comicEntryModel->index(sourceRow, 0);
    return m_comicEntryModel->get(index);
}
