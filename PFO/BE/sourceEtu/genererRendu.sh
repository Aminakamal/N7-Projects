#!/bin/sh -e

echo "Saisissez votre login ENSEEIHT :"
read login
mkdir $login
cp -p GrandNombre.ml $login
cp -p IntList.ml $login
cp -p PasSiGrandNombre.ml $login
cp -p dune $login
cp -p dune-project $login
cp -p dune-workspace $login
tar -cvf  $login.tar $login
rm -rf $login

