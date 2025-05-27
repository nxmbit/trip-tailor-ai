#!/bin/sh
echo "API_BASE_URL=$API_BASE_URL" > /usr/share/nginx/html/assets/.env
echo "GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_FRONTEND_API_KEY" >> /usr/share/nginx/html/assets/.env