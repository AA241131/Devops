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
        `ej1_crea_usuarios.sh [-i] [-c contraseña ] `
    
        Archivo_con_los_usuarios_a_crear
        En caso de faltar opciones en el archivo, se deben usar los defaults del comando useradd o los que se definan como predeterminados. 
        Archivo de usuarios: 
        la información será separada por ":" t tiene una sintaxis como sigue. 
        `Nombre de usuario: Comentario: Directorio home: crear dir home si no existe (SI/NO): Shell por defecto`
    3. Opciones
        -i despliega información para cada usuario a crear. Debe desplegar la creación o intento. Al final se despliega una línea en blanco y el total de usuarios creados con éxito. 
        -c seguido de texto que se considerará la contraseña. Si no se usa esta opción, el usuario se crea sin contraseña. Se usa el predeterminado de useradd. 
        Errores: 
        0 - éxito
        1 - archivo inexistente
        2 - archivo no regular 
        3 - no hay permisos de lectura sobre el archivo
        4 - sintaxis incorrecta en el archivo (formato)
        5 - parámetros incorrectos (ej -c sin contraseña)
        6 - modificadores inválidos (no son "i" o "c")
        7 - cantidad de parámetros incorrectos
    4. Script
        


