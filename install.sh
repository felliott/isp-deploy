#!/bin/bash

git submodule init
git submodule update

for i in isp, experimenter, jamdb
do
    pushd $i
    docker build -t $i:develop .
    popd
done

cp config/jamdb/jam/settings/local.yml jamdb/jam/settings/
cp config/jam-setup/config/local.yml jam-setup/config/
cp config/experimenter/.env experimenter/
cp config/isp/.env isp/


