# fcompute frontend server

[![Build Status](https://travis-ci.org/sharma-abhishek-it/fcompute_frontend_server.svg?branch=master)](https://travis-ci.org/sharma-abhishek-it/fcompute_frontend_server)
[![Code Climate](https://codeclimate.com/github/sharma-abhishek-it/fcompute_frontend_server/badges/gpa.svg)](https://codeclimate.com/github/sharma-abhishek-it/fcompute_frontend_server)
[![Coverage Status](https://coveralls.io/repos/sharma-abhishek-it/fcompute_frontend_server/badge.svg?branch=master)](https://coveralls.io/r/sharma-abhishek-it/fcompute_frontend_server?branch=master)


This repository contains code for frontend handling of fcompute. It is based out of ROR.

-----------------
Setup steps:

1. Install and run [Docker](https://docs.docker.com/) (boot2docker on osx)
2. Install [fig](http://www.fig.sh/)
3. In this dir run `fig build web`
4. To run test cases `fig run web bundle exec rspec`

Main logic of code is as follows:
- A scheduler looks for files in directory and uploads sectors and products to postgresql and redis respectively
- Scheduler makes use of a helper module to fill up blank data and also to read from files
- TODO: Finally few route expos requests that generate HTML for data visualization. Internally they make request to the main fCompute server for report generation data
