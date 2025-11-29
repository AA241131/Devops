#!/bin/bash

echo "comienzo"

function extraer_linea {
        linea=$(head -n1 $1)
#       tail -n +2 $1 > restante.txt
}

function testear_linea {
        nombre_de_usuario=$(echo $1 | cut -d":" -f1 | sed "s/^[[:space:]]*//" )
        comentario=$(echo $1 | cut -d":" -f2 | sed "s/^[[:space:]]*//" )
        directorio_home=$(echo $1 | cut -d":" -f3 | sed "s/^[[:space:]]*//" )
        crear_home=$(echo $1 | cut -d":" -f4 | sed "s/^[[:space:]]*//" )
        shell_predeterminada=$(echo $1 | cut -d":" -f5 | sed "s/^[[:space:]]*//" )
        #test de nombre
        if [[ ! $nombre_de_usuario =~ ^[a-zA-Z0-9_.][a-zA-Z0-9_.-]*$ ]]
        then
                echo "Nombre invalido"
                exit 4
        fi
        #test de formato directorio
        directorio_padre=$(dirname "$directorio_home")
        if [[ ! "$directorio_home" =~ ^[[:space:]]*/ ]]
        then
                echo "directorio no absoluto"
                exit 4
        elif [[ ! -d "$directorio_padre" ]]
        then
                echo $directorio_padre
                echo "directorio padre no existe"
                exit 4
        elif [[ -d "$directorio_home" ]]
        then
                echo "directorio ya existe"
                exit 4
        #test de booleana de directorio
        elif [[ ! "$crear_home" =~ ^[[:space:]]*(SI|NO)[[:space:]]*$ ]]
        then
                echo $crear_home
                echo "opcion crear directorio invalida"
                exit 4
        #test de shell
        elif ! grep -qE $shell_predeterminada /etc/shells
        then
                echo "Shell invalido"
                exit 4
        fi
}

function crear_usuario {
        if [[ "$crear_home" =~ ^SI ]]
        then
                useradd $nombre_de_usuario -c $comentario -m -d $directorio_home -s $shell_predeterminada
        else
                useradd $nombre_de_usuario -c $comentario -M -s $shell_predeterminada
        fi
}

extraer_linea $1
testear_linea "$linea"
crear_usuario "$linea"

echo "fin"
