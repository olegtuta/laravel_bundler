#!/bin/bash

# Say 'hello' to user
echo "Welcome to Laravel project setup script!"

# Get wrk for testing benchmark
sudo apt install wrk

# Check if alias 'sail' already exists ~/.bashrc
if ! grep -q "alias sail" ~/.bashrc; then
  echo "alias sail='bash vendor/bin/sail'" >> ~/.bashrc
fi

# Reload configuration
source ~/.bashrc

# Ask user for project name
read -p "Enter project name: " project_name

# Ask user if they want to add authentication
while true
do
  read -p "Do you want to add authentication? [y/n]: " add_auth

  case $add_auth in
    [Yy]* ) auth_option="--auth"; break;;
    [Nn]* ) auth_option=""; break;;
    * ) echo "Please enter Y for Yes or N for No.";;
  esac
done

# Create Laravel project with selected options
composer create-project laravel/laravel $project_name
cd $project_name
composer require laravel/ui
php artisan ui vue $auth_option

# Add sail to project
composer require laravel/sail --dev
php artisan sail:install

# Add  octane to project
composer require laravel/octane
php artisan octane:install

# Get up the docker
vendor/bin/sail up -d
vendor/bin/sail composer require laravel/octane spiral/roadrunner

# Publish won't help if it's down
vendor/bin/sail artisan sail:publish
php artisan sail:publish

# Change supervisord.conf for running roadrunner instead of artisan serve
versions=("7.4" "8.0" "8.1" "8.2")
for v in "${versions[@]}"
do
  config_file="docker/$v/supervisord.conf"
  new_command="/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=roadrunner --host=0.0.0.0 --rpc-port=6001 --port=80"
  sed -i "s|^command=.*|command=$new_command|g" $config_file
done

# Rebuild image stopping and getting up then
vendor/bin/sail down
vendor/bin/sail build --no-cache

# Get requires and run the watcher
npm install
vendor/bin/sail up & chmod +x ./rr
