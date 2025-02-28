#!/bin/bash

set -e

BASE_CONF="/etc/nginx/sites-available/nn"
YA_CONF="/etc/nginx/sites-available/ya"
DH_CONF="/etc/nginx/sites-available/dh"

echo "Копирование базовой конфигурации..."
sudo cp "$BASE_CONF" "$YA_CONF"
sudo cp "$BASE_CONF" "$DH_CONF"

echo "Замена порта «9870» на «8088» в $YA_CONF..."
sudo sed -i 's/9870/8088/g' "$YA_CONF"

echo "Заменить порт «9870» на «19888» в $DH_CONF..."
sudo sed -i 's/9870/19888/g' "$DH_CONF"

echo "Создание символической ссылки в sites-enabled..."
sudo ln -sf "$YA_CONF" /etc/nginx/sites-enabled/ya
sudo ln -sf "$DH_CONF" /etc/nginx/sites-enabled/dh

echo "Перезагрузка Nginx..."
sudo systemctl reload nginx
sudo systemctl status nginx --no-pager

echo "Nginx настроен для YARN (порт 8088) и HistoryServer (порт 19888)."
