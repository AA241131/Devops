import boto3
import time
import json
from botocore.exceptions import ClientError
import os


#crear el cliente s3
s3 = boto3.client('s3')

# Parámetros
bucket_name = 'aa24131-bucket-obligatorio'
path_al_script = os.path.dirname(os.path.abspath(__file__))
file_path = ['/archivos_bucket/app.css',
            '/archivos_bucket/app.js',
            '/archivos_bucket/config.php',
            '/archivos_bucket/index.html',
            '/archivos_bucket/login.css',
            '/archivos_bucket/login.html',
            '/archivos_bucket/login.js',
            '/archivos_bucket/login.php',
            '/archivos_bucket/init_db.sql'
            ]
             
object_name = []

for i in file_path:
    object_name.append(i.split('/')[-1])

#Crear un bucket de S3
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
        s3.upload_file(path_al_script+file_path[i], bucket_name, object_name[i])
        print(f"Archivo {path_al_script+file_path[i]} subido a {bucket_name}/{object_name[i]}")
    except FileNotFoundError:
        print(f"El archivo {file_path[i]} no existe")
    except ClientError as e:
        print(f"Error subiendo archivo: {e}") 
    
# print(i)
# print(object_name)






