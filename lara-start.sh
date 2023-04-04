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
composer create-project --prefer-dist laravel/laravel $project_name
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
sail up -d
sail composer require laravel/octane spiral/roadrunner
sail shell

# Publish won't help if it's down
sail artisan sail:publish
chmod +x ./rr

# Get requires and run the watcher
npm install
npm run dev
