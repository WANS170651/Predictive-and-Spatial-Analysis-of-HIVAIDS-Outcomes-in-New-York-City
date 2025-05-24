[![R Version](https://img.shields.io/badge/R-%3E%3D%204.0-276DC3?logo=r&style=flat-square)](https://www.r-project.org/) [![License: MIT](https://img.shields.io/badge/License-MIT-00C13F?style=flat-square)](LICENSE)

# 🏙️ Predictive & Spatial Analysis of NYC HIV/AIDS Outcomes  
> A unified framework combining machine learning and spatial analysis to uncover disparities in HIV care linkage and viral suppression across NYC regions.

---

## 🔍 Project Overview
New York City continues to face challenges in HIV/AIDS prevention and care despite ongoing interventions.  
This project integrates predictive modeling with spatial clustering and dimensionality reduction to:
- Identify demographic & regional drivers of **timely care linkage** and **viral suppression**  
- Map geographic “hotspots” and clusters of high-risk areas  
- Provide data-driven guidance for targeted public health interventions  
  
_Data source:_ DOHMH HIV/AIDS Annual Report (2017–2021) (NYC OPEN DATA)

---

## 🚀 Features
| Phase                      | Techniques & Tools                                      |
| :------------------------- | :------------------------------------------------------ |
| **Data Cleaning & ETL**     | Missing value imputation, encoding, scaling             |
| **Predictive Modeling**     | Logistic Regression, Random Forest                     |
| **Spatial Analysis**        | K-means clustering, Moran’s I                          |
| **Dimensionality Reduction**| Principal Component Analysis (PCA)                     |
| **Visualization**           | Choropleth maps, ROC/AUC plots, Feature importance bar |

---

## 🛠️ Tech Stack
| Language | Libraries & Packages                       |
| :------- | :----------------------------------------- |
| **R**     | tidyverse (dplyr, ggplot2), sf, caret, randomForest |
| **Python**<sup>optional</sup> | geopandas, scikit-learn, matplotlib     |
| **Data**  | `DOHMH_HIV_AIDS_Cleaned.csv` :contentReference[oaicite:1]{index=1} |

---

## How to Use
The analysis can be fully reproduced by running the provided HTML and RMD files. For a complete explanation of the findings, please refer to the accompanying PDF report.
