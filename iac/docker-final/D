FROM nginx:alpine

# Remover config default
RUN rm /etc/nginx/conf.d/default.conf

# Copiar config customizada
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar página HTML
COPY html/index.html /usr/share/nginx/html/index.html

# Expor porta 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s CMD wget --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]