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
        ComicEntryFormattedDateRole,
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
