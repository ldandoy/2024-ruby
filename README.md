
*Objectif : Maîtriser les bases de Ruby, le langage sous-jacent de Ruby on Rails.*

## Qu'est-ce que Ruby On Rails ?

Ruby on rails est un langage de programmation interprété, tout comme le PHP, le python ou encore le JavaScript. Il est plus proche du PHP, car comme celui-ci il sera installé sur un serveur web (apache, nginx, tomcat...) et lorsque serveur recevra un requête HTTP et qu'il verra que c'est un fichier Ruby on rails, alors il utilisera l'interpréteur Ruby pour exécuté le fichier correspondant.

## L'histoire de Ruby On Rails

c'est un framework de développement web open-source, écrit en langage Ruby, qui a révolutionné la manière de créer des applications web :

1. **Création (2003-2004)**  
    Rails a été développé par **David Heinemeier Hansson** (DHH) pendant qu'il travaillait sur Basecamp, une application de gestion de projets. DHH souhaitait simplifier et accélérer le développement web. Rails a été publié pour la première fois en **juillet 2004** en tant que projet open-source.
    
2. **Philosophie et impact**  
    Rails repose sur deux principes majeurs :
    
    - **Convention over Configuration (Convention plutôt que configuration)** : Les développeurs suivent des conventions préétablies pour éviter d'écrire trop de code de configuration.
    - **Don't Repeat Yourself (DRY)** : Encourager la réutilisation de code pour éviter les duplications.
    
    Ces principes, combinés à des outils comme ActiveRecord pour gérer les bases de données, ont permis de réduire considérablement le temps de développement. Rails a introduit une structure MVC (Modèle-Vue-Contrôleur) intuitive, influençant de nombreux autres frameworks.
    
3. **Adoption et popularité (2005-2010)**  
    Rails a rapidement gagné en popularité grâce à des applications emblématiques comme **Twitter**, **GitHub**, **Shopify**, et **Airbnb**, qui l'ont utilisé dans leurs débuts. Son slogan, **"Build a blog in 15 minutes"**, montrait à quel point il rendait le développement accessible.
    
4. **Évolutions et critiques**  
    Rails a continué à évoluer avec des versions majeures (Rails 2, 3, 4, etc.), ajoutant des fonctionnalités comme **RESTful routes**, **ActiveJob**, et une meilleure gestion des performances. Cependant, il a aussi été critiqué pour sa lenteur dans certaines situations, ce qui a poussé certains projets à migrer vers des solutions comme Node.js.
    
5. **Rails aujourd'hui**  
    En 2023, Rails en est à sa version 7, avec des améliorations significatives en termes de performance, d'intégration avec JavaScript (via **Hotwire**), et de compatibilité avec des architectures modernes. Malgré une concurrence accrue, il reste un choix populaire pour les startups et les projets où la rapidité de développement est primordiale.
    

Rails a laissé une empreinte durable dans le monde du développement web, offrant un équilibre entre simplicité et puissance pour des développeurs de tous niveaux.

## Mise en place de l'environnement développement

Tout comme Javascript à besoin de Nodejs pour être exécuté, un programme Ruby On Rails aura besoin du Ruby pour être exécuté. Nous allons donc commencer par créer un environnement docker avec un container contenant l'interpréteur Ruby. Puis grâce à celui-ci nous pourront généré un projet Ruby On Rails. Une fois le projet créé, nous pourrons alors créer un container contenant les dépendances et autres librairies nécessaire à notre projet.

### Création des fichiers pour l'environnement docker

Pour commencer créez le fichier Dockerfile, afin de définir comment sera créé l'image de votre container.

```bash
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
COPY src ./

# Ajout yarn au system
RUN npm install --global yarn

# Exposer le port du serveur Rails
EXPOSE 3000

# Entrée par défaut
CMD ["rails", "server", "-b", "0.0.0.0"]

```

En suite pour lancé la création de l'image et éventuellement d'autre service utile dans le projet, créez le fichier docker-compose.yml. C'est lui qui sera responsable de tous les containers dont on aura besoin dans le projet.

```yaml
services:
  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && rails server -b 0.0.0.0 -p 3000"
    volumes:
      - ./src:/app
    ports:
      - "3000:3000"

```

Le fichier entrypoint.sh

```bash
#!/bin/bash
set -e

# Supprimer un éventuel fichier de PID de serveur existant
rm -f /app/tmp/pids/server.pid

# Exécuter la commande donnée en argument
exec "$@"

```

A présent, créez un dossier src, puis créez le fichier src/Gemfile. Le fichier Gemfile va contenir toutes les librairies dont notre application aura besoin. On ajoutera au faire et à mesure des librairie à l'intérieur.

```bash
source 'https://rubygems.org'
gem 'rails', '~> 7.0'
gem 'sqlite3', '~> 1.4'

```

Pour finir créez src/Gemfile.lock et laissez le vide, c'est Ruby qui va se charger de le remplir.

### Mise en place et exécution du projet

Commencez par créer l'image qui permettra de créer un projet Ruby On Rails.

```bash
$ docker-compose build
```

Créez à présent votre premier projet Ruby On Rails

```bash
$ docker-compose run web rails new . --force --database=sqlite3
$ sudo chown -R ${USER}:${USER} src
```

Et pour finir créez l'image qui permettra de faire fonctionné le projet

```bash
$ docker-compose up --build -d
```

A présent rendez-vous sur l'url http://127.0.0.1:3000, et vous devrier voir apparaite çà:

![[Capture d'écran 2025-01-22 135028.png]]

## Les Fondamentaux de Rails

Comme nous l'avons vu un plutôt, Ruby On Rails est un Framework qui suit la logique du MVC. Nous allons commencer par la base de données et donc par les models.

### Les Modèles

Mettez en place le model de notre application de suivit de poids. Et pour commencer, créer le model WeightEntry, qui représentera la table weight_entry et qui contiendra weight (le poids) et la date où celui-ci à été noté.

```bash
$ docker-compose exec web rails generate model WeightEntry weight:decimal date:date
$ docker-compose exec web rails db:migrate
$ sudo chown -R ${USER}:${USER} src
```

Comme vous pouvez le voir, il y a deux parties: d'un côté la création du model et de la migration, et de l'autre on exécute la migration. Comme généralement vous n'êtes pas seul à développer un projet avec une base de donnée et que vous n'êtes pas toujours à côté des autres développeurs, on utilise un système de migration. A chaque fois que vous voulez ajouter une information sur votre base de données, vous la créez dans une fichier de migration et ensuite vous exécutez ce fichiez de migration. Comme çà lorsque vous récupérez le travail de vos collègues par exemple via GIT, vous voyez qu'il y a des fichiers de migration et bien vous n'avez qu'à les exécuter et votre base de données est à jour !

Et bien sûr vous pouvez ajouter directement quelques données, en vous connectant à la console Ruby On Rails de votre container

```bash
$ docker-compose exec web rails console
WeightEntry.create(weight: 75, date: "20/01/2025")
WeightEntry.create(weight: 76.4, date: "22/01/2025")
```

Pour quitter il vous suffit de taper Ctrl et q en même temaps.

### Les Routings et les URLs

A présent, vous avez une base de donnée et des fichiers Ruby On Rails, comment faire pour que par exemple si l'utilisateur tape l'url http://127.0.0.1:3000/ Vous lui affichiez les listes des poids entrez dans votre base de données ?

Rails utilise le concept RESTful pour simplifier les routes liées à des ressources. On va remplacer le contenu du fichier config/routes.rb par celui juste en dessous.

*config/routes.rb*
``` ruby
Rails.application.routes.draw do
  root "weight_entries#index"
  resources :weight_entries
end
```

Dans notre exemple, si on vient sur le site, sans choisir de page, on sera renvoyer vers le controller 
weight_entries et l'action index de celui ci. Parfois vous avez besoin de connaitre toutes les routes créez sur le projet, voici comment afficher la liste de toutes les routes existantes dans un projet Ruby On Rails:

```bash
$ docker-compose exec web rails routes

Prefix           Verb   URI Pattern                   Controller#Action
root             GET    /                             weight_entries#index
weight_entries   GET    /weight_entries(.:format)     weight_entries#index
                 POST   /weight_entries(.:format)     weight_entries#create
new_weight_entry GET    /weight_entries/new(.:format) weight_entries#new
edit_weight_entry GET   /weight_entries/:id/edit      weight_entries#edit
weight_entry     GET    /weight_entries/:id(.:format) weight_entries#show
                 PATCH  /weight_entries/:id(.:format) weight_entries#update
                 PUT    /weight_entries/:id(.:format) weight_entries#update
                 DELETE /weight_entries/:id(.:format) weight_entries#destroy

```

On voit ici que la seconde ligne à permit d'activé toutes les routes pour créer, editer, supprimer ou encore voir les données de la table weight_entries, lia les actions du Controller weight_entries.
### Les Contrôleurs

J'ai parlé de controller à plusieurs reprise, mais qu'est-ce que c'est ? C'est un fichier qui permet de regrouper les actions possible d'un application. Et une action, c'est par exemple lister tous les poids de la base de données où par exemple créer une nouveau poids en base de données, mais aussi afficher un formulaire pour créer un nouveau poids. On peut voir une action comme une page web, bien que parfois, çà ne soit pas une page, mais une redirection, comme dans le cas d'une création.

Commençons par le listing des poids stocker en base de données. Pour ce faire on va créer le controller WeightEntries et bien sûr l'action index.

```bash
$ docker-compose exec web rails generate controller WeightEntries index
$ sudo chown -R ${USER}:${USER} src
```

La seconde ligne est nécessaire car dans la première ligne on se connecte au container pour créer les fichiers nécessaire au controller et à l'action. Mais il est fort possible que le compte utilisé dans le controller ne soit pas le même que celui que vous utilisez sur votre ordinateur. Donc si vous voulez modifier par la suite le fichier créé, il faudra vous en donné l'autorisation et/ou la propriété.

Maintenant nous allons modifier ce controller pour qu'il liste les données de votre base.

*app/controllers/weight_entries_controllers.rb*
```ruby
class WeightEntriesController < ApplicationController
  def index
    @weight_entries = WeightEntry.order(date: :desc)
  end
end
```
### Les Vues

Comme on utilise le principe de MVC, on doit séparé l'affichage du traitement de données. Dans le controller on appelle le Model puis on effectue les opérations sur le données, quand il y a des opérations à effectué, puis on envoie le résultat à la vue.

Pour transmettre ses informations, on ajoute un '@' devant le nom des variables pour que l'on puisse les utiliser dans le vue.

*app/views/weight_entries/index.html.erb*
```ruby
<%# app/views/weight_entries/index.html.erb %>
<div class="container mx-auto p-6">
  <h1 class="text-4xl font-bold text-center text-blue-600 mb-6">Trackeuse de Poids</h1>

  <div class="flex justify-end mb-4">
    <%= link_to "Ajouter une nouvelle entrée", new_weight_entry_path, class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" %>
  </div>

  <div class="overflow-x-auto">
    <table class="min-w-full bg-white shadow-md rounded-lg">
      <thead>
        <tr class="bg-gray-200 text-gray-600 uppercase text-sm leading-normal">
          <th class="py-3 px-6 text-left">Date</th>
          <th class="py-3 px-6 text-left">Poids (kg)</th>
          <th class="py-3 px-6 text-center">Actions</th>
        </tr>
      </thead>
      <tbody class="text-gray-600 text-sm font-light">
        <% @weight_entries.each do |entry| %>
          <tr class="border-b border-gray-200 hover:bg-gray-100">
            <td class="py-3 px-6 text-left"><%= entry.date %></td>
            <td class="py-3 px-6 text-left"><%= entry.weight %></td>
            <td class="py-3 px-6 text-center flex justify-center">
              <%= link_to "Voir", weight_entry_path(entry), class: "text-blue-500 hover:underline" %> |
              <%= link_to "Modifier", edit_weight_entry_path(entry), class: "text-green-500 hover:underline" %> |
              <%= button_to weight_entry_path(entry), method: :delete, 
		        form: { data: { turbo_confirm: "Are you sure...?" } },
				class: "text-red-500 hover:underline", title: "Delete" do
				%>
				Supprimer
				<% end %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
</div>

```

Si vous retourner sur http://127.0.0.1:3000/ Vous devriez voir quelque chose çà:

![[Capture d'écran 2025-01-22 140247.png]]
### Supprimer un gem

On commence par supprimer la ligne correspondante au gem dans le fichier Gemfile, puis on fait

```bash
$ docker-compose exec web gem cleanup tailwindcss-rails
$ docker-compose exec web bundler clean --force
$ docker-compose down
$ docker-compose up --build -d
```


### Mettre à jour un gem

```bash
$ docker-compose exec web bundle update tailwindcss-rails
$ docker-compose down
$ docker-compose up --build -d
```

### Ajout de tailwind au projet

Pour ce projet nous allons utiliser tailwind comme Framework CSS. Voici comment l'intégrer facilement à votre projet

```
$ docker-compose exec web bundle add tailwindcss-rails
$ docker-compose exec web rails tailwindcss:install
$ sudo chown -R ${USER}:${USER} src
$ docker-compose down
$ docker-compose up --build -d
```

Et vous devriez voir la page comme ceci

![[Capture d'écran 2025-01-22 140708.png]]

### Les layouts

Les layouts dans Ruby on Rails sont des fichiers HTML qui servent de "cadres" ou de "gabarits" pour organiser et structurer les pages de votre application web. Ils définissent une structure commune pour toutes les pages ou un sous-ensemble de pages, ce qui permet de centraliser le design général de votre site.

Modification du layout principale.

*app/views/layouts/applicaiton.html/erb*
```
<%# app/views/layout/application.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for(:title) || "App" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <%= yield :head %>
    
    <link rel="manifest" href="/manifest.json">
    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">
    <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>
  
  <body>
    <main class="container mx-auto mt-28 px-5">
      <%= yield %>
    </main>
  </body>
</html>
```

### Mise en place l'ajout de données à notre base sqlite

Maintenant que le listing fonctionne il va falloir passer à la partie création, afin de pouvoir ajouter de nouvelle données au faire et à mesure.
#### Modification du controller

On va commencer par modifier le controller et créer deux action. L'une pour afficher le formulaire et éventuellement les erreurs qui pourrait s'y glisser, et l'une pour envoyer les données vers la base de données.

*app/controllers/weight_entries_controllers.rb*
```
class WeightEntriesController < ApplicationController

  def index
    @weight_entries = WeightEntry.order(date: :desc)
  end

  def new
    @weight_entry = WeightEntry.new(date: Date.current)
  end

  def create
    @weight_entry = WeightEntry.new(weight_entry_params)
    if @weight_entry.save
	      redirect_to weight_entries_path, notice: 'Votre suivi de poids a été ajouté avec succès.'
      else
	      render :new
      end
  end

  def show
  end

  def edit
  end

  def update
  end
  
  def destroy
  end

  private

    def weight_entry_params
      params.require(:weight_entry).permit(:weight, :date)
    end
  end
```

On peut s'arrêter sur la fonction weight_entry_params, qui permet de dire à Ruby On Rails, quelles sont les données venant du formulaire on peut utiliser pour ajouter des données. Ici, on récupère les données via la variable params (Ce sont les données envoyé par le formulaire en POST), et on va cherche les données concernant weight_entry, puis uniquement weight et date. Comme si jamais un pirate voulait ajouter des données, notre application ne les prendrait pas en compte.

#### Création de la vue

A présent, on s'occupe de présenter tout çà à l'écran !

*app/views/weight_entries/new.html.erb*
```
<%# app/views/weight_entries/new.html.erb %>

<h1 class="text-2xl font-bold text-center mb-6">Ajouter un nouveau suivi de poids</h1>

<%= form_with(model: @weight_entry, local: true, class: "max-w-3xl mx-auto p-6 bg-white shadow-md rounded-md") do |form| %>
  <% if @weight_entry.errors.any? %>
    <div class="mb-6 p-4 bg-red-200 text-red-700 rounded">
      <h2 class="text-xl font-semibold">Erreur(s) de validation</h2>
      <ul class="list-disc pl-5">
        <% @weight_entry.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="mb-4">
    <%= form.label :weight, class: "block font-medium text-gray-700" %>
    <%= form.number_field :weight, class: "w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500", step: "0.1", placeholder: "Entrez votre poids" %>
  </div>

  <div class="mb-4">
    <%= form.label :date, class: "block font-medium text-gray-700" %>
    <%= form.date_field :date, class: "w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" %>
  </div>

  <div class="flex justify-end">
    <%= form.submit "Enregistrer", class: "px-6 py-2 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500" %>
  </div>
<% end %>

<%= link_to 'Retour', weight_entries_path, class: "mt-6 block text-center text-blue-600 hover:text-blue-700" %>
```

#### Et pour finir on s'occupe du model

Effectivement, on va devoir vérifier et mettre quelques limite à l'enregistrement des données, par exemple, on ne veut pas d'un poids en dessous 0, personne ne pèse 0 kg ! De même on veut absolument que la date et le poids soit obligatoire !

*app/models/weight_entry.rb*
```
# app/models/weight_entry.rb
class WeightEntry < ApplicationRecord
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
end
```

### Recompilation du CSS des qu'il y a un changement

On va modifier un peu la configuration de puma et ajouter la ligne suivante à la fin du fichier config/puma.rb

```
plugin :tailwindcss
```

En suite on arrête le container et on le redémarre

```
docker-compose down
docker-compose up -d
```

En allant sur http://127.0.0.1:3000/weight_entries/new vous devriez voir

![[Capture d'écran 2025-01-22 150408.png]]

### Partie show

Pour continuer on va ajouter la page lorsque l'on clique sur le lien show. Et afficher les infos sur le poids et la date.

#### Modification du controller

On va dans ce cas là, ajouter une fonction (qui permet de récupérer un poids en fonction de l'id passer dans l'url) qui sera appeler lorsque l'on va sur les actions qui ont cet id dans leur irl, donc pour les actions show, edit, update et destroy.

*app/controllers/weight_entries_controllers.rb*
```
class WeightEntriesController < ApplicationController
  before_action :set_weight_entry, only: [:show, :edit, :update, :destroy]
  
  def index
    @weight_entries = WeightEntry.order(date: :desc)
  end

  def new
      @weight_entry = WeightEntry.new
  end

  def create
    @weight_entry = WeightEntry.new(weight_entry_params)
    if @weight_entry.save
      redirect_to weight_entries_path, notice: 'Votre suivi de poids a été ajouté avec succès.'
    else
      render :new
    end
  end
  
  def show
  end

  def edit
  end  

  def update
  end

  def destroy
  end

  private

  def set_weight_entry
    @weight_entry = WeightEntry.find(params[:id])
  end

  def weight_entry_params
    params.require(:weight_entry).permit(:weight, :date)
  end
end
```

#### Création de la vue

A présent, on s'occupe de présenter tout çà à l'écran !

*app/views/weight_entries/show.html.erb*
```
<%# app/views/weight_entries/show.html.erb %>

<h1 class="text-2xl font-bold text-center mb-6">Détails de l'entrée de poids</h1>

<div class="max-w-3xl mx-auto p-6 bg-white shadow-md rounded-md">
  <div class="mb-4">
    <h2 class="text-xl font-semibold text-gray-800">Poids</h2>
    <p class="text-lg text-gray-700"><%= @weight_entry.weight %> kg</p>
  </div>

  <div class="mb-4">
    <h2 class="text-xl font-semibold text-gray-800">Date</h2>
    <p class="text-lg text-gray-700"><%= @weight_entry.date.strftime("%d %B %Y") %></p>
  </div>

  <div class="flex justify-between mt-6">
    <%= link_to 'Modifier', edit_weight_entry_path(@weight_entry), class: "px-4 py-2 bg-yellow-600 text-white font-semibold rounded-md hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-yellow-500" %>
  </div>
</div>

<%= link_to 'Retour', weight_entries_path, class: "mt-6 block text-center text-blue-600 hover:text-blue-700" %>
```

Et si vous allez sur l'url http://127.0.0.1:3000/weight_entries/2 Vous devriez voir

![[Capture d'écran 2025-01-22 144921.png]]
### Partie suppression des donnnées

Effectivement c'est la troisième et avant dernière opération ! On va s'occuper du dernier bouton des actions possible lorsqu'on est dans le listing.

#### Modification du controller

*app/controllers/weight_entries_controllers.rb*
```
class WeightEntriesController < ApplicationController
  before_action :set_weight_entry, only: [:show, :edit, :update, :destroy]
  
  def index
    @weight_entries = WeightEntry.order(date: :desc)
  end

  def new
      @weight_entry = WeightEntry.new
  end

  def create
    @weight_entry = WeightEntry.new(weight_entry_params)
    if @weight_entry.save
      redirect_to weight_entries_path, notice: 'Votre suivi de poids a été ajouté avec succès.'
    else
      render :new
    end
  end
  
  def show
  end

  def edit
  end  

  def update
  end

  def destroy
	 @weight_entry.destroy
	 redirect_to weight_entries_path, notice: "Entrée supprimée."
  end

  private

  def set_weight_entry
    @weight_entry = WeightEntry.find(params[:id])
  end

  def weight_entry_params
    params.require(:weight_entry).permit(:weight, :date)
  end
end
```

#### Création de la vue

Il n'y en a pas vu qu'on va juste faire une redirection.

Mais on peut ajouter la lecture des messages. Car dans l'action destroy, on fait une redirection grâce à la fonction redirect_to, et on voit qu'il y a un argument notice:. On va voir comment afficher un message une seule fois lorsque l'on arrive sur la page de listring. Pour celà on va modifier le fichier 

*app/views/layouts/application.html.erb*
```
<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for(:title) || "App" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <%= yield :head %>
    
    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
	  <main class="container mx-auto mt-28 px-5">
    <% if flash[:notice] %>
    <div class="container mx-auto p-6">  
      <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
          <strong class="font-bold">Succès!</strong>
          <span class="block sm:inline"><%= flash[:notice] %></span>
        </div>
      </div>
    <% end %>
    
    <%= yield %>
    </main
  </body>
</html>
```

Lorsque vous aurez supprimé un poids vous devriez vous ceci

![[Capture d'écran 2025-01-22 145135.png]]

### Partie mise à jour des données

Comme pour la création, il va falloir utiliser deux actions, l'une pour afficher le formulaire l'autre pour faire les actions sur la base de données.

#### Modification du controller

*app/controllers/weight_entries_controllers.rb*
```
class WeightEntriesController < ApplicationController
  before_action :set_weight_entry, only: [:show, :edit, :update, :destroy]

  def index
    @weight_entries = WeightEntry.order(date: :desc)
  end

  def new
    @weight_entry = WeightEntry.new
  end

  def create
    @weight_entry = WeightEntry.new(weight_entry_params)
    if @weight_entry.save
      redirect_to weight_entries_path, notice: "Entrée de poids ajoutée avec succès."
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @weight_entry.update(weight_entry_params)
      redirect_to weight_entries_path, notice: "Entrée de poids mise à jour."
    else
      render :edit
    end
  end

  def destroy
    @weight_entry.destroy
    redirect_to weight_entries_path, notice: "Entrée supprimée."
  end

  private

  def set_weight_entry
    @weight_entry = WeightEntry.find(params[:id])
  end

  def weight_entry_params
    params.require(:weight_entry).permit(:weight, :date)
  end
end

```

#### Création de la vue

*app/views/weight_entries/edit.html.erb*
```
<%# app/views/weight_entries/edit.html.erb %>

<h1 class="text-2xl font-bold text-center mb-6">Modifier l'entrée de poids</h1>

<%= form_with model: @weight_entry, local: true, class: "max-w-3xl mx-auto p-6 bg-white shadow-md rounded-md" do |form| %>
  <% if @weight_entry.errors.any? %>
    <div class="mb-4 bg-red-100 text-red-700 p-4 rounded-md">
      <h2 class="font-semibold">Erreurs :</h2>
      <ul>
        <% @weight_entry.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="mb-4">
    <%= form.label :weight, "Poids (kg)", class: "block text-lg font-medium text-gray-700" %>
    <%= form.number_field :weight, class: "w-full px-4 py-2 mt-2 border rounded-md", step: "0.1", value: @weight_entry.weight, required: true %>
  </div>

  <div class="mb-4">
    <%= form.label :date, "Date de la mesure", class: "block text-lg font-medium text-gray-700" %>
    <%= form.date_field :date, class: "w-full px-4 py-2 mt-2 border rounded-md", value: @weight_entry.date.strftime("%Y-%m-%d"), required: true %>
  </div>

  <div class="flex justify-between items-center">
    <%= form.submit "Mettre à jour", class: "px-4 py-2 w-full bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500" %>
  </div>
<% end %>


<%= link_to 'Retour', weight_entries_path, class: "mt-6 block text-center text-blue-600 hover:text-blue-700" %>
```

Et voilà ce que çà doit rendre finalement

![[Capture d'écran 2025-01-22 145826.png]]

## Ajout d'un librairie de chart

A présent on va voir comment ajouter des modules et des librairies externe au projet. Ici nous allons utiliser une librairie pour afficher une courbe pour voir l'évolution de notre poids.

On commence par modifier le Gemfile et ajoutant la ligne suivante à lafin.

*Gemfile*
```
gem "chartkick"
```

En suite on lance l'installation du gem

```
docker-compose up -d --build
```

Suivant la configuration de votre projet, la suite peu changer. Mais par défaut on utilise les importmap dans les projets récents. Voici la suite de la configuration.

*config/importmap.rb*
```
pin "chartkick", to: "chartkick.js" 
pin "Chart.bundle", to: "Chart.bundle.js"
```

En suite, on va ajouter la partie javascript à notre application.
*app/javascript/application.js*
```
import "chartkick" 
import "Chart.bundle"
```

Et pour finir pour ajoute le html qui va générer le chart dans notre page.
*app/views/index.html.erb*
```
<%# app/views/weight_entries/index.html.erb %>
<div class="container mx-auto p-6">
  <h1 class="text-4xl font-bold text-center text-blue-600 mb-6">Trackeuse de Poids</h1>

  <div class="mb-4">
    
  </div>

  <div class="flex justify-end mb-4">
    <%= link_to "Ajouter une nouvelle entrée", new_weight_entry_path, class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" %>
  </div>
  
  <div class="overflow-x-auto">
    <table class="min-w-full bg-white shadow-md rounded-lg">
      <thead>
        <tr class="bg-gray-200 text-gray-600 uppercase text-sm leading-normal">
          <th class="py-3 px-6 text-left">Date</th>
          <th class="py-3 px-6 text-left">Poids (kg)</th>
          <th class="py-3 px-6 text-center">Actions</th>
        </tr>
      </thead>
      <tbody class="text-gray-600 text-sm font-light">
        <% @weight_entries.each do |entry| %>
          <tr class="border-b border-gray-200 hover:bg-gray-100">
            <td class="py-3 px-6 text-left"><%= entry.date %></td>
            <td class="py-3 px-6 text-left"><%= entry.weight %></td>
            <td class="py-3 px-6 text-center flex justify-center">
              <%= link_to "Voir", weight_entry_path(entry), class: "text-blue-500 hover:underline" %> |
              <%= link_to "Modifier", edit_weight_entry_path(entry), class: "text-green-500 hover:underline" %> |
              <%= button_to weight_entry_path(entry), method: :delete,
            form: { data: { turbo_confirm: "Are you sure...?" } },
        class: "text-red-500 hover:underline", title: "Delete" do
      %>
        Supprimer
        <% end %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
</div>
```

Et en vous rendant sur http://127.0.0.1:3000 vous devriez voir:

![[Capture d'écran 2025-01-22 152145.png]]

## Authentification

### Installation du gem devise

On ajoute directement devise dans le fichier Gemfile

*src/Gemfile*
```
gem 'devise'
```

ou

```bash
$ docker-compose exec web bundle add devise
```

En suite il faut relancer le build pour ajouter le gem au projet

```
$ docker-compose down
$ docker-compose up --build -d
```

Maintenant il faut installé et configurer devise  au niveau du projet

```
$ docker-compose exec web rails generate devise:install
```

Tous les fichiers nécessaire vont être créé ainsi que la configuration.

### Mise en place de la base de données

Comme pour toute authentification, il va falloir créer une table users, avec les informations nécessaire à l'authentification des utilisateurs.

```
$ docker-compose exec web rails generate devise User
$ docker-compose exec web rails db:migrate
$ docker-compose down
$ docker-compose up -d
```

### Configuration des permissions

Maintenant que nous avons la base de donnée qui est en place, il va falloir restreindre l'accès aux pages en fonction de l'utilisateur connecté.

*app/controllers/weight_entries_controllers.rb*
```
class WeightEntriesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_weight_entry, only: [:show, :edit, :update, :destroy]

	def index
		@weight_entries = WeightEntry.order(date: :desc)
	end

	def new
	    @weight_entry = WeightEntry.new
	end

	def create
		@weight_entry = WeightEntry.new(weight_entry_params)
		if @weight_entry.save
			redirect_to weight_entries_path, notice: "Entrée de poids ajoutée avec succès."
		else
			render :new
		end
	end

	def show
	end

	def edit
	end

	def update
	    if @weight_entry.update(weight_entry_params)
		    redirect_to weight_entries_path, notice: "Entrée de poids mise à jour."
	    else
		    render :edit
	    end
	end

	def destroy
		@weight_entry.destroy
		redirect_to weight_entries_path, notice: "Entrée supprimée."
	end

	private

	def set_weight_entry
		@weight_entry = WeightEntry.find(params[:id])
	end

	def weight_entry_params
		params.require(:weight_entry).permit(:weight, :date)
	end
end
```

*app/controllers/application_controller.rb*
```
class ApplicationController < ActionController::Base
	before_action :authenticate_user!
	# Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.

	allow_browser versions: :modern
	
	def after_sign_in_path_for(resource)
		weight_entries_path # Remplacez par la page souhaitée 
	end
end
```

### Personnalisation des vues

Si les vues par default ne vous plaise pas, vous pouvez les modifier. Dans un premier temps, il faut générer les fichiers au niveau de votre application. Pour bien comprendre il y a un système de fallback, c'est à dire que Ruby On Rails va d'abord regarder dans les fichiers du dossier app/views s'il y a des templates, s'il n'y en a pas, il va regarder dans les fichiers du gems.

Ici, on va utiliser la génération automatique des fichiers et ensuite, vous n'aurez plus qu'à afficher le choses !

```
$ docker-compose exec web rails generate devise:views
$ sudo chown -R ${USER}:${USER} src
```

Et pour finir on ajout le bouton de déconnexion et de ceux de connextion, création de compte. Dans un premier temps on va créer un dossier shared pour stocker les templates que l'on peut inclure dans notre application.

```
$ mkdir app/views/shared
```


*app/views/shared/_nav.html.erb*
```
<nav class="bg-blue-600 text-white p-4"> 
	<div class="container mx-auto flex justify-between items-center"> 
		<div class="text-lg font-bold"> 
			<%= link_to 'Mon Application', root_path, class: "hover:underline" %> 
		</div>
		
		<div class="flex items-center justify-center">
		<% if user_signed_in? %>
			<span class="mr-4"><%= current_user.email %></span> 
			<%= button_to destroy_user_session_path, method: :delete,
                    form: { data: { turbo_confirm: "Etes vous sûr ? ?" } },
                    class: "text-white hover:bg-red-700 bg-red-500 rounded-xl px-4 py-2", title: "Déconnexion" do
                %>
                    Déconnexion
                <% end %>
		<% else %> 
			<%= link_to 'Connexion', new_user_session_path, class: "text-blue-300 hover:text-white mr-4" %> 
			<%= link_to 'Inscription', new_user_registration_path, class: "text-blue-300 hover:text-white" %> 
		<% end %>
		</div>
	</div>
</nav>
```

En suite on l'ajout au layout de l'application

*app/views/layouts/application.html.erb*
```
<!DOCTYPE html>
<html>
	<head>
		<title><%= content_for(:title) || "App" %></title>
		<meta name="viewport" content="width=device-width,initial-scale=1">
		<meta name="mobile-web-app-capable" content="yes">
		<%= csrf_meta_tags %>
		<%= csp_meta_tag %>
		
		<%= yield :head %>
    
		<link rel="icon" href="/icon.png" type="image/png">
		<link rel="icon" href="/icon.svg" type="image/svg+xml">
		<link rel="apple-touch-icon" href="/icon.png">
		<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
		<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
		<%= javascript_importmap_tags %>
	</head>

	<body>
		<%= render "shared/nav" %>
		
		<main class="container mx-auto mt-28 px-5">
			<% if flash[:notice] %>
				<div class="container mx-auto p-6">  
					<div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
						<strong class="font-bold">Succès!</strong>
						<span class="block sm:inline"><%= flash[:notice] %></span>
					</div>
				</div>
			<% end %>
		
			<%= yield %>
		</main
	</body>
</html>
```


Et pour finir on va styliser un peu la page de register et de login.

*app/views/devise/sessions/new*
```
<div class="border border-gray-200 rounded-2xl p-10 w-1/2 m-auto bg-blue-600/30 shadow-lg">
  <h2 class="text-center text-3xl">Connexion</h2>

  <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
    <div class="field mt-4">
      <%= f.label :email %><br />
      <%= f.email_field :email, autofocus: true, autocomplete: "email", class: "w-full p-3 border border-gray-200 rounded-xl" %>
    </div>

    <div class="field mt-4">
      <%= f.label :password %><br />
      <%= f.password_field :password, autocomplete: "current-password", class: "w-full p-3 border border-gray-200 rounded-xl" %>
    </div>

    <% if devise_mapping.rememberable? %>
      <div class="field mt-4">
        <%= f.check_box :remember_me %>
        <%= f.label :remember_me %>
      </div>
    <% end %>

    <div class="actions mt-4">
      <%= f.submit "Log in", class: 'text-white border border-blue-600 bg-blue-600 hover:bg-blue-700 hover:border-blue-700 rounded-xl px-4 py-2' %>
    </div>
  <% end %>
  <%= render "devise/shared/links" %>
</div>
```

*app/views/devise/shared/_links.html.erb*
```
<div class="mt-4 flex items-center justify-between w-2/3 m-auto">
  <%- if controller_name != 'sessions' %>
    <%= link_to "Déjà un compte ?", new_session_path(resource_name) %><br />
  <% end %>

  <%- if devise_mapping.registerable? && controller_name != 'registrations' %>
    <%= link_to "Pas encore de compte ?", new_registration_path(resource_name) %><br />
  <% end %>

  <%- if devise_mapping.recoverable? && controller_name != 'passwords' && controller_name != 'registrations' %>
    <%= link_to "Mot de passe oublié ?", new_password_path(resource_name) %><br />
  <% end %>

  <%- if devise_mapping.confirmable? && controller_name != 'confirmations' %>
    <%= link_to "Didn't receive confirmation instructions?", new_confirmation_path(resource_name) %><br />
  <% end %>

  <%- if devise_mapping.lockable? && resource_class.unlock_strategy_enabled?(:email) && controller_name != 'unlocks' %>
    <%= link_to "Didn't receive unlock instructions?", new_unlock_path(resource_name) %><br />
  <% end %>

  <%- if devise_mapping.omniauthable? %>
    <%- resource_class.omniauth_providers.each do |provider| %>
      <%= button_to "Sign in with #{OmniAuth::Utils.camelize(provider)}", omniauth_authorize_path(resource_name, provider), data: { turbo: false } %><br />
    <% end %>
  <% end %>
</div>
```

*app/views/devise/registrations/new*
```ruby
<div class="border border-gray-200 rounded-2xl p-10 w-1/2 m-auto bg-blue-600/30 shadow-lg">

  <h2 class="text-center text-3xl">Créez votre compte</h2>

  

  <%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>

    <%= render "devise/shared/error_messages", resource: resource %>

  

    <div class="field mt-4">

      <%= f.label :email %><br />

      <%= f.email_field :email, autofocus: true, autocomplete: "email", class: "w-full p-3 border border-gray-200 rounded-xl" %>

    </div>

  

    <div class="field mt-4">

      <%= f.label :password %>

      <% if @minimum_password_length %>

        <em>(<%= @minimum_password_length %> characters minimum)</em>

      <% end %><br />

      <%= f.password_field :password, autocomplete: "new-password", class: "w-full p-3 border border-gray-200 rounded-xl" %>

    </div>

  

    <div class="field mt-4">

      <%= f.label :password_confirmation %><br />

      <%= f.password_field :password_confirmation, autocomplete: "new-password", class: "w-full p-3 border border-gray-200 rounded-xl" %>

    </div>

  

    <div class="actions mt-4">

      <%= f.submit "Créez le compte", class: 'text-white border border-blue-600 bg-blue-600 hover:bg-blue-700 hover:border-blue-700 rounded-xl px-4 py-2' %>

    </div>

  <% end %>

  

  <%= render "devise/shared/links" %>

</div>
```

*app/views/devise/passwords/new.html.erv*
```ruby
<div class="border border-gray-200 rounded-2xl p-10 w-1/2 m-auto bg-blue-600/30 shadow-lg">

  <h2 class="text-center text-3xl">Mot de passe oublié ?</h2>

  <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f| %>
    <%= render "devise/shared/error_messages", resource: resource %>

    <div class="field mt-4">
      <%= f.label :email %><br />
      <%= f.email_field :email, autofocus: true, autocomplete: "email", class: "w-full p-3 border border-gray-200 rounded-xl" %>
    </div>


    <div class="actions mt-4">
      <%= f.submit "Envoyer le lien par mail", class: 'text-white border border-blue-600 bg-blue-600 hover:bg-blue-700 hover:border-blue-700 rounded-xl px-4 py-2' %>
    </div>
  <% end %>

  <%= render "devise/shared/links" %>
</div>
```
## Liaison entre les utilisateurs et les entrées de poids

### Modification des models pour les liés

Il va falloir dire de chaque côté de l'association comment sont liés les deux models

*app/models/weight_entry.rb*
```ruby
class WeightEntry < ApplicationRecord
	belongs_to :user
	
	validates :weight, presence: true, numericality: { greater_than: 0 }
	validates :date, presence: true
end
```

A présent le model User

*app/models/user.rb*
```ruby
class User < ApplicationRecord
	# Associations from Devise 
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable # Relationship with weight entries has_many :weight_entries, dependent: :destroy

	has_many :weight_entries, dependent: :destroy
end
```

Maintenant que les models sont modifiés, il va falloir générer le fichier de migration pour mettre à jour la base de données.

```bash
$ docker-compose exec web rails generate migration AddUserToWeightEntries user:references
$ docker-compose exec web rails db:migrate
```

Pour finir on va modifier la fonction set_weight_entry du controller, afin que l'on récupère uniquement les entrées de l'utilisateurs. Ainsi que toutes les requêtes de récupération des données.

