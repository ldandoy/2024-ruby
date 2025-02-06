# Utiliser l'image officielle Ruby
FROM ruby:3.4

# Installer des dépendances système
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm

# Définir le répertoire de travail
WORKDIR /app  

# Copier les fichiers Gemfile et Gemfile.lock
COPY src/Gemfile src/Gemfile.lock ./

# Installer les dépendances Ruby (gemmes)
RUN bundle install

# Copier tout le code Rails
COPY src/ ./

# Ajout yarn au system
RUN npm install --global yarn

# Exposer le port du serveur Rails
EXPOSE 3000

# Entrée par défaut
CMD ["rails", "server", "-b", "0.0.0.0"]