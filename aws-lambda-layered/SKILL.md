---
name: aws-lambda-layered
description: >
  Patterns and conventions for creating AWS Lambda services following a layered Controller/Delegate/Service architecture.
  Trigger: When creating a new Lambda service or adding/modifying Controller, Delegate, or Service layers.
license: Apache-2.0
metadata:
  author: kanazawa-dev
  version: "1.0"
---

## When to Use

- Creating a new `{vendor}-{feature}-service` Lambda function
- Adding or modifying a Controller, Delegate, or Service class
- Debugging issues in the layered architecture
- Setting up local testing with `local.js` and `events.js`

## DEFAULT Pattern: Controller → Delegate → Service (3 layers)

This is the standard architecture for all new services. Use it unless the API integration
explicitly requires a simpler or specialized approach (see variants below).

### Project Structure

```
{vendor}-{feature}-service/
├── index.js                          # Lambda handler entry point (always identical)
├── config.js                         # Account-based static config
├── local.js                          # Local test runner
├── remote.js                         # Remote invocation handler
├── events.js                         # Test payloads
├── package.json
└── {feature}/
    ├── {Feature}Controller.js        # extends LambdaController
    ├── {Feature}Delegate.js          # extends Delegate
    └── {Feature}Service.js           # extends RestService or SOAPService
```

> **Note:** This skill assumes a shared internal commons package (e.g. `your-lambda-commons`)
> that exports `LambdaController`, `Delegate`, `RestService`, `SOAPService`, `HttpError`,
> `ConfigDAO`, and `Service`. Adapt the require paths to match your project's package name.

### Controller

Responsibilities: validate input (JSON Schema), instantiate Delegate, call `process()`.

```js
const LambdaController = require("your-lambda-commons").LambdaController;
const {Feature}Delegate = require("./{Feature}Delegate");

class {Feature}Controller extends LambdaController {
    constructor(lambdaContext, config, logLevel = "INFO") {
        super(lambdaContext, config, logLevel);
        this.useInputSchema(inputSchema);
        this.delegate = new {Feature}Delegate(lambdaContext, config, logLevel);
    }

    async process(request) {
        return await this.delegate.{doSomething}(request, this.getAccount());
    }
}

const inputSchema = {
    "type": "object",
    "properties": {
        // define fields and types here
    },
    "required": [/* required field names */]
}

module.exports = {Feature}Controller;
```

### Delegate

Responsibilities: fetch dynamic config via `ConfigDAO`, build the outgoing request,
invoke Service, process and map the response, throw `HttpError` on failures.

```js
const Delegate = require("your-lambda-commons").Delegate;
const {Feature}Service = require("./{Feature}Service.js");
const HttpError = require("your-lambda-commons").HttpError;
const ConfigDAO = require("your-lambda-commons").ConfigDAO;

class {Feature}Delegate extends Delegate {
    constructor(lambdaContext, config, logLevel = "INFO") {
        super(lambdaContext, config, logLevel);
        this.{feature}Service = new {Feature}Service(lambdaContext, config, logLevel);
        this.configDAO = new ConfigDAO(config, logLevel);
    }

    async {doSomething}(request, account) {
        const response = await this.call{Feature}(request, account);
        return this.processResponse(response);
    }

    async call{Feature}(request, account) {
        // fetch config to build auth headers, credentials, or extra params
        const config = await this.getConfiguration(account);
        const req = {
            data: { /* map request fields here */ },
            headers: { /* build auth headers from config if needed */ }
        };
        return await this.{feature}Service.execute(req);
    }

    async getConfiguration(account) {
        return await this.configDAO.getByFunctionNameAndEnviroment(
            "{vendor}-{feature}-service",   // MUST match the service folder name
            account
        );
    }

    processResponse(response) {
        // map vendor-specific response to a clean output shape
        // throw HttpError with the appropriate HTTP code on failure
        if (/* success condition */) {
            return { /* mapped output */ };
        } else {
            throw new HttpError(response.message, 500);
        }
    }
}

module.exports = {Feature}Delegate;
```

### Service

Responsibilities: configure the REST/SOAP connection name and error handlers.
Inject auth or signatures in `invokeService()` only when needed at the transport level.

```js
const RestService = require("your-lambda-commons").RestService;
const HttpError = require("your-lambda-commons").HttpError;

class {Feature}Service extends RestService {
    constructor(lambdaContext, config, logLevel = "INFO") {
        super(lambdaContext, config, logLevel);
        this.setName("{featureName}");    // MUST match the key under config.rest (or config.soap)
        this.setErrorHandler(500, this.errorHandler);
    }

    errorHandler(data) {
        throw new HttpError("Error processing request", 400, "Error processing request");
    }
}

module.exports = {Feature}Service;
```

---

## Shared Files (identical across all variants)

### index.js

```js
const config = require('./config.js');
const {Feature}Controller = require('./{feature}/{Feature}Controller.js');

exports.handler = async (event, context, callback) => {
    const controller = new {Feature}Controller(
        { event: event, context: context, callback: callback },
        { ...config },
        "INFO"
    );
    await controller.run();
}
```

### config.js — account-keyed

Only include the blocks that the service actually uses. If there's no `ConfigDAO`, omit `dao` entirely.

`000000000000` = local dev. When `dao` is present, include `endpoint` for local DynamoDB.
Production accounts never include `endpoint` in `dao`.

```js
// With ConfigDAO (e.g. when fetching credentials from a config table)
const config = {
    "000000000000": {
        dao: {
            Cache:  { config: { tableName: "your-cache-table",  region: "us-east-1", endpoint: "http://localhost:8000", timeout: 30000 } },
            Config: { config: { tableName: "your-config-table", region: "us-east-1", endpoint: "http://localhost:8000", timeout: 30000 } }
        },
        rest: { {featureName}: { service: { url: "...", api: "...", headers: {}, method: "POST", timeout: 30000, rejectUnauthorized: false } } }
    },
    "<PROD_ACCOUNT_1>": {
        dao: {
            Cache:  { config: { tableName: "your-cache-table",  region: "us-east-1" } },
            Config: { config: { tableName: "your-config-table", region: "us-east-1" } }
        },
        rest: { /* same as local */ }
    },
    "<PROD_ACCOUNT_2>": {
        dao: {
            Cache:  { config: { tableName: "your-cache-table",  region: "us-east-1" } },
            Config: { config: { tableName: "your-config-table", region: "us-east-1" } }
        },
        rest: { /* same as local */ }
    }
}

// Without ConfigDAO (e.g. Bearer token from request, no dynamic credentials)
const config = {
    "000000000000": {
        rest: { {featureName}: { service: { url: "...", api: "...", headers: {}, method: "GET", timeout: 30000, rejectUnauthorized: false } } }
    },
    "<PROD_ACCOUNT_1>": { rest: { /* same */ } },
    "<PROD_ACCOUNT_2>": { rest: { /* same */ } }
}

module.exports = config;
```

---

## Variants (when to deviate from the default)

### Variant A: Extra signature injection in Service

When the vendor requires a custom signature on every request, override `invokeService` in the Service.
Move `ConfigDAO` to the Service (not the Delegate) so it can access credentials at transport level.

```js
// Service only — rest of the pattern stays the same
const VendorHelper = require("your-lambda-commons").VendorHelper;
const ConfigDAO = require("your-lambda-commons").ConfigDAO;

constructor(...) {
    // ...
    this.configDAO = new ConfigDAO(config, logLevel);   // ConfigDAO HERE in Service, not Delegate
}

async invokeService(request) {
    let config = await this.getConfiguration(this.getAccount());
    request.params._ak = config.accessKey;
    request.params._signature = VendorHelper.calculateSignature(request, config);
    return super.invokeService(request);
}

async getConfiguration(account) {
    const conf = await this.configDAO.getByFunctionNameAndEnviroment("{vendor}-{feature}-service", account);
    return conf.config;
}
```

Request shape in Delegate when using signature injection:
```js
const req = {
    data: { sn: request.serialNumber, method: "get", params: {} },
    queryStringParameters: { "_ts": new Date().getTime() }
};
```

Response check pattern:
```js
if (response.code == 0) { return { /* map result */ }; }
else { throw new HttpError("code[" + response.code + "]: " + response.message, 500); }
```

### Variant B: Simple token — no Delegate, Controller calls Service directly

When auth is just a Bearer/token from the request payload and there's no config to fetch.

```js
// Controller process() — no delegate
async process(request) {
    const service = new {Feature}Service(this.getExecutionContext(), this.getConfig(), this.getLogLevel());
    return await service.execute({
        headers: { "x-auth-token": request.accessToken },
        data: { /* map fields */ }
    });
}
```

### Variant C: SOAP service

Replace `RestService` with `SOAPService`. Optionally hook `BEFORE_OUTPUT_EXECUTE` to parse XML.

```js
const SOAPService = require("your-lambda-commons").SOAPService;
const Service = require("your-lambda-commons").Service;

class {Feature}Service extends SOAPService {
    constructor(...) {
        super(...);
        this.setName("{featureName}");
        this.on(Service.EVENTS.BEFORE_OUTPUT_EXECUTE, this.postProcessor);
    }
    postProcessor(event, request) {
        return parsedResult; // transform XML → JSON here
    }
}
```

---

## useInputSchema — JSON Schema tips

```js
// String with minimum length
"fieldName": { "type": "string", "minLength": 1 }

// Enum with auto-transform
"status": { "type": "string", "enum": ["ACTIVE", "INACTIVE"], "transform": ["toUpperCase"] }

// Optional array
"groups": { "type": "array", "items": { "type": "string" } }
```

## Error handling conventions

| Scenario | HTTP code |
|----------|-----------|
| Remote service error (generic) | 500 |
| Business rule violation | 403 |
| Bad input / invalid data | 400 |
| Unauthorized credentials | 401 |
| Not found | 404 |

## Local Testing

```bash
node local.js 001          # named event from events.js
node local.js ./event.json # from file
node local.js              # empty event
```

`events.js` must cover: valid input, null field, missing required field, invalid format.

## Commands

```bash
npm install        # install dependencies
node local.js 001  # test locally
```
