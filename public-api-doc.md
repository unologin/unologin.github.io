# HTTP API (v1.unolog.in)

## General
If you are using [one of our SDKs](https://unolog.in/packages#sdks), follow the SKD's documentation first, as you will probably not need to directly interface with the HTTP-API.

The following examples will be using [curl](https://curl.se/) to be as general as possible. 

## Error handling

The API uses HTTP status codes for indicating whether a request was successful. Any ```2XX```-code indicates success, while any other code will indicate failure. 

Here's an exemplary failure:

```bash
$ curl -i 'https://v1.unolog.in/util/test-api-key'
```
Response:
```
HTTP/2 401 
```
```json
{"code":401,"msg":"no API-Key provided","data":null}
```
The failure response structure will always be the same: 
```typescript
{
  code: number,
  msg: string,
  data: any,
}
```
Note that the response code is duplicated in the body. 

## Authentication

To authenticate with the API, populate the ```X-API-KEY``` header with your API key in every request. You can obtain an API key in your app dashboard in the "API Access" tab.

The following examples may omit the API key for brevity. Be sure to **provide your API key with every request**.

You can make a request using any HTTP method (GET, POST, etc.) to ```/util/test-api-key``` to test the authentication:

```bash
$ curl "https://v1.unolog.in/util/test-api-key" \
    -H "X-API-KEY: ${UNOLOGIN_API_KEY}"
```

If everything is OK, the response will look like this:  

```json
{"appId":"your-app-id"}
```
Otherwise, you will get an error response. 

## General API

### Token verification 

To verify a login token through the API, use any of the following endpoints.


When authenticating users through the API, **any status code that is not ```200``` should be treated as failed authentication!** 

### Simple authentication

```bash
$ curl -X POST "https://v1.unolog.in/users/auth" \
    -H "X-API-KEY: ${UNOLOGIN_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{ \"user\": { \"appLoginToken\": \"${APP_LOGIN_TOKEN}\"  } }"
```

Successful response: 

```json
{
  "userClasses": [ "users_default" ],
  "asuId": "510d188417d34a000804c493",
  "r": 3600,
  "t": "alt",
  "iat": 1645002083,
  "exp": 1646211683
}
```

If the token is invalid, the API will return an error response, e. g.:

```json
{
  "code": 401,
  "msg": "jwt malformed",
  "data": { "param": "user" }
}
```

### Authentication with refresh

The following example is similar to the simple authentication above with the exception that it will also return a new login token. You may swap the users current token for the newly generated one to increase its lifespan.

```bash
$ curl -X POST "https://v1.unolog.in/users/refresh" \
    -H "X-API-KEY: ${UNOLOGIN_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{ \"user\": { \"appLoginToken\": \"${APP_LOGIN_TOKEN}\"  } }"
```
Response:
```json
[
  {
    "userClasses": [ "users_default" ],
    "asuId": "510d188417d34a000804c493",
    "r": 3600,
    "t": "alt",
    "iat": 1645002083,
    "exp": 1646211683
  },
  {
    "value":"XXXXXXXXXXXXX",
    "maxAge":86400000
  }
]
```

Note that the response body is now an array. The first element being the same response as before. The second element may be sent to the user (for example as a cookie). 

## REST API

Most of the API follows a REST-ful approach. More information about REST can be found [here](https://restfulapi.net/) or anywhere on the internet. 

### Schemas

The API uses JSON schemas in order to define and verify the shape of your requests. The documentation also includes response schemas that you can use to understand the shape of the response body. Each collection of resources may have three separate schemas associated with it (which are explained in the table below). 

| Schema  | Description |
| ------------- | ------------- |
| query  | This is the part after the ```?``` in the URL. JSON values are allowed but will need to be URL-encoded. Example: ```?foo={"bar": 1}``` becomes ```?foo=%7B%22bar%22%3A%201%7D```. Most browsers will do this automatically. Use ```--data-urlencode``` with curl. The query schema also includes path parameters such as ```/apps/:id``` |
| request body | Describes the JSON schema of the request body.   |
| response body  | Describes what is returned by the API in the response body when making a GET request to a single resource. When reading a collection of resources, the schema will look like this: ```{ results: ResponseSchema[], total: number }``` where each item in the `results` array will follow the response schema and `total` will contain the total amount of resources that match your query (as the length of results may be subject to a limit).   |

### Resource /apps/:appId/users

Query schema: [show query schema](https://v1.unolog.in/schemas/apps/:appId/users/query)

Response schema: [show response schema](https://v1.unolog.in/schemas/apps/:appId/users/read)


This resource represents all users that have signed up for your app through unolog.in. 

Each entry will come with a `profile` key, which is an object containing the information the user has decided to share during signup. Consult the response schema for more detailed information.

Supported methods: ```GET```.

Examples:

```bash
$ # to get a list of users as { results: User[], total: number }
$ curl -G "https://v1.unolog.in/apps/${APPID}/users"
$ # to get a specific user by their asuId
$ curl -G "https://v1.unolog.in/apps/${APPID}/users/${asuId}"
```

### Resource /public-keys

Hosts all public keys used by unolog.in. Right now, the only available key is ```app-login-token```. The returned public key can be used to verify login tokens without making an API call.

Please **do not cache any public key for longer than intended** as they are changed periodically. 

```bash
$ # this will produce a raw text response
$ # remove the "raw"-parameter to get a JSON response 
$ curl "https://v1.unolog.in/public-keys/app-login-token?raw=true"
```

Response:


```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArqY1C7KjzdVwXcAVcR8M
QQG2HLgydBqXru6KUR21mpmbB5ZrHW+b4fsJW7Qhzh9PFclB10GG33pv4Y/8aTpM
4E0xGhjZHUklOswFP77xJ5pCrc1cHIfOgobQYKqKc728fOrP0G9hyaRaAV85eBig
VHyIptkpyQP6aSUyVnW6d+NsSjIxcjx0rfWRor7ibKGgx4wX8cwrsPbksz2weODJ
4rHhtvjN2Zg6eVPy+Oa6AxxeNp9Go2Go3dci6JZTT2PUxaOdwuIbCPssxH/myR5y
D/PyaFvmmU5UHwOamE8CzChCaopU7HhjMp8FVh8/PpyJc0W49aYnKLc2WhXJzffQ
fQIDAQAB
-----END PUBLIC KEY-----
```


