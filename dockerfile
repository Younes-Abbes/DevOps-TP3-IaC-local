# Utilise une image de base tres legere (Alpine)
FROM alpine:latest

# Mise a jour et installation du serveur web Nginx
RUN apk update && \
    apk add nginx && \
    rm -rf /var/cache/apk/*

# Creation d'une page HTML simple comme preuve de deploiement
RUN echo "<h1>Application Deployed via Terraform IaC!</h1>" > /var/www/localhost/index.html

# Expose le port par defaut de Nginx
EXPOSE 80

# Commande pour demarrer Nginx en mode non-demonise
CMD ["nginx", "-g", "daemon off;"]
