/**************************************************************************
 *    XMCR
 *    Copyright (C) 2011 Simon Pena <spena@igalia.com>
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

#include "comicentryfetcher.h"
#include "comicentrylistmodel.h"
#include "comicentry.h"

#include <QWebView>
#include <QWebPage>
#include <QWebFrame>
#include <QWebElement>
#include <QUrl>
#include <QLocale>

#include <QDebug>

ComicEntryFetcher::ComicEntryFetcher(ComicEntryListModel *model) :
    m_webView(new QWebView),
    m_comicEntryListModel(model)
{
    connect(m_webView, SIGNAL(loadFinished(bool)),
            this, SLOT(onLoadFinished(bool)), Qt::UniqueConnection);
}

ComicEntryFetcher::~ComicEntryFetcher()
{
    delete m_webView;
}

void ComicEntryFetcher::fetchEntries()
{
    QUrl entriesUrl("http://xkcd.com/archive/");

    m_webView->load(entriesUrl);
}

void ComicEntryFetcher::onLoadFinished(bool ok)
{
    if (ok) {
        QList<ComicEntry> entries;
        QWebElement document = m_webView->page()->mainFrame()->documentElement();
        QWebElementCollection comicLinks = document.findAll("div#middleContent.dialog div.bd div.c div.s a");

        if (comicLinks.count() > 0) {
            Q_FOREACH(QWebElement comicLink, comicLinks) {
                ComicEntry entry(comicLink.toPlainText(),
                                 comicLink.attribute("title"),
                                 comicLink.attribute("href"));
                entries << entry;
            }
        }

        m_comicEntryListModel->setComicEntries(entries);

        emit entriesFetched(entries.count());
    } else {
        qCritical() << Q_FUNC_INFO << "Loading error";
        emit entriesFetched(0);
    }
}
