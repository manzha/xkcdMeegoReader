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

#ifndef SORTFILTERMODEL_H
#define SORTFILTERMODEL_H

#include <QSortFilterProxyModel>

class ComicEntry;
class ComicEntryListModel;

class SortFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    SortFilterModel(QObject *parent = 0);
    ~SortFilterModel();

    void setSourceModel(QAbstractItemModel *sourceModel);

public Q_SLOTS:
    void setFavoritesFiltered(bool filtering);

    bool favoritesFiltered() const;

    void updateFavorite(int row, bool isFavorite);

    void updateAltText(int row, const QString &altText);

    void updateImageSource(int row, const QString &altText);

    QVariantMap get(int sourceRow) const;

signals:
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private Q_SLOTS:
    void onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight);

private:
    bool m_filteringFavorites;
    ComicEntryListModel *m_comicEntryModel;
};

#endif // SORTFILTERMODEL_H
