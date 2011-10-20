#ifndef COMICENTRY_H
#define COMICENTRY_H

#include <QObject>
#include <QUrl>
#include <QDate>

class ComicEntry : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name)
    Q_PROPERTY(QString month READ month)
    Q_PROPERTY(QDate date READ date)
    Q_PROPERTY(int id READ id)
    Q_PROPERTY(bool favorite READ isFavorite WRITE setFavorite)
    Q_PROPERTY(QString altText READ altText WRITE setAltText)
    Q_PROPERTY(QUrl imageSource READ imageSource WRITE setImageSource)

public:
    ComicEntry(const QString &name, const QString &date, const QString &id);

    const QString name() const;
    const QDate date() const;
    int id() const;
    bool isFavorite() const;
    const QString altText() const;
    const QString month() const;
    const QUrl imageSource() const;

    void setFavorite(bool favorite);
    void setAltText(const QString &altText);
    void setImageSource(const QUrl &imageSource);

private:
    QString m_name;
    QDate m_date;
    int m_id;
    bool m_favorite;
    QString m_altText;
    QUrl m_imageSource;
};

#endif // COMICENTRY_H
