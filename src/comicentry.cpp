#include "comicentry.h"

static const QString MONTH_DATE_FORMAT("MMM yyyy");
static const QString XKCD_DATE_FORMAT("yyyy-M-d");

ComicEntry::ComicEntry(const QString &name,
                       const QString &date,
                       const QString &id) :
    m_favorite(false),
    m_altText(),
    m_imageSource()
{
    m_name = name;
    m_id = id.mid(1, id.length() - 2).toInt();
    m_date = QDate::fromString(date, XKCD_DATE_FORMAT);
    m_formattedDate = m_date.toString(Qt::DefaultLocaleShortDate);
    m_month = m_date.toString(MONTH_DATE_FORMAT);
}

ComicEntry::ComicEntry(int id,
                       const QString &name,
                       const QDate &date) :
    m_favorite(false),
    m_altText(),
    m_imageSource()
{
    m_name = name;
    m_id = id;
    m_date = date;
    m_formattedDate = date.toString(Qt::DefaultLocaleShortDate);
    m_month = date.toString(MONTH_DATE_FORMAT);
}

const QString ComicEntry::name() const
{
    return m_name;
}

const QString ComicEntry::formattedDate() const
{
    return m_formattedDate;
}

const QString ComicEntry::altText() const
{
    return m_altText;
}

const QString ComicEntry::month() const
{
    return m_month;
}

const QDate ComicEntry::date() const
{
    return m_date;
}

int ComicEntry::id() const
{
    return m_id;
}

bool ComicEntry::isFavorite() const
{
    return m_favorite;
}

const QString ComicEntry::imageSource() const
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

void ComicEntry::setImageSource(const QString &imageSource)
{
    m_imageSource = imageSource;
}
