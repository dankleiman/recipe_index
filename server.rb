require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG::Connection.open(dbname: 'recipes')
    yield(connection)
  ensure
    connection.close
  end
end

def get_recipes
  db_connection do |conn|
    conn.exec("SELECT id, name FROM recipes")
  end
end

def get_recipe_details(id)
  db_connection do |conn|
    conn.exec_params("SELECT recipes.name AS recipe, recipes.instructions, recipes.description, ingredients.name AS ingredients
      FROM ingredients JOIN recipes ON recipes.id = ingredients.recipe_id WHERE recipes.id = $1", [id])
  end
end

get '/recipes' do
  @recipes = get_recipes
  erb :index
end

get '/recipes/:id' do
  id = params[:id]
  @recipe_details = get_recipe_details(id)
  erb :show
end
