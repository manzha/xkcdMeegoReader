#ifndef SORTFILTERMODEL_H
#define SORTFILTERMODEL_H

#include <QSortFilterProxyModel>

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

signals:
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private Q_SLOTS:
    void onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight);

private:
    bool m_filteringFavorites;
};

#endif // SORTFILTERMODEL_H
