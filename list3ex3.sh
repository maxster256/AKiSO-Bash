#!/bin/bash

# REST API exercises
wget http://thecatapi.com/api/images/get?format=src -O cat.jpeg
img2txt cat.jpeg

curl -s http://api.icndb.com/jokes/random | jq .value.joke