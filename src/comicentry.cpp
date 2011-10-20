#include "comicentry.h"

ComicEntry::ComicEntry(const QString &name,
                       const QString &date,
                       const QString &id) :
    m_favorite(false),
    m_altText(),
    m_imageSource()
{
    m_name = name;
    m_id = id.mid(1, id.length() - 2).toInt();
    m_date = QDate::fromString(date, "yyyy-M-d");
}

const QString ComicEntry::name() const
{
    return m_name;
}

const QDate ComicEntry::date() const
{
    return m_date;
}

const QString ComicEntry::altText() const
{
    return m_altText;
}

const QString ComicEntry::month() const
{
    return m_date.toString("MMMM yyyy");
}

int ComicEntry::id() const
{
    return m_id;
}

bool ComicEntry::isFavorite() const
{
    return m_favorite;
}

const QUrl ComicEntry::imageSource() const
{
    return m_imageSource;
}

void ComicEntry::setFavorite(bool favorite)
{
    m_favorite = favorite;
}

void ComicEntry::setAltText(const QString &altText)
{
    m_altText = altText;
}

void ComicEntry::setImageSource(const QUrl &imageSource)
{
    m_imageSource = imageSource;
}
