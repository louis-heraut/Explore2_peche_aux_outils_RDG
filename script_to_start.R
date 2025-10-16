# Copyright 2025 Louis Héraut (louis.heraut@inrae.fr)*1,
#                Éric Sauquet (eric.sauquet@inrae.fr)*1
#
# *1   INRAE, UR RiverLy, Villeurbanne, France
#
# This file is part of Explore2 R later toolbox.
#
# Explore2 R later toolbox is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Explore2 R later toolbox is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Explore2 R later toolbox.
# If not, see <https://www.gnu.org/licenses/>.


## 1. TÉLÉCHARGER UN JEU DE DONNÉES __________________________________
# Par exemple les séries annuelles d'indicateur hydrologique pour le
# modèle hydrologique J2000 sous RCP 8.5
# https://doi.org/10.57745/RTHKI2


## 2. CHEMIN D'ACCÈS _________________________________________________ 
# Chemin d'accès de votre dossier de données où vous stockez le
# dossier téléchargé depuis l'entrepôt Recherche Data Gouv
data_dirpath = "/home/lheraut/Téléchargements/dataverse_files"
# "path/to/data/directory"

# Nom du dossier de données dézipé
indicators_dir =
    "series_annuelles"

# Liste de l'ensemble des chemins d'accès aux fichiers parquet
Paths = list.files(file.path(data_dirpath, indicators_dir),
                   pattern=".parquet", full.names=TRUE,
                   recursive=TRUE)

# Listes des noms de fichier
Files = basename(Paths)


## 3. FILTRAGE _______________________________________________________
### 3.1. Matche par découpe des noms de fichiers _____________________
# L'objectif est de retirer les informations d'intérêt des noms de
# fichier en les découpant selon le caractères de séparation "_" 

Files_info = strsplit(Files, "_")
Indicators = sapply(Files_info, "[", 1)
Samplings = sapply(Files_info, "[", 2)
EXP = sapply(Files_info, "[", 3)
GCM = sapply(Files_info, "[", 4)
RCM = sapply(Files_info, "[", 5)
BC = sapply(Files_info, "[", 6)
HM = sapply(Files_info, "[", 7)

indicator = "VCN10"
sampling = "yr"
exp = "rcp85"
gcm = "HadGEM2"
rcm = "CCLM4"
bc = "ADAMONT"
hm = "J2000"

path = Paths[Indicators == indicator &
             Samplings == sampling &
             EXP == exp &
             GCM == gcm &
             RCM == rcm &
             BC == bc &
             HM == hm]




### 3.2. Expressions régulières ______________________________________
# Les expressions régulières (regex)sont des motifs textuels servant à
# rechercher, valider ou manipuler des chaînes de caractères selon des
# règles précises. Les mots-clés utilisés peuvent être tonqué tant que
# l'on s'assure de notre séléction finale.
#
# Ici le "^" est utilisé pour indiquer le début du nom du fichier et
# pour éviter de sélection "tVCN10_summer" qui serait aussi
# sélectionné avec "VCN10_summer". Voilà un des nombreux exemples de
# règles utilisés dans les expressions régulières. 

variable = "^VCN10_summer" 
exp = "rcp85"
gcm = "HadGEM2"
rcm = "CCLM4"
bc = "ADAMONT"
hm = "J2000"

path = Paths[grepl(variable, Files) &
             grepl(exp, Files) &
             grepl(gcm, Files) &
             grepl(rcm, Files) &
             grepl(bc, Files) &
             grepl(hm, Files)]

# Cette démarche peut paraître compliquées au premier abord mais
# permet une plus grande flexibilité et rapidité d'utilisation.
## /!\ Toujours vérifier la sélection faite ##


## 4. LECTURE ________________________________________________________
