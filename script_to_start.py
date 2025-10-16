# Copyright 2025 Louis Héraut (louis.heraut@inrae.fr)*1,
#                Éric Sauquet (eric.sauquet@inrae.fr)*1
#
# *1   INRAE, UR RiverLy, Villeurbanne, France
#
# This file is part of Explore2_peche_aux_outils_RDG.
#
# Explore2_peche_aux_outils_RDG is free software: you can redistribute
# it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, either version
# 3 of the License, or (at your option) any later version.
#
# Explore2_peche_aux_outils_RDG is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Explore2_peche_aux_outils_RDG.
# If not, see <https://www.gnu.org/licenses/>.


## 0. REQUIREMENT ____________________________________________________
# Installation des dépendances si nécessaire
# (à exécuter manuellement dans un terminal si besoin)
# pip install pyarrow pandas
import glob
import os
import numpy as np
import re
import pandas as pd
import pyarrow.parquet as pq


## 1. TÉLÉCHARGER UN JEU DE DONNÉES __________________________________
# Par exemple les séries annuelles d'indicateur hydrologique pour le
# modèle hydrologique J2000 sous RCP 8.5
# https://doi.org/10.57745/RTHKI2


## 2. CHEMIN D'ACCÈS _________________________________________________
# Chemin d'accès de votre dossier de données où vous stockez le
# dossier téléchargé depuis l'entrepôt Recherche Data Gouv
data_dirpath = "path/to/dataverse_files"

# Nom du dossier de données dézipé
indicators_dir = "series_annuelles"

# Liste de l'ensemble des chemins d'accès aux fichiers parquet
Paths = glob.glob(os.path.join(data_dirpath,
                               indicators_dir,
                               "**", "*.parquet"),
                  recursive=True)

# Listes des noms de fichier
Files = [os.path.basename(p) for p in Paths]


## 3. FILTRAGE _______________________________________________________
### 3.1. Matche par découpe des noms de fichiers _____________________
# L'objectif est de retirer les informations d'intérêt des noms de
# fichier en les découpant selon le caractères de séparation "_"

# Séparation des informations
Files_info = [os.path.splitext(f)[0].split("_") for f in Files]

# Récupération des informations
Indicators = np.array([info[0] for info in Files_info])
Samplings = np.array([info[1] for info in Files_info])
EXP = np.array([info[2] for info in Files_info])
GCM = np.array([info[3] for info in Files_info])
RCM = np.array([info[4] for info in Files_info])
BC = np.array([info[5] for info in Files_info])
HM = np.array([info[6] for info in Files_info])

# Sélection de la ou les chaînes de simulation voulues
indicator = "VCN10"
sampling = "summer"
exp = "historical-rcp85"
gcm = "HadGEM2-ES"
rcm = ["ALADIN63", "CCLM4-8-17"]
bc = "ADAMONT"
hm = "SMASH"

# Récupération des chemins des données avec NumPy
paths_selection = np.array(Paths)[
    (np.isin(Indicators, indicator) &
     np.isin(Samplings, sampling) &
     np.isin(EXP, exp) &
     np.isin(GCM, gcm) &
     np.isin(RCM, rcm) &
     np.isin(BC, bc) &
     np.isin(HM, hm))
]

### 3.2. Expressions régulières ______________________________________
# Les expressions régulières (regex) sont des motifs textuels servant
# à rechercher, valider ou manipuler des chaînes de caractères selon
# des règles précises. Les mots-clés utilisés peuvent être tonqué
# tant que l'on s'assure de notre séléction finale.

# Ici le "^" est utilisé pour indiquer le début du nom du fichier et
# pour éviter de sélection "tVCN10_summer" qui serait aussi
# sélectionné avec "VCN10_summer". Le ".*" fait office de jocker et
# permet de sélectionner toutes les options. Voilà deux des nombreux
# exemples de règles utilisés dans les expressions régulières.
variable = "^VCN10_summer"
exp = "rcp85"
gcm = ".*"
rcm = ".*"
bc = "ADAMONT"
hm = "SMASH"

# Récupération des chemins des données sans NumPy
paths_all_rcp85 = [
    path for i, path in enumerate(Paths)
    if re.search(variable, Files[i])
    and re.search(exp, Files[i])
    and re.search(gcm, Files[i])
    and re.search(rcm, Files[i])
    and re.search(bc, Files[i])
    and re.search(hm, Files[i])
]


## 4. LECTURE ________________________________________________________
### 4.1. Lecture d'un fichier unique _________________________________
# Sélection d'une chaîne
path = paths_selection[1]
data_selection = pq.read_table(path).to_pandas()

### 4.2. Lecture multiple ____________________________________________
data_all_rcp85_list = [pq.read_table(p).to_pandas()
                       for p in paths_all_rcp85]
data_all_rcp85 = pd.concat(data_all_rcp85_list)
