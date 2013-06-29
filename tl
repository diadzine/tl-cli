#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Affiche les prochains bus/metros d'apres les données accessibles sur le site
# des transports publics lausannois (http://www.t-l.ch/).
#
# Portage en Python du projet initialement en Ruby de François Deppierraz
# (https://github.com/ctrlaltdel/tl-cli)
#
# Copyleft 2013 Aymeric Bringard
# License GPL v2 (https://www.gnu.org/licenses/gpl-2.0.txt)
#
# 30.06.2013 - Initial release


##### CONFIG

STOPS = {
    '13-loz': ['13|Provence Nord - Verdeil|13', 'Montelly', 'A'],
    '13-provence': ['13|Provence Nord - Verdeil|13', 'Montelly', 'R'],
    'm1-loz': ['70|Renens-Gare - Lausanne-Flon|70', 'Montelly', 'A'],
    'm1-renens': ['70|Renens-Gare - Lausanne-Flon|70', 'Montelly', 'R'],
}

##### END CONFIG

import requests
import urllib
from bs4 import BeautifulSoup
from itertools import imap


def download_horaire(ligne, arret, sens):
    url = "http://www.t-l.ch/index.php"
    params = {
        'option': 'com_tl',
        'task': 'hd',
        'Itemid': 7,
        'arret': arret,
        'ligne': ligne,
        'sens': sens }
    headers = { 'User-Agent': 'Browser' } # Le site filtre les user-agent contenant 'python'.

    req = requests.get(url, params=params, headers=headers)
    page = BeautifulSoup(req.text)

    # On enlève la dernière cellule contenant "* Ces horaires sont théoriques"
    return (horaire.get_text() for horaire in page.select('div.content_box_voyages_step2 td')[:-1])


stop_name_length = max(imap(len,STOPS))

for nom in STOPS.keys():
    (ligne, arret, sens) = STOPS[nom]
    prochains = download_horaire(ligne, arret, sens)
    print nom.ljust(stop_name_length),' ',' | '.join(prochains)