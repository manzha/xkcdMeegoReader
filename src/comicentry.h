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
    QDate m_date;
    int m_id;
    bool m_favorite;
    QString m_altText;
    QString m_imageSource;
};

#endif // COMICENTRY_H
