#!/bin/bash

export GREYMATTER_API_HOST=localhost:10080
export GREYMATTER_API_INSECURE=true
export GREYMATTER_API_KEY=xxx
export GREYMATTER_API_PREFIX=
export GREYMATTER_API_SSL=false


cd public

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd private

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd data/data

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd jwt

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd ..

cd sense/catalog

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd dashboard

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd objectives

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd prometheus

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

cd ..
cd ..
cd website

for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done

