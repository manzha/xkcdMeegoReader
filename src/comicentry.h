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

#ifndef COMICENTRY_H
#define COMICENTRY_H

#include <QDate>

class ComicEntry
{
public:
    ComicEntry(const QString &name, const QString &date, const QString &id);
    ComicEntry(int id, const QString &name, const QDate &date);

    const QString name() const;
    const QDate date() const;
    const QString formattedDate() const;
    int id() const;
    bool isFavorite() const;
    const QString altText() const;
    const QString month() const;
    const QString imageSource() const;

    void setFavorite(bool favorite);
    void setAltText(const QString &altText);
    void setImageSource(const QString &imageSource);

private:
    QString m_name;
    QString m_month;
    QDate m_date;
    QString m_formattedDate;
    int m_id;
    bool m_favorite;
    QString m_altText;
    QString m_imageSource;
};

#endif // COMICENTRY_H
