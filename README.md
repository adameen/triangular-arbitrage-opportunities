# Cryptocurrency Triangular Arbitrage Opportunities

This README includes general information about the application and the installation instructions. The application has been created as a part of diploma thesis in 2019.

Cryptocurrency Triangular Arbitrage Opportunities web application computes potential triangular arbitrage profits on Bittrex and Kraken cryptocurrency exchanges in real-time. It also gathers the best opportunities during each hour. A user can then choose a day to view and compare the historical profits of the cryptocurrency exchanges in the chart.

## General information
* Title: Cryptocurrencies Exchange Rates Reporting Tool
* Author: Adam Pečev
* University: Faculty of Information Technology, CTU in Prague

## Used technologies
* Ruby on Rails 5.2.3
* Ruby 2.6.1
* Database (Active Record): sqlite3 gem 1.4.0 (SQLite 3.6.16 or newer)
* Action Cable (WebSockets) for server-client communication
* jQuery (gem: jquery-rails 4.3.3) and jQuery UI lib (gem: jquery-ui-rails 5.0.5)
* Chart.js (gem: chart-js-rails 0.1.6)
* Syntactically awesome style sheets (Sass, gem: sass-rails 5.0)


## Installation
1. Download or fork this repository (https://github.com/adameen/triangular-arbitrage-opportunities)
2. Unzip the downloaded project and navigate to the project directory:  
`cd triangular-arbitrage-opportunities-master`
3. Install Ruby version 2.6.1. The detailed description is here: https://www.ruby-lang.org/en/documentation/installation/
4. Install Ruby on Rails framework version 5.2.3. The detailed description is here: https://gorails.com/setup/
5. Install Bundler. The detailed description is here: https://bundler.io/
6. Install the Gemfile dependencies:  
`bundle install`
7. Install a JavaScript run-time library in case you do not have it installed already. E.g. Node.js may be installed – the detailed description is here: https://nodejs.org/en/download/
8. Run pending Migrations:  
`bin/rails db:migrate RAILS_ENV=development`

## Launch the application
1. Launch the server:  
`bin/rails server`
2. Connect with web browser to: <localhost:3000>

## GUI Snapshots
### Realtime page
![Realtime page](https://drive.google.com/uc?id=1AuE2KnpWHziUlkFLc7LteRoTe7S_lz8B)
---
### Records page with chart
![Records page with chart](https://drive.google.com/uc?id=1UWp-nmpZt8IzxZql7fBbgDCP7WzXI6jk)
---
### Records page with table
![Records page with table](https://drive.google.com/uc?id=1fivPfIYp0trRI7gF2dqDkz3EIjbqvcxX)
