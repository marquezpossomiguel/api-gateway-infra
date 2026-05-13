FROM nginx:1.27-alpine

COPY nginx/nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY nginx/entrypoint.sh /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
