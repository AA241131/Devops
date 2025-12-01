import boto3
import time
import json


#crear el cliente s3
s3 = boto3.client('s3')

# Parámetros
bucket_name = 'AA24131_bucket_obligatorio'
file_path = ['/archivo_archivos_bucket/app.css',
            '/archivo_archivos_bucket/app.js',
            '/archivo_archivos_bucket/config.php',
            '/archivo_archivos_bucket/index.html',
            '/archivo_archivos_bucket/login.css',
            '/archivo_archivos_bucket/login.html',
            '/archivo_archivos_bucket/login.js',
            '/archivo_archivos_bucket/login.php',
            '/archivo_archivos_bucket/init_db.sql'
            ]
             
object_name = []

for i in file_path:
    object_name.append(i.split('/')[-1])


# Crear un bucket de S3
try:
    s3.create_bucket(Bucket=bucket_name)
    print(f"Bucket creado: {bucket_name}")
except ClientError as e:
    if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
        print(f"El bucket {bucket_name} ya existe y es tuyo.")
    else:
        print(f"Error creando bucket: {e}")
        exit(1)

#Subir archivos al bucket
for i in range(len(file_path)-1):
    try:
        s3.upload_file(file_path[i], bucket_name, object_name[i])
        print(f"Archivo {file_path} subido a {bucket_name}/{object_name}")
    except FileNotFoundError:
        print(f"El archivo {file_path} no existe")
    except ClientError as e:
        print(f"Error subiendo archivo: {e}") 
    
# print(i)
# print(object_name)






