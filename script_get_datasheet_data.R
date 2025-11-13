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
if(!require(arrow)) install.packages("arrow")
if(!require(dplyr)) install.packages("dplyr")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(RColorBrewer)) install.packages("RColorBrewer")


## 1. TÉLÉCHARGER UN JEU DE DONNÉES __________________________________
# Télécharger les données d'indicateurs hydrologiques associées aux
# fiches de synthèse TRACC : https://doi.org/10.57745/W0KO1G

# Télécharger les métadonnées de stations associées :
# https://doi.org/10.57745/UTKWR5


## 2. CHEMIN D'ACCÈS _________________________________________________ 
# Chemin d'accès de votre dossier de données où vous stockez le
# dossier téléchargé depuis l'entrepôt Recherche Data Gouv
data_dirpath =
    "path/to/dataverse_files"

# Chemin vers le fichier de métadonnées spatiales
Stations_path =
    "path/to/metadata/stations_Explore2.csv"

# Lecture du fichier de métadonnées
Stations = dplyr::tibble(read.csv(Stations_path))


## 3. CALCUL DES DONNÉES ASSOCIÉES AUX FIGURES _______________________
### 3.0. Sélection du cas d'étude de la fiche ________________________
# Niveau de réchauffement
rwl = "RWL-27"

# Secteur hydrographique
sh = "M3"

### 3.1. Figure (b) : Carte du VCN10_Été _____________________________
# Variable
variable = "delta-VCN10_summer"

# Nom du fichier 
file = "delta-VCN10_summer_RWL-all_historical-rcp85_all_all_ADAMONT_all_ref-19910101-20201231_filtered.parquet"

# Création du chemin vers les données 
path = file.path(data_dirpath, file)

# Lecture du fichier parquet
data_all = arrow::read_parquet(path)

# Filtrage
data = dplyr::filter(data_all,
                     RWL==rwl & SH==sh)

# Calcul
data_stat =
    dplyr::summarise(dplyr::group_by(data, code, GCM, RCM),
                     !!variable:=mean(get(variable),
                                      na.rm=TRUE),
                     .groups="drop")
data_stat = 
    dplyr::summarise(dplyr::group_by(data_stat, code, GCM),
                     !!variable:=mean(get(variable),
                                      na.rm=TRUE),
                     .groups="drop")
data_stat = 
    dplyr::summarise(dplyr::group_by(data_stat, code),
                     !!variable:=mean(get(variable),
                                      na.rm=TRUE),
                     .groups="drop")


# Ajout des métadonnées
data_stat = dplyr::left_join(data_stat,
                             dplyr::select(Stations,
                                           code, XL93_m, YL93_m),
                             by="code")

# Graphique sommaire
breaks = c(-50, -37.5, -25, -12.5, 0, 12.5, 25, 37.5, 50)
labels = c("< -50", "-37.5", "-25", "-12.5", "0", "12.5", "25", "37.5", "> 50")
plot =
    ggplot(data_stat,
           aes(x=XL93_m, y =YL93_m, color=get(variable))) +
    coord_fixed() +
    geom_point(size=3) +
    scale_color_stepsn(colors=RColorBrewer::brewer.pal(10, "BrBG"),
                       breaks=breaks,
                       labels=labels,
                       limits=c(-62.5, 62.5),
                       oob=scales::squish,
                       name="Changements relatifs (%)") +
    theme_minimal() +
    labs(title=variable)
plot


### 3.2. Tableau (f) : Changements relatifs projetés _________________
# Variable
variable = "delta-VCN10-5_summer"

# Nom du fichier 
file = "delta-VCN10-5_summer_RWL-all_historical-rcp85_all_all_ADAMONT_all_ref-19910101-20201231_filtered.parquet"

# Création du chemin vers les données 
path = file.path(data_dirpath, file)

# Lecture du fichier parquet
data_all = arrow::read_parquet(path)

# Filtrage
data = dplyr::filter(data_all,
                     RWL==rwl & SH==sh)

# Calcul de la médiane spatiale sur l'ensemble du secteur pour chaque
# chaîne de simulation
data_secteur =
    dplyr::summarise(dplyr::group_by(data,
                                     GCM, RCM, HM),
                     !!variable:=median(get(variable),
                                        na.rm=TRUE),
                     .groups="drop")

# Calcul des statistiques d'ensemble
data_stat =
    dplyr::summarise(data_secteur,
                     !!paste0("min_", variable):=
                         min(get(variable), na.rm=TRUE),
                     !!paste0("med_", variable):=
                         median(get(variable), na.rm=TRUE),
                     !!paste0("max_", variable):=
                         max(get(variable), na.rm=TRUE))
