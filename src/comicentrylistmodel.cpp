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

#include "comicentrylistmodel.h"
#include "comicentry.h"
#include <QApplication>
#include <QDir>
#include <QDesktopServices>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>

static const int ID_INDEX = 0;
static const int NAME_INDEX = 1;
static const int DATE_INDEX = 2;
static const int FAVORITE_INDEX = 3;
static const int ALT_TEXT_INDEX = 4;
static const int IMAGE_SOURCE_INDEX = 5;

static const QString DB_NAME = "comics.db";

ComicEntryListModel::ComicEntryListModel(QObject *parent) :
    QAbstractListModel(parent),
    m_comicEntries(),
    m_dbFullPath(QDesktopServices::storageLocation(QDesktopServices::DataLocation))
{
    QHash<int, QByteArray> roles;
    roles[ComicEntryNameRole] = "title";
    roles[ComicEntryFormattedDateRole] = "formattedDate";
    roles[ComicEntryAltTextRole] = "altText";
    roles[ComicEntryFavoriteRole] = "isFavorite";
    roles[ComicEntryIdRole] = "entryId";
    roles[ComicEntryMonthRole] = "month";
    roles[ComicEntryImageSourceRole] = "imageSource";
    setRoleNames(roles);

    createDatabase();
    loadComicEntries();
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
    if (!index.isValid() || index.row() >= m_comicEntries.count()) {
        return QVariant();
    }

    const ComicEntry &entry = m_comicEntries.at(index.row());

    switch (role) {
    case ComicEntryNameRole:
        return QVariant::fromValue(entry.name());
    case ComicEntryFormattedDateRole:
        return QVariant::fromValue(entry.formattedDate());
    case ComicEntryAltTextRole:
        return QVariant::fromValue(entry.altText());
    case ComicEntryFavoriteRole:
        return QVariant::fromValue(entry.isFavorite());
    case ComicEntryIdRole:
        return QVariant::fromValue(entry.id());
    case ComicEntryMonthRole:
        return QVariant::fromValue(entry.month());
    case ComicEntryImageSourceRole:
        return QVariant::fromValue(entry.imageSource());
    default:
        return QVariant();
    }
}

bool ComicEntryListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_comicEntries.count()) {
        return false;
    }

    ComicEntry &entry = m_comicEntries[index.row()];

    switch (role) {
    case ComicEntryAltTextRole:
        entry.setAltText(value.toString());
        break;
    case ComicEntryFavoriteRole:
        entry.setFavorite(value.toBool());
        break;
    case ComicEntryImageSourceRole:
        entry.setImageSource(value.toString());
        break;
    default:
        return false;
    }

    emit dataChanged(index, index);
    return updateEntry(entry);
}

bool ComicEntryListModel::updateEntry(const ComicEntry &entry)
{
    QSqlDatabase::database().transaction();
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE comicentry "
                        "SET favorite=:favorite, altText=:altText, imageSource=:imageSource "
                        "WHERE entryId=:id");

    updateQuery.bindValue(":id", entry.id());
    updateQuery.bindValue(":favorite", entry.isFavorite());
    updateQuery.bindValue(":altText", entry.altText());
    updateQuery.bindValue(":imageSource", entry.imageSource());
    bool result = updateQuery.exec();
    QSqlDatabase::database().commit();

    return result;
}

Qt::ItemFlags ComicEntryListModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index)

    return Qt::ItemIsEditable & Qt::ItemIsEnabled & Qt::ItemIsSelectable;
}

void ComicEntryListModel::setComicEntries(QList<ComicEntry> entries)
{
    updateComicEntries(entries);

    saveComicEntries();
}

void ComicEntryListModel::updateComicEntries(QList<ComicEntry> entries)
{
    int newEntries = entries.count() - m_comicEntries.count();
    if (newEntries > 0) {
        beginInsertRows(QModelIndex(), 0, newEntries - 1);
        for (int i = newEntries - 1; i >= 0; i --) {
            m_comicEntries.prepend(entries[i]);
        }
        endInsertRows();
    }

    emit countChanged();
}

void ComicEntryListModel::createDatabase()
{
    QDir dir;
    if (!dir.exists(m_dbFullPath)) {
        dir.mkpath(m_dbFullPath);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(m_dbFullPath + QDir::separator() + DB_NAME);
    if (db.open()) {
        // Create table
        QSqlQuery createTableQuery("CREATE TABLE IF NOT EXISTS comicentry"
                                   "(entryId INTEGER PRIMARY KEY ASC, "
                                   "title TEXT, "
                                   "date DATE, "
                                   "favorite BOOLEAN, "
                                   "altText TEXT, "
                                   "imageSource TEXT)");
        createTableQuery.exec();
    }
}

void ComicEntryListModel::loadComicEntries()
{
    QSqlQuery query("SELECT entryId, title, date, favorite, altText, imageSource "
                    "FROM comicentry "
                    "ORDER BY entryId DESC");
    query.exec();

    QList<ComicEntry> entries;
    while (query.next()) {
        ComicEntry entry(query.value(ID_INDEX).toInt(),
                         query.value(NAME_INDEX).toString(),
                         query.value(DATE_INDEX).toDate());
        entry.setFavorite(query.value(FAVORITE_INDEX).toBool());
        entry.setAltText(query.value(ALT_TEXT_INDEX).toString());
        entry.setImageSource(query.value(IMAGE_SOURCE_INDEX).toString());

        entries << entry;
    }

    updateComicEntries(entries);
}

void ComicEntryListModel::saveComicEntries()
{
    QSqlDatabase::database().transaction();
    QSqlQuery saveQuery;
    saveQuery.prepare("INSERT INTO comicentry (entryId, title, date, favorite, altText, imageSource) "
                  "VALUES (?, ?, ?, ?, ?, ?)");

    QVariantList entryIds;
    QVariantList entryNames;
    QVariantList entryDates;
    QVariantList entryFavorites;
    QVariantList entryAltTexts;
    QVariantList entryImageSources;

    Q_FOREACH (const ComicEntry &entry, m_comicEntries) {
        entryIds << entry.id();
        entryNames << entry.name();
        entryDates << entry.date();
        entryFavorites << entry.isFavorite();
        entryAltTexts << entry.altText();
        entryImageSources << entry.imageSource();
    }

    saveQuery.addBindValue(entryIds);
    saveQuery.addBindValue(entryNames);
    saveQuery.addBindValue(entryDates);
    saveQuery.addBindValue(entryFavorites);
    saveQuery.addBindValue(entryAltTexts);
    saveQuery.addBindValue(entryImageSources);
    saveQuery.execBatch();
    QSqlDatabase::database().commit();
}

QVariantMap ComicEntryListModel::get(const QModelIndex &index) const
{
    QVariantMap mappedEntry;

    if (!index.isValid() || index.row() >= m_comicEntries.count()) {
        return mappedEntry;
    }

    const ComicEntry &comicEntry = m_comicEntries.at(index.row());

    mappedEntry.insert("month", comicEntry.month());
    return mappedEntry;
}
