# Programación para DevOps

1. ### Propuesta

2. ### Script de Bash

    1. Objetivos: 
    Crea usuarios contenidos en un **archivo** pasado como **parámetro**.
    El archivo tiene:
    - Shell por defecto
    - Directorio home
    - Comentario
    - Si se crea o no el directorio home en caso de no existir (booleano)
    Opciones del script: 
    - Informar el resultado de la creación para cada usuario
    - Crear los usuarios con una contraseña pasada como parámetro de la opción

    2. Forma del script
    >ej1_crea_usuarios.sh [-i] [-c contraseña ] 
    
    Archivo_con_los_usuarios_a_crear
    En caso de faltar opciones en el archivo, se deben usar los defaults del comando useradd o los que se definan como predeterminados. 
    Archivo de usuarios: 
    la información será separada por ":" t tiene una sintaxis como sigue. 
