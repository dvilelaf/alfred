import json
from jsonschema import validate
from RecipeCollection import RecipeCollection

# with open('../recipes.json', 'r') as recipeFile:
#     recipes = json.load(recipeFile)


# newrecipes = {}
# for r in recipes:
#     newrecipes[r['name']] = r
#     newrecipes[r['name']]['category'] = ''
#     newrecipes[r['name']]['requiresConnection'] = True
#     del newrecipes[r['name']]['name']


# with open('../newrecipes.json', 'w') as recipeFile:
#     json.dump(newrecipes, recipeFile, indent=4)

# with open('../recipeSchema.json', 'r') as recipeSchemaFile:
#     # json.dump(packages, recipeFile, indent=4)
#     recipeSchema = json.load(recipeSchemaFile)

# validate(instance=recipes, schema=recipeSchema)


a = RecipeCollection('/home/david/pCloudDrive/Code/Projects/alfred/recipes.json',
                     '/home/david/pCloudDrive/Code/Projects/alfred/recipeSchema.json')

for i in a:
    print(i)
    print(a[i]['description'])

print(a.loaded)
print(a.error)