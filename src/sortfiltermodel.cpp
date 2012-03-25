/**************************************************************************
 *   XMCR
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

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
