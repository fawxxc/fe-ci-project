FROM nginx:1.24-alpine
COPY dist/ /usr/share/nginx/html
