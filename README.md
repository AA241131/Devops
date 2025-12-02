# Programación para DevOps

1. ### Script de Bash

    1. Descripción del script: 
        Crea usuarios contenidos en un **archivo** pasado como **parámetro**.
    2. Sintaxis del script
        `ej1_crea_usuarios.sh [-i] [-c contraseña] archivo_de_usuarios.txt`
    
        **-i** Opcional, modo verbose. Despliega información de cada usuario creado. 
        **-c** seguido de texto que se considerará la contraseña. Si no se usa esta opción, el usuario se crea sin contraseña. Se usa el predeterminado de useradd. 
        
    3. Formato de archivo_de_usuarios
        la información será separada por ":" t tiene una sintaxis como sigue. 
        `Nombre de usuario : Comentario : Directorio home : crear dir home si no existe (SI/NO): Shell por defecto`
        los campos Comentario, directorio home, crear dir home y shell por defecto pueden estar vacios. 
    4. Codigo de Errores usado: 
        **0** - éxito
        **1** - archivo inexistente
        **2** - archivo no regular 
        **3** - no hay permisos de lectura sobre el archivo
        **4** - sintaxis incorrecta en el archivo (formato)
        **5** - parámetros incorrectos (ej -c sin contraseña)
        **6** - modificadores inválidos (no son "i" o "c")
        **7** - cantidad de parámetros incorrectos
        **8**- permisos de sudo

---

2. ### Script de Python

    1. **Descripción del script:** 
        Crea un bucket s3, una instancia ec2 y una base de datos rds en aws. Carga estas instancias con una app de recursos humanos que es accesible desde una IP publica
    2. **Requerimientos:**
        - Python 3.10 o más reciente
        `sudo dnf install python3.12`
        - pip
        `dnf install python3.12-pip`
        - boto3
        `pip install boto3`
        - aws cli
        ```sudo dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm```
        - configurar aws acorde
        `aws configure`
        - editar password.txt con la contraseña deseada de la base de datos
        
    3. **Despliegue**
        - Ejecutar el script
        - Navegar a la dirección indicada al final de la ejecución del script. 
        - Tener en cuenta que el despliegue tomará alrededor de 8 minutos. 




