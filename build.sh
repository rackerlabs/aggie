#!/bin/bash

# Update apt
echo "Running an apt-get update"
apt-get update > /dev/null 2>&1

# Install wget if needed
dpkg -l wget > /dev/null 2>&1 
if [ $? != 0 ]
then
    echo "Installing wget" 
    apt-get install -y wget > /dev/null 2>&1
fi

# Download the erlang solutions package if not already
if [ ! -e "/tmp/erlang-solutions_1.0_all.deb" ]
then
    echo "Downloading erlang-solutijons_1.0_all.deb"
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb -O /tmp/erlang-solutions_1.0_all.deb > /dev/null 2>&1
fi

# Install it if needed
dpkg -l erlang-solutions > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "Installing erlang-solutions_1.0_all.deb"
    dpkg -i /tmp/erlang-solutions_1.0_all.deb > /dev/null 2>&1
    echo "Running an apt-get update"
    apt-get update > /dev/null 2>&1
fi

# Install packages after the erlang-solutions repo config
for PACKAGE in esl-erlang elixir
do
    dpkg -l $PACKAGE > /dev/null 2>&1
    if [ $? != 0 ]
    then
        echo "Installing ${PACKAGE}" 
        apt-get install -y $PACKAGE 2>&1
    fi
done

# Move a copy of the erlang runtime over
if [ ! -e "/opt/aggie/ubuntu_erts" ]
then
    echo "Copying /usr/lib/erlang to /opt/aggie/ubuntu_erts"
    cp -rp /usr/lib/erlang /opt/aggie/ubuntu_erts
fi

# Make sure we are in the proper dir for building
cd /opt/aggie

# Install any needed mix requirements not handled by aggie
for MIXREQ in local.rebar local.hex
do
    echo "running mix ${MIXREQ}"
    mix $MIXREQ --force > /dev/null 2>&1
done

# Install the dependancies defined in aggie
echo "Running mix deps.get.  See /var/log/aggiebuild.txt for more details"
mix deps.get > /var/log/aggiebuild.txt  2>&1

# Build the package
echo "Running mix release in the prod env.  See /var/log/aggiebuild.txt for more details"
MIX_ENV=prod mix release >> /var/log/aggiebuild.txt 2>&1

