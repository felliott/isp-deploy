#!/bin/bash

git submodule init
git submodule update

cp config/jamdb/jam/settings/local.yml jamdb/jam/settings/
cp config/jam-setup/config/local.yml jam-setup/config/
cp config/experimenter/.env experimenter/
cp config/isp/.env isp/

for i in jamdb, jam-setup, experimenter, isp
do
    pushd $i
    docker build -t $i:develop .
    popd
done

