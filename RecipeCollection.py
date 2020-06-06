import os
from tools import downloadURLtoFile
import json
import jsonschema


class RecipeCollection:

    defaultRecipesURL = 'https://raw.githubusercontent.com/derkomai/alfred/master/recipes.json'
    defaultRecipesPath = '/tmp/alfredRecipes.json'

    defaultSchemaURL = 'https://raw.githubusercontent.com/derkomai/alfred/master/recipeSchema.json'
    defaultSchemaPath = '/tmp/alfredRecipeSchema.json'

    def __init__(self, recipesFilePath=None, schemaFilePath=None):

        self.recipes = None
        self.schema = None
        self.loaded = False
        self.error = None

        # Download the default recipes file if not provided
        if not recipesFilePath:

            # Check that the recipes file has been correctly downloaded
            if downloadURLtoFile(RecipeCollection.defaultRecipesURL,
                                 RecipeCollection.defaultRecipesPath):
                recipesFilePath = RecipeCollection.defaultRecipesPath

            else:
                self.error = 'The default recipes could not be downloaded'
                return

        else:

            # Check that the provided config file exists
            if not os.path.isfile(recipesFilePath):
                self.error = 'The provided recipes path does not exist'
                return

        self.recipesFilePath = recipesFilePath

        # Load the recipes
        try:
            with open(self.recipesFilePath, 'r') as recipesFile:
                self.recipes = json.load(recipesFile)

        except json.JSONDecodeError:
            self.error = 'JSON parse error while loading the recipes file'
            return


        # Download the default schema file if not provided
        if not schemaFilePath:

            # Check that the schema file has been correctly downloaded
            if downloadURLtoFile(RecipeCollection.defaultSchemaURL,
                                 RecipeCollection.defaultSchemaPath):
                schemaFilePath = RecipeCollection.defaultSchemaPath

            else:
                self.error = 'The default recipes schema could not be downloaded'
                return

        else:

            # Check that the provided file exists
            if not os.path.isfile(schemaFilePath):
                self.error = 'The provided schema path does not exist'
                return

        self.schemaFilePath = schemaFilePath

        # Load the schema
        try:
            with open(self.schemaFilePath, 'r') as schemaFile:
                self.schema = json.load(schemaFile)

        except json.JSONDecodeError:
            self.error = 'JSON parse error while loading the schema file'
            return

        # Validate the recipes
        try:
             jsonschema.validate(instance=self.recipes, schema=self.schema)

        except jsonschema.ValidationError as ex:
            self.error = f'The recipes did not validate against the schema:\n{ex}'
            return

        self.loaded = True


    def __getitem__(self, key):
        return self.recipes[key]


    def __iter__(self):
        return self.recipes.__iter__()