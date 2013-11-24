FORMAT: 1A
HOST: https://api.malt.io

Tapline Homebrewing API
=======================
Tapline is an API for [Malt.io](http://beta.malt.io/), a homebrewing community website. It provides access to users, recipes, and conversion/calculation functions that any client can use if they can speak HTTPS and JSON.

Tapline is split into two logical components. You can use just one of these, or both if your application requires it. The simplest is the public API because it does not require getting authorization from an existing user nor sending any special headers. Be aware that the public API provides **read-only** access to stored state like recipes. To create, edit, or delete recipes you must use the authenticated API instead.

 1. Public API

    * Utility functions

    * Read-only access to users, recipes, etc

    * Creating new users

    * Getting authorizations

 1. Authenticated API

    * Full access to users, recipes, etc

## Examples

 * [Display a list of users](http://jsfiddle.net/danielgtaylor/vn3Rt/)

## Formats
JSON is the primary format used within Tapline, but for the HTTP `GET` request method query arguments are typically used. For example, to get a list of recipes:

```http
GET /v1/public/recipes?limit=5&sort=name HTTP/1.1
```

The above uses HTTP query parameters, while `POST`, `PUT`, and `DELETE` methods use JSON. For example, modifying a recipe would use a JSON content body:

```http
PUT /v1/recipes/3jl452lk42h3 HTTP/1.1
Content-Type: application/json
Authorization: bearer k4j534h53j4lh53l4j5

{
    private: false,
    recipe: {
        "name": "My Recipe",
        "description": "...",
        ...
    }
}
```

Responses will always return JSON when successful, and a plain text error message when an error has occured. For example:

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-Request-ID: k23l4j2
X-Response-Time: 16ms

{
    "id": "23k4j2k3j42h34",
    "name": "User name",
    ...
}
```

An error, on the other hand, would be returned like this:

```http
HTTP/1.1 400 BAD REQUEST
Content-Type: text/html
X-Request-ID: hf324d6j
X-Response-Time: 2ms

Error: JSON object property 'sort' is not in enum
```

# Group Anonymous Public API
Public calls that do not require authentication. These calls cannot change stored state - for example you can only **read** recipes, not **write** them. See the authenticated API calls for information on how to write data on behalf of a user.

## Convert Duration [/v1/convert/duration]

+ Parameters

    + values (required, array, `[1, 2]`) ... List of durations to convert
    + outputFormat = `minutes` (optional, string, `display`) ... Output format

        + Values
            + `minutes`
            + `display`

    + approximate (optional, integer, `2`) ... Approximate the display duration to this many significant units. For example, `'2 days 1 hour 15 minutes'` approximated to `2` would be `'2 days 1 hour'`.

### Convert [POST]
Utilities to convert one or more representations of durations. Converts between a number of minutes and a user-friendly string representation of a duration.

+ Request

    + Headers

            Content-Type: application/json

    + Body

        {
            "values": [
                5823,
                "1 day 23 hours 2min",
                "60hrs"
            ],
            "outputFormat": "display"
        }

+ Response 200

    + Headers

            Content-Type: application/json

    + Body

        {
            "format": "display",
            "values": [
                "4 days 1 hour 3 minutes", 
                "1 day 23 hours 2 minutes", 
                "2 days 12 hours"
            ]
        }

+ Response 400

    Invalid output format 'foo'!

## Convert Color [/v1/convert/color]

+ Parameters

    + format (required, string, `ebc`) ... Input format

        + Values
            + `ebc`
            + `srm`
            + `lovibond`

    + values (required, array, `[1, 2]`) ... List of colors to convert
    + outputFormat = `ebc` (optional, string, `srm`) ... Output format

        + Values
            + `ebc`
            + `srm`
            + `lovibond`
            + `name`
            + `rgb`
            + `css`

### Convert [POST]
Utilities to convert one or more representations of colors.

+ Request

    + Headers

            Content-Type: application/json

    + Body

        {
            "format": "srm",
            "values": [
                4,
                9,
                15,
                20,
                28
            ]
            "outputFormat": "ebc"
        }

+ Response 200

    + Headers

            Content-Type: application/json

    + Body

        {
            "format": "ebc",
            "values": [
                7.88,
                17.73,
                29.55,
                39.4,
                55.16
            ]
        }

+ Response 400

    Invalid output format 'foo'!

## Convert Recipe [/v1/convert/recipe]

+ Parameters

    + format (required, string, `beerxml`) ... Input format

        + Values
            + `json`
            + `beerxml`

    + recipes (required, array, `['<beerxml>...</beerxml>']`) ... List of recipes to convert
    + outputFormat = `json` (optional, string, `beerxml`) ... Output format

        + Values
            + `json`
            + `beerxml`

### Convert [POST]
Utilities to convert one or more representations of a serialized recipe.

+ Request

    + Headers

            Content-Type: application/json

    + Body

        {
            "format": "beerxml",
            "recipes": [
                "<recipes><recipe><version>1</version><name>Test</name><fermentables><fermentable><name>Pale extract</name><amount>3.5</amount><yield>75</yield></fermentable></fermentables></recipe></recipes>"
            ],
            "outputFormat": "json"
        }

+ Response 200

    + Headers

            Content-Type: application/json

    + Body

        {
            "format": "json", 
            "recipes": [
                {
                    "agingDays": 14, 
                    "agingTemp": 20, 
                    "author": "Anonymous Brewer", 
                    "batchSize": 20, 
                    "boilSize": 10, 
                    "bottlingPressure": 0, 
                    "bottlingTemp": 0, 
                    "description": "Recipe description", 
                    "fermentables": [
                        {
                            "color": 2, 
                            "late": false, 
                            "name": "Pale extract", 
                            "weight": 3.5, 
                            "yield": 75
                        }
                    ], 
                    "ibuMethod": "tinseth", 
                    "mash": null, 
                    "mashEfficiency": 75, 
                    "name": "Test", 
                    "primaryDays": 14, 
                    "primaryTemp": 20, 
                    "secondaryDays": 0, 
                    "secondaryTemp": 0, 
                    "servingSize": 0.355, 
                    "spices": [], 
                    "steepEfficiency": 50, 
                    "steepTime": 20, 
                    "style": null, 
                    "tertiaryDays": 0, 
                    "tertiaryTemp": 0, 
                    "yeast": []
                }
            ]
        }

+ Response 400

    Invalid output format 'foo'!

## Calculate Recipe [/v1/calculate/recipe]

+ Parameters

    + format (required, string, `beerxml`) ... Input format

        + Values
            + `json`
            + `beerxml`

    + recipes (required, array, `['<beerxml>...</beerxml>']`) ... List of recipes to convert
    + siUnits = `true` (optional, boolean, `false`) ... True to use kg, liters and &deg;C instead of lb, oz, gallons, and &deg;F

### Calculate [POST]
Utilities to convert one or more representations of a serialized recipe.

+ Request

    + Headers

            Content-Type: application/json

    + Body

        {
            "format": "beerxml",
            "recipes": [
                "<recipes><recipe><version>1</version><name>Test</name><fermentables><fermentable><name>Pale extract</name><amount>3.5</amount><yield>75</yield></fermentable></fermentables></recipe></recipes>"
            ],
            "siUnits": true
        }

+ Response 200

    + Headers

            Content-Type: application/json

    + Body

        [
            {
                "abv": 4.982895960844915, 
                "abw": 3.8872943605883177, 
                "buToGu": 0, 
                "bv": 0, 
                "calories": 165.65117039861516, 
                "color": 3.1126033196646703, 
                "fg": 1.0126549326899237, 
                "fgPlato": 3.2323394802073437, 
                "grainWeight": 0, 
                "ibu": 0, 
                "og": 1.0506197307596945, 
                "ogPlato": 12.534722891468903, 
                "price": 15.400000000000002, 
                "realExtract": 4.914210400963434, 
                "timeline": [
                    [
                        0, 
                        "Bring 10.0l to a rolling boil (about 21 minutes)."
                    ], 
                    [
                        21, 
                        "Flame out. Begin chilling to 20°C and aerate the cooled wort (about 20 minutes)."
                    ], 
                    [
                        41, 
                        "Pitch yeast and seal the fermenter. You should see bubbles in the airlock within 24 hours."
                    ], 
                    [
                        20201, 
                        "Prime and bottle about 56 bottles. Age at 20C for 14 days."
                    ], 
                    [
                        40361, 
                        "Relax, don't worry and have a homebrew!"
                    ]
                ]
            }
        ]

+ Response 400

    Invalid input format 'foo'!

## Recipe Collection [/v1/public/recipes]
A collection of recipes.

+ Parameters

    + ids (optional, string, `100,102,105`) ... List of recipe IDs
    + userIds (optional, string, `200,201,204`) ... List of recipe owner user IDs
    + slugs (optional, string, `test-recipe,hefeweizen`) ... List of recipe slugs to find in conjunction with `userIds`
    + offset = `0` (optional, integer, `0`) ... Number of recipes to skip
    + limit = `20` (optional, integer, `30`) ... Number of recipes returned
    + sort = `-created` (optional, string, `name`) ... Sort method
    
        + Values
            + `created`
            + `-created`
            + `name`
            + `-name`

    + detail = `false` (optional, boolean, `true`) ... Whether to show detailed info

+ Model
A list of recipes

    + Headers
    
            Content-Type: application/json; charset=utf-8

    + Body

            [
                {
                    "created": "2013-11-02T17:25:51.275Z", 
                    "data": {
                        "agingDays": 14, 
                        "agingTemp": 20, 
                        "agingTempF": 68, 
                        "author": "Anonymous Brewer", 
                        "batchSize": 20, 
                        "batchSizeGallons": 5.283440000000001, 
                        "boilSize": 10, 
                        "boilSizeGallons": 2.6417200000000003, 
                        "bottlingPressure": 2.5, 
                        "bottlingTemp": 23, 
                        "bottlingTempF": 73.4, 
                        "description": "Just a basic beer example for testing. foo this is a long description", 
                        "fermentables": [
                            {
                                "color": 6.096, 
                                "late": false, 
                                "name": "Extra pale extract", 
                                "weight": 4.5, 
                                "yield": 75
                            }
                        ], 
                        "ibuMethod": "tinseth", 
                        "mash": null, 
                        "mashEfficiency": 75, 
                        "name": "Another Beer 2", 
                        "primaryDays": 14, 
                        "primaryTemp": 20, 
                        "primaryTempF": 68, 
                        "secondaryDays": 0, 
                        "secondaryTemp": 0, 
                        "secondaryTempF": 32, 
                        "servingSize": 0.355, 
                        "servingSizeOz": 0.09378106, 
                        "spices": [
                            {
                                "aa": 4.5, 
                                "form": "pellet", 
                                "name": "Cascade hops", 
                                "time": 60, 
                                "use": "boil", 
                                "weight": 0.028349556839727483
                            }
                        ], 
                        "steepEfficiency": 50, 
                        "steepTime": 20, 
                        "style": null, 
                        "tertiaryDays": 0, 
                        "tertiaryTemp": 0, 
                        "tertiaryTempF": 32, 
                        "yeast": [
                            {
                                "attenuation": 74, 
                                "form": "liquid", 
                                "name": "Wyeast 3052", 
                                "type": "ale"
                            }
                        ]
                    }, 
                    "id": "5275359f031555931a000005", 
                    "private": false, 
                    "slug": "another-beer-2", 
                    "user": {
                        "id": "51de54131084ffeef8000001", 
                        "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
                        "name": "daniel"
                    }
                }, 
                {
                    "created": "2013-10-24T20:39:23.320Z", 
                    "data": {
                        "agingDays": 14, 
                        "agingTemp": 20, 
                        "agingTempF": 68, 
                        "author": "Anonymous Brewer", 
                        "batchSize": 20, 
                        "batchSizeGallons": 5.283440000000001, 
                        "boilSize": 10, 
                        "boilSizeGallons": 2.6417200000000003, 
                        "bottlingPressure": 2.5, 
                        "bottlingTemp": 23, 
                        "bottlingTempF": 73.4, 
                        "description": "Just a basic beer example for testing. foo this is a long description", 
                        "fermentables": [
                            {
                                "color": 1.27, 
                                "late": false, 
                                "name": "Extra pale extract", 
                                "weight": 4.5, 
                                "yield": 75
                            }
                        ], 
                        "ibuMethod": "tinseth", 
                        "mash": null, 
                        "mashEfficiency": 75, 
                        "name": "Hefeweizen", 
                        "primaryDays": 14, 
                        "primaryTemp": 20, 
                        "primaryTempF": 68, 
                        "secondaryDays": 0, 
                        "secondaryTemp": 0, 
                        "secondaryTempF": 32, 
                        "servingSize": 0.355, 
                        "servingSizeOz": 0.09378106, 
                        "spices": [
                            {
                                "aa": 4.5, 
                                "form": "pellet", 
                                "name": "Cascade hops", 
                                "time": 60, 
                                "use": "boil", 
                                "weight": 0.028349556839727483
                            }
                        ], 
                        "steepEfficiency": 50, 
                        "steepTime": 20, 
                        "style": null, 
                        "tertiaryDays": 0, 
                        "tertiaryTemp": 0, 
                        "tertiaryTempF": 32, 
                        "yeast": [
                            {
                                "attenuation": 74, 
                                "form": "liquid", 
                                "name": "Wyeast 3052", 
                                "type": "ale"
                            }
                        ]
                    }, 
                    "id": "5269857b7011ba8186000001", 
                    "private": false, 
                    "slug": "hefeweizen", 
                    "user": {
                        "id": "51de54131084ffeef8000001", 
                        "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
                        "name": "daniel"
                    }
                }
            ]

### Get recipes [GET]
Gets a list of recipes given the input parameters for filtering and sorting. An example call would look like this:

```no-highlight
https://api.malt.io/v1/public/recipes?detail=true
```

+ Response 200

    [Recipe Collection][]

+ Response 400

    Invalid sort option

## Actions Collection [/v1/public/actions]

+ Model
A list of user actions.

    + Headers
    
            Content-Type: application/json; charset=utf-8

    + Body

            [
                {
                    "created": "2013-11-12T05:52:58.487Z", 
                    "data": {
                        "abv": 6.294638860098035, 
                        "color": 7.9427671464530025, 
                        "description": "Just a basic beer example for testing. foo this is a long description", 
                        "fg": 1.016921452853955, 
                        "ibu": 8.232188432976319, 
                        "name": "Another Beer 2", 
                        "og": 1.0650825109767499, 
                        "slug": "another-beer-2"
                    }, 
                    "id": "5281c23a5889ca3e8b000001", 
                    "private": false, 
                    "targetId": "5275359f031555931a000005", 
                    "type": "recipe-updated", 
                    "user": {
                        "id": "51de54131084ffeef8000001", 
                        "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
                        "name": "daniel"
                    }
                }, 
                {
                    "created": "2013-11-12T00:23:43.863Z", 
                    "data": {
                        "abv": 6.294638860098035, 
                        "color": 7.9427671464530025, 
                        "description": "Just a basic beer example for testing. foo this is a long description", 
                        "fg": 1.016921452853955, 
                        "ibu": 8.232188432976319, 
                        "name": "Another Beer 2", 
                        "og": 1.0650825109767499, 
                        "slug": "another-beer-2"
                    }, 
                    "id": "5281750f0f7d42a578000004", 
                    "private": false, 
                    "targetId": "5275359f031555931a000005", 
                    "type": "recipe-updated", 
                    "user": {
                        "id": "51de54131084ffeef8000001", 
                        "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
                        "name": "daniel"
                    }
                },
            ]

### Get actions [GET]
Gets a list of user actions.

+ Parameters

    + userIds (optional, array, `['id1', 'id2']`) ... List of user IDs
    + ids (optional, array, `['id1', 'id2']`) ... List of action IDs
    + offset = `0` (optional, integer, `0`) ... Number of recipes to skip
    + limit = `20` (optional, integer, `30`) ... Number of recipes returned
    + sort = `name` (optional, string, `-created`) ... Sort method
    
        + Values
            + `created`
            + `-created`

+ Response 200

    [Actions Collection][]

+ Response 400

    Invalid sort option

## User Collection [/v1/public/users]
A collection of users.

+ Parameters

    + ids (optional, string, `101,102`) ... List of user IDs
    + names (optional, string, `daniel,kari`) ... List of usernames
    + offset = `0` (optional, integer, `0`) ... Number of recipes to skip
    + limit = `20` (optional, integer, `30`) ... Number of recipes returned
    + sort = `name` (optional, string, `-created`) ... Sort method
    
        + Values
            + `created`
            + `-created`
            + `name`
            + `-name`
            + `recipeCount`
            + `-recipeCount`
            + `location`
    
    + fromLong (optional, number, `-122.3`) ... Longitude to find nearby users when `sort` is `location`
    + fromLat (optional, number, `47.6`) ... Latitude to find nearby users when `sort` is `location`

+ Model

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            [
                {
                    "confirmed": true, 
                    "created": "2013-07-11T06:43:31.988Z", 
                    "following": [], 
                    "id": "51de54131084ffeef8000001", 
                    "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
                    "location": [
                        -122.331, 
                        47.61
                    ], 
                    "name": "daniel", 
                    "recipeCount": 0
                }, 
                {
                    "confirmed": false, 
                    "created": "2013-08-01T00:54:44.656Z", 
                    "following": [], 
                    "id": "51f9b1d45946118c34000001", 
                    "image": "https://plus.google.com/s2/photos/profile/117442582930902051362?sz=SIZE", 
                    "location": [
                        -122.331, 
                        47.61
                    ], 
                    "name": "daniel-taylor", 
                    "recipeCount": 0
                }
            ]

### Get users [GET]
Gets a list of users given the input parameters for filtering and sroting. An example call would look like this:

```no-highlight
https://api.malt.io/v1/public/users?limit=5
```

+ Response 200

    [User Collection][]

+ Response 400
    
    Invalid sort option

## Register new user [/v1/users]
Registers a new user account with a username and password. This user will not be able to use social authentication to log in.

### POST

+ Request

    + Headers

            Content-Type: application/json

    + Body

        {
            "email": "foo@bar.com",
            "name": "username",
            "image": "http://foo.com/bar.jpg?size=SIZE",
            "location": [-122.331, 47.61]
        }

+ Response 201 (application/json)

    + Body

        {
            "confirmed": false, 
            "created": "2013-11-01T00:54:44.656Z", 
            "following": [], 
            "id": "51f9b1d45946118c34000001", 
            "image": "http://foo.com/bar.jpg?size=SIZE", 
            "location": [
                -122.331, 
                47.61
            ], 
            "name": "username", 
            "recipeCount": 0
        }

+ Response 400

    Invalid username!

# Group Authentication
The API is split into two parts: the public API and the authenticated API. The public API requires no authentication and will list public information about users and recipes as well as providing converters and calculators.

The authenticated API, on the other hand, **requires** an OAuth bearer token in an HTTP authorization header. For example:

```http
Authorization: bearer 5262d64b892e8d4341000001
```

In order to get an authorization token, you must first register an application. Then, using your application token you request access on behalf of a user and are given an OAuth bearer token to use for subsequent requests.

## Registering an application
TODO

## Getting an OAuth token
To get an OAuth token for a user, you use a special URL. For example:

```no-highlight
https://api.malt.io/account/authorize?response_type=code&redirect_uri={website}&scope=user,recipe&client_id={client}&type=token
```

| Variable | Description                   | Example                           |
| -------- | ----------------------------- | --------------------------------- |
| website  | URL to your website's handler | http://beta.malt.io/auth/callback |
| client   | Your application token        | 51de552db0848b204b554089          |

If the user authorizes your application then the user is redirected to the `website` URL above, which the token in a hash value:

```no-highlight
http://your-website.com/auth/callback#access_token:5262d64b892e8d4341000001
```

Save this token and you can use it for all subsequent requests that require auth.

# Group Recipes
Authenticated calls to get, modify and delete recipes.

## Recipe Collection [/v1/recipes]
A collection of recipes.

### Get recipes [GET]

+ Parameters

    + ids (optional, string, `100,102,105`) ... List of recipe IDs
    + userIds (optional, string, `200,201,204`) ... List of recipe owner user IDs
    + slugs (optional, string, `test-recipe,hefeweizen`) ... List of recipe slugs to find in conjunction with `userIds`
    + offset = `0` (optional, integer, `0`) ... Number of recipes to skip
    + limit = `20` (optional, integer, `30`) ... Number of recipes returned
    + sort = `-created` (optional, string, `name`) ... Sort method
    
        + Values
            + `created`
            + `-created`
            + `name`
            + `-name`

    + detail = `false` (optional, boolean, `true`) ... Whether to show detailed info
    + private = `false` (optiona, boolean, `true`) ... If true, return private recipes of the requesting user. By default only return public recipes.

+ Response 200

    [Recipe Collection][]

### Create a new recipe [POST]

+ Parameters

    + private = `false` (optional, boolean, `true`) ... Make this recipe private
    + detail = `false` (optional, boolean, `true`) ... Return calculated recipe details
    + recipe (required, object, `{...}`) ... A JSON representation of a recipe

+ Request (application/json; charset=utf-8)

    {
        "detail": true,
        "recipe": {
            "name": "Recipe name",
            "description": "Recipe description",
            "fermentables": [
                {
                    "name": "Pale malt",
                    "weight": 3.5,
                    "yield": 0.75,
                    "color": 4.0
                }
            ]
        }
    }

+ Response 200 (application/json; charset=utf-8)

    {
        "created": "2013-11-02T17:25:51.275Z", 
        "data": {
            "agingDays": 14, 
            "agingTemp": 20, 
            "agingTempF": 68, 
            "author": "Anonymous Brewer", 
            "batchSize": 20, 
            "batchSizeGallons": 5.283440000000001, 
            "boilSize": 10, 
            "boilSizeGallons": 2.6417200000000003, 
            "bottlingPressure": 2.5, 
            "bottlingTemp": 23, 
            "bottlingTempF": 73.4, 
            "description": "Just a basic beer example for testing. foo this is a long description", 
            "fermentables": [
                {
                    "color": 6.096, 
                    "late": false, 
                    "name": "Extra pale extract", 
                    "weight": 4.5, 
                    "yield": 75
                }
            ], 
            "ibuMethod": "tinseth", 
            "mash": null, 
            "mashEfficiency": 75, 
            "name": "Another Beer 2", 
            "primaryDays": 14, 
            "primaryTemp": 20, 
            "primaryTempF": 68, 
            "secondaryDays": 0, 
            "secondaryTemp": 0, 
            "secondaryTempF": 32, 
            "servingSize": 0.355, 
            "servingSizeOz": 0.09378106, 
            "spices": [
                {
                    "aa": 4.5, 
                    "form": "pellet", 
                    "name": "Cascade hops", 
                    "time": 60, 
                    "use": "boil", 
                    "weight": 0.028349556839727483
                }
            ], 
            "steepEfficiency": 50, 
            "steepTime": 20, 
            "style": null, 
            "tertiaryDays": 0, 
            "tertiaryTemp": 0, 
            "tertiaryTempF": 32, 
            "yeast": [
                {
                    "attenuation": 74, 
                    "form": "liquid", 
                    "name": "Wyeast 3052", 
                    "type": "ale"
                }
            ]
        }, 
        "id": "5275359f031555931a000005", 
        "private": false, 
        "slug": "another-beer-2", 
        "user": {
            "id": "51de54131084ffeef8000001", 
            "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
            "name": "daniel"
        }
    }

## Recipe [/v1/recipes/{id}]
A single recipe.

+ Model

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

        {
            "created": "2013-11-02T17:25:51.275Z", 
            "data": {
                "agingDays": 14, 
                "agingTemp": 20, 
                "agingTempF": 68, 
                "author": "Anonymous Brewer", 
                "batchSize": 20, 
                "batchSizeGallons": 5.283440000000001, 
                "boilSize": 10, 
                "boilSizeGallons": 2.6417200000000003, 
                "bottlingPressure": 2.5, 
                "bottlingTemp": 23, 
                "bottlingTempF": 73.4, 
                "description": "Just a basic beer example for testing. foo this is a long description", 
                "fermentables": [
                    {
                        "color": 6.096, 
                        "late": false, 
                        "name": "Extra pale extract", 
                        "weight": 4.5, 
                        "yield": 75
                    }
                ], 
                "ibuMethod": "tinseth", 
                "mash": null, 
                "mashEfficiency": 75, 
                "name": "Another Beer 2", 
                "primaryDays": 14, 
                "primaryTemp": 20, 
                "primaryTempF": 68, 
                "secondaryDays": 0, 
                "secondaryTemp": 0, 
                "secondaryTempF": 32, 
                "servingSize": 0.355, 
                "servingSizeOz": 0.09378106, 
                "spices": [
                    {
                        "aa": 4.5, 
                        "form": "pellet", 
                        "name": "Cascade hops", 
                        "time": 60, 
                        "use": "boil", 
                        "weight": 0.028349556839727483
                    }
                ], 
                "steepEfficiency": 50, 
                "steepTime": 20, 
                "style": null, 
                "tertiaryDays": 0, 
                "tertiaryTemp": 0, 
                "tertiaryTempF": 32, 
                "yeast": [
                    {
                        "attenuation": 74, 
                        "form": "liquid", 
                        "name": "Wyeast 3052", 
                        "type": "ale"
                    }
                ]
            }, 
            "id": "5275359f031555931a000005", 
            "private": false, 
            "slug": "another-beer-2", 
            "user": {
                "id": "51de54131084ffeef8000001", 
                "image": "http://www.gravatar.com/avatar/f3ada405ce890b6f8204094deb12d8a8?s=SIZE&d=retro", 
                "name": "daniel"
            }
        }

### Get a recipe [GET]

+ Parameters

    + id (optional, string, `100`) ... Recipe ID
    + detail = `false` (optional, boolean, `true`) ... Whether to show detailed info
    + private = `false` (optional, boolean, `true`) ... If true, return private recipes of the requesting user. By default only return public recipes.

+ Response 200

    [Recipe][]

### Update a recipe [PUT]

+ Response 200

    [Recipe][]

### Delete a recipe [DELETE]

+ Response 204

# Group Users

## User Collection [/v1/users]

### Get users [GET]

## User [/v1/users/{id}]

### Get a recipe [GET]

### Update a recipe [PUT]

### Delete a recipe [DELETE]