#!/bin/bash

#echo "comienzo"

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
        linea=$(head -n $1 $2 | tail -n 1)
}

function testear_linea {
        nombre_de_usuario=$(echo $1 | cut -d":" -f1 | sed "s/^[[:space:]]*//" )
        comentario=$(echo $1 | cut -d":" -f2 | sed "s/^[[:space:]]*//" )
        directorio_home=$(echo $1 | cut -d":" -f3 | sed "s/^[[:space:]]*//" )
        crear_home=$(echo $1 | cut -d":" -f4 | sed "s/^[[:space:]]*//" )
        shell_predeterminada=$(echo $1 | cut -d":" -f5 | sed "s/^[[:space:]]*//" )

        #comentario
        if [[ "$comentario" =~ ^[[:space:]]*$ ]]
        then
                comentario="<valor por defecto>"
                cmd_comentario=""
        else
                cmd_comentario=$comentario
        fi

        #test de nombre
        if [[ ! $nombre_de_usuario =~ ^[a-zA-Z0-9_.][a-zA-Z0-9_.-]*$ ]]
        then
                echo "Nombre invalido" >&2
                exit 4
        elif grep -q "^$1:" /etc/passwd
        then
                echo "Usuario ya existe" >&2
                exit 4
        else
                cmd_nombre=$nombre_de_usuario
        fi

        #test de formato directorio
        directorio_padre=$(dirname "$directorio_home")
        if [[ "$directorio_home" =~ ^[[:space:]]*$ ]]
        then
                directorio_home="<valor por defecto>"
                cmd_directorio_home=""
        elif [[ ! "$directorio_home" =~ ^[[:space:]]*/ ]]
        then
                echo "directorio no absoluto" >&2
                exit 4
        elif [[ ! -d "$directorio_padre" ]]
        then
                echo "directorio padre no existe" >&2
                exit 4
        elif [[ -d "$directorio_home" ]]
        then
                echo "directorio ya existe" >&2
                exit 4
        else
                cmd_directorio_home="-d $directorio_home"
        fi

        #test de booleana de directorio
        if [[ "$crear_home" =~ ^[[:space:]]*$ ]]
        then
                crear_home="<valor por defeto>"
                cmd_crear_home=""
        elif [[ ! "$crear_home" =~ ^[[:space:]]*(SI|NO)[[:space:]]*$ ]]
        then
                echo "opcion crear directorio invalida" >&2
                exit 4
        elif [[ "$crear_home" =~ ^[[:space:]]*SI[[:space:]]*$ ]]
        then
                cmd_crear_home="-m"
        else
                cmd_crear_home="-M"
        fi

        #test de shell
        if [[ "$shell_predeterminada" =~ ^[[:space:]]*$ ]]
        then
                shell_predeterminada="<valor por defecto>"
                cmd_shell=""
        elif ! grep -qE $shell_predeterminada /etc/shells
        then
                echo "Shell invalido" >&2
                exit 4
        else
                cmd_shell="-s $shell_predeterminada"
        fi
}

function crear_usuario {
if $flag_contrasena
then
        contrasena_encriptada=$(openssl passwd -6 "$contrasena")
        cmd_contrasena="-p $contrasena_encriptada"
else
        cmd_contrasena=""
fi

useradd "$cmd_nombre" -c "$cmd_comentario" $cmd_crear_home $cmd_directorio_home $cmd_shell $cmd_contrasena

if [ "$flag_verbose" ]
then
        echo "Usuario ""$nombre_de_usuario"" creado con exito con datos indicados:"
        echo -e "\tComentario: ""$comentario"
        echo -e "\tDir home: ""$directorio_home"
        echo -e "\tAsegurando la existencia de directorio home: ""$crear_home"
        echo -e "\tShell por defecto: ""$shell_predeterminada"
fi
}

#comprobacion de sudo usando useradd --help
if ! sudo -n useradd --help >/dev/null 2>&1
then
        echo "Faltan permisos de sudo" >&2
        exit 8
fi

#logica principal
iteraciones=$(wc -l "$archivo_absoluto" | cut -d" " -f1)

for i in $( seq 1 "$iteraciones")
do
        extraer_linea $i "$archivo_absoluto"
        testear_linea "$linea"
        crear_usuario "$linea"
done

#extraer_linea $1
#testear_linea "$linea"
#crear_usuario "$linea"

#echo "fin"
