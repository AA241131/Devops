#!/bin/bash

echo "comienzo"

#sanitizado de parametros
#inicio variables
flag_verbose=false
flag_contrasena=false

while getopts "ic:" modificador
do
        case $modificador in
                i)      flag_verbose=true
                ;;
                c)      flag_contrasena=true
                        contrasena=$OPTARG
                        #sanitizado de contrasena
                        if  [ -z "$contrasena" ]
                        then
                                echo "contrasena vacia" >&2
                                exit 5
                        elif [[ "$contrasena" == -* ]]
                        then
                                echo "opcion luego de contrasena" >&2
                                exit 5
                        fi
                ;;
                *)      echo "modificador "-$OPTARG" inexistente, solo se aceptan -i y -c" >&2
                        exit 6
                ;;
        esac
done

if [ $# -ne $OPTIND ]
then
        echo "Cantidad de parametros incorrecta, solo se reciben los modificadores -i, y -c seguido de una contrasena, y un directorio valido" >&2
        exit 7
else
        shift $((OPTIND-1))
fi


#sanitizar archivo, que exista, que sea regular, y que tenga permisos de lectura
archivo_absoluto=$(pwd)"/$1"
if  [ ! -e "$archivo_absoluto" ]
then
        echo "archivo no existe" >&2
        exit 1
elif [ ! -f "$archivo_absoluto" ]
then
        echo "archivo no regular" >&2
        exit 2
elif [ ! -r "$archivo_absoluto" ]
then
        echo "no hay permiso de lectura" >&2
        exit 3
fi

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
