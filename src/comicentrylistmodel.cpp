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
    roles[ComicEntryDateRole] = "date";
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

bool ComicEntryListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_comicEntries.count()) {
        return false;
    }

    ComicEntry *entry = m_comicEntries.at(index.row());

    switch (role) {
    case ComicEntryAltTextRole:
        entry->setAltText(value.toString());
        break;
    case ComicEntryFavoriteRole:
        entry->setFavorite(value.toBool());
        break;
    case ComicEntryImageSourceRole:
        entry->setImageSource(value.toString());
        break;
    default:
        return false;
    }

    emit dataChanged(index, index);
    return updateEntry(entry);
}

bool ComicEntryListModel::updateEntry(ComicEntry *entry)
{
    QSqlDatabase::database().transaction();
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE comicentry "
                        "SET favorite=:favorite, altText=:altText, imageSource=:imageSource "
                        "WHERE entryId=:id");

    updateQuery.bindValue(":id", entry->id());
    updateQuery.bindValue(":favorite", entry->isFavorite());
    updateQuery.bindValue(":altText", entry->altText());
    updateQuery.bindValue(":imageSource", entry->imageSource());
    bool result = updateQuery.exec();
    QSqlDatabase::database().commit();

    return result;
}

Qt::ItemFlags ComicEntryListModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index)

    return Qt::ItemIsEditable & Qt::ItemIsEnabled & Qt::ItemIsSelectable;
}

void ComicEntryListModel::setComicEntries(QList<ComicEntry*> entries)
{
    updateComicEntries(entries);

    saveComicEntries();
}

void ComicEntryListModel::updateComicEntries(QList<ComicEntry *> entries)
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

    QList<ComicEntry*> entries;
    while (query.next()) {
        ComicEntry* entry = new ComicEntry(query.value(ID_INDEX).toInt(),
                                           query.value(NAME_INDEX).toString(),
                                           query.value(DATE_INDEX).toDate());
        entry->setFavorite(query.value(FAVORITE_INDEX).toBool());
        entry->setAltText(query.value(ALT_TEXT_INDEX).toString());
        entry->setImageSource(query.value(IMAGE_SOURCE_INDEX).toString());

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

    Q_FOREACH (ComicEntry* entry, m_comicEntries) {
        entryIds << entry->id();
        entryNames << entry->name();
        entryDates << entry->date();
        entryFavorites << entry->isFavorite();
        entryAltTexts << entry->altText();
        entryImageSources << entry->imageSource();
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
