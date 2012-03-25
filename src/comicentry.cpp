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
