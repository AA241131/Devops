import boto3
import time
import json
from botocore.exceptions import ClientError
import os

#crear el cliente s3, ssm y ec2
s3 = boto3.client('s3')
ec2 = boto3.client('ec2')
ssm = boto3.client('ssm')
rds_client = boto3.client('rds')


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
for i in range(len(file_path)):    
    try:
        s3.upload_file(path_al_script+file_path[i], bucket_name, object_name[i])
        print(f"Archivo {path_al_script+file_path[i]} subido a {bucket_name}/{object_name[i]}")
    except FileNotFoundError:
        print(f"El archivo {file_path[i]} no existe")
    except ClientError as e:
        print(f"Error subiendo archivo: {e}") 
    




#no necesita sudo para user_data
user_data = '''#!/bin/bash
dnf clean all
dnf makecache
dnf -y update
dnf -y install httpd php php-cli php-fpm php-common php-mysqlnd mariadb105 nmap-ncat
systemctl enable --now httpd
systemctl enable --now php-fpm
echo '<FilesMatch \.php$>
  SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/"
</FilesMatch>' | sudo tee /etc/httpd/conf.d/php-fpm.conf
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
systemctl restart httpd php-fpm
aws s3 cp s3://aa24131-bucket-obligatorio/app.css /var/www/html/app.css
aws s3 cp s3://aa24131-bucket-obligatorio/app.js /var/www/html/app.js
aws s3 cp s3://aa24131-bucket-obligatorio/config.php /var/www/html/config.php
aws s3 cp s3://aa24131-bucket-obligatorio/index.html /var/www/html/index.html
aws s3 cp s3://aa24131-bucket-obligatorio/login.css /var/www/html/login.css
aws s3 cp s3://aa24131-bucket-obligatorio/login.html /var/www/html/login.html
aws s3 cp s3://aa24131-bucket-obligatorio/login.js /var/www/html/login.js
aws s3 cp s3://aa24131-bucket-obligatorio/login.php /var/www/html/login.php
aws s3 cp s3://aa24131-bucket-obligatorio/init_db.sql /var/www/init_db.sql
'''

#Crear una instancia EC2 asociada al Instance Profile del rol LabRole
response = ec2.run_instances(
    ImageId='ami-0fa3fe0fa7920f68e',
    MinCount=1,
    MaxCount=1,
    InstanceType='t2.micro',
    IamInstanceProfile={'Name': 'LabInstanceProfile'},
    UserData=user_data
)

instance_id = response['Instances'][0]['InstanceId']

# Agregar tag Name: webserver-devops
ec2.create_tags(
    Resources=[instance_id],
    Tags=[{'Key': 'Name', 'Value': 'webserver-devops'}]
)

print(f"Instancia creada con ID: {instance_id} y tag 'webserver-devops'")




#comprobar el funcionamiento con aws ssm start-session --target instance_id


# Crear instancia RDS MySQL


db_instance_identifier = 'rds-obligatorio'
db_instance_class = 'db.t3.medium'  
engine = 'mysql'
#engine_version = '10.6.14'  
master_username = 'admin'
master_user_password = open("password.txt", 'r').read().strip()  # Asegúrate de que el archivo password.txt contenga la contraseña
allocated_storage = int(os.environ.get('RDS_ALLOCATED_STORAGE', 20))  #20GB o RDS_ALLOCATED_STORAGE
publicly_accessible = True

try:
    response = rds_client.create_db_instance(
        DBInstanceIdentifier=db_instance_identifier,
        DBInstanceClass=db_instance_class,
        Engine=engine,
        #EngineVersion=engine_version,
        MasterUsername=master_username,
        MasterUserPassword=master_user_password,
        AllocatedStorage=allocated_storage
    )
    print(f"Creando instancia de base de datos RDS: {db_instance_identifier}")
except Exception as e:
    print(f"Error al crear la instancia de base de datos: {e}")

#print(json.dumps(response, indent=2, default=str))

#Endpoint = response['DBInstance']['InstanceId']

db_instance_identifier = 'rds-obligatorio' #sacar despues


#agregar waiter para esperar a que la instancia RDS esté disponible
print("Esperando a que la instancia RDS esté disponible...")    
rds_client.get_waiter('db_instance_available').wait(DBInstanceIdentifier=db_instance_identifier)
print(f"Instancia DB {db_instance_identifier} está en estado running.")


# Comprobar a que la instancia EC2 esté en estado running
ec2.get_waiter('instance_status_ok').wait(InstanceIds=[instance_id])
print(f"Instancia EC2 {instance_id} está en estado running.")


#The endpoint might not be shown for instances with the status of creating.
#sacar endpoint de la instancia RDS
response = rds_client.describe_db_instances(DBInstanceIdentifier=db_instance_identifier)
endpoint = [response['DBInstances'][0]['Endpoint']['Address'], response['DBInstances'][0]['Endpoint']['Port']]
print(f"Endpoint de la instancia RDS: {endpoint[0]}:{endpoint[1]}")


# crear SG para permitir el acceso a la instancia RDS desde la instancia EC2
sg_name = 'webserver-a-rds-sg'
ip_ec2 = ec2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': ['webserver-devops']}])['Reservations'][0]['Instances'][0]['PublicIpAddress']
print(f"IP pública de la instancia EC2: {ip_ec2}")
sg_ec2 = ec2.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': ['webserver-devops']}])['Reservations'][0]['Instances'][0]['SecurityGroups'][0]['GroupName']
print(f"SG de la instancia EC2: {sg_ec2}")

try:
    response = ec2.create_security_group(
        GroupName=sg_name,
        Description='Permitir trafico desde la instancia EC2 a la RDS por el puerto 3306'
    )
    sg_id = response['GroupId']

    # Permitir puerto 3306 desde la EC2
    ec2.authorize_security_group_ingress(
        GroupId=sg_id,
        SourceSecurityGroupName=sg_ec2,                  
    )
except ClientError as e:
    if 'InvalidGroup.Duplicate' in str(e):
        sg_id = ec2.describe_security_groups(GroupNames=[sg_name])['SecurityGroups'][0]['GroupId']
        print(f"Security Group ya existe: {sg_id}")
    else:
        raise


# Asociar el SG a la instancia RDS

rds_client.modify_db_instance(DBInstanceIdentifier=db_instance_identifier, VpcSecurityGroupIds=[sg_id])
print(f"SG {sg_id} asociado a la instancia {db_instance_identifier}")


#crear base de datos con mysql -h rds-obligatorio.cddpiv5wo1l7.us-east-1.rds.amazonaws.com -u admin -pDevOps-RDS-Admin < /var/www/init_db.sql
#arreglar el SG, no usar IP sino el SG de la EC2

"""
sudo tee /var/www/.env >/dev/null <<'ENV'
   DB_HOST=endpoint[0]
   DB_NAME='demo_db'
   DB_USER=master_username
   DB_PASS=master_user_password

   APP_USER=<APP_USER>
   APP_PASS=<APP_PASS>
   ENV



"""
