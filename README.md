# Supply Chain Dashboard

This project is an interactive dashboard built using Shiny to explore supply chain data.

The dashboard allows users to filter by product category and transportation mode and visualize:

- Defect rates by SKU
- Shipping cost matrix by route and transportation mode
- Summary metrics such as average cost and inspection pass rate

PS: This is a trimmed down version of the main dashboard, built in Python, which can be found [here](https://019c9b42-3095-b6d6-0bde-f47f0f78a6be.share.connect.posit.cloud/)

## Installation

Clone the repository:

git clone git@github.com:gaurang23/supply-chain-shiny-r.git

Install dependencies:

install.packages("renv")
renv::restore()

## Running the app

shiny::runApp()