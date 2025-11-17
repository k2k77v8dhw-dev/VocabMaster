# AWS API Specification for VocabMaster

This document specifies the REST API endpoints required for the AWS backend to work with the `AWSVocabularyProvider`.

## Base Configuration

```
Base URL: https://api.vocabmaster.com/v1
Authentication: API Key + JWT Bearer Token
Content-Type: application/json
```

## Authentication

All requests must include:
- Header: `X-API-Key: {your-api-key}`
- Header: `Authorization: Bearer {jwt-token}` (for user-specific data)

## Data Models

### VocabularyWord

```json
{
  "id": "uuid-string",
  "word": "string",
  "definition": "string",
  "example": "string",
  "pronunciation": "string or null",
  "language": "string or null (e.g., 'en', 'es')",
  "translationLanguage": "string or null",
  "categoryType": "string (business|travel|daily|academic)"
}
```

### AppSettings

```json
{
  "currentLanguage": "string (en|es|fr|de|ja|zh|ko|ar|ru|pt)",
  "lastSyncDate": "ISO 8601 date string or null",
  "userId": "string or null"
}
```

---

## API Endpoints

### 1. Words

#### Fetch Words by Category
```http
GET /api/v1/words?category={category}
```

**Query Parameters:**
- `category` (required): business | travel | daily | academic

**Response:**
```json
{
  "words": [
    {
      "id": "abc123",
      "word": "Negotiate",
      "definition": "To discuss terms",
      "example": "We need to negotiate.",
      "pronunciation": "/nɪˈɡoʊʃieɪt/",
      "language": "en",
      "translationLanguage": "en",
      "categoryType": "business"
    }
  ]
}
```

#### Fetch All Words
```http
GET /api/v1/words
```

**Response:**
```json
{
  "words": [...]
}
```

#### Fetch Single Word
```http
GET /api/v1/words/{id}
```

**Response:**
```json
{
  "id": "abc123",
  "word": "Negotiate",
  "definition": "...",
  ...
}
```

**Error Responses:**
- `404`: Word not found

#### Create Word
```http
POST /api/v1/words
```

**Request Body:**
```json
{
  "word": {
    "id": "abc123",
    "word": "Negotiate",
    "definition": "...",
    "example": "...",
    "pronunciation": "...",
    "language": "en",
    "translationLanguage": "en"
  },
  "category": "business"
}
```

**Response:**
```json
{
  "id": "abc123",
  "word": "Negotiate",
  ...
}
```

#### Bulk Create Words
```http
POST /api/v1/words/batch
```

**Request Body:**
```json
{
  "words": [
    {
      "id": "abc123",
      "word": "Negotiate",
      ...
    },
    {
      "id": "def456",
      "word": "Revenue",
      ...
    }
  ],
  "category": "business"
}
```

**Response:**
```json
{
  "words": [...]
}
```

#### Update Word
```http
PUT /api/v1/words/{id}
```

**Request Body:**
```json
{
  "id": "abc123",
  "word": "Updated Word",
  "definition": "...",
  ...
}
```

**Response:**
```json
{
  "id": "abc123",
  "word": "Updated Word",
  ...
}
```

#### Delete Word
```http
DELETE /api/v1/words/{id}
```

**Response:**
```json
{}
```

**Status:** `204 No Content`

#### Bulk Delete Words
```http
DELETE /api/v1/words/batch
```

**Request Body:**
```json
{
  "ids": ["abc123", "def456", "ghi789"]
}
```

**Response:**
```json
{}
```

#### Delete All Words in Category
```http
DELETE /api/v1/words?category={category}
```

**Response:**
```json
{}
```

---

### 2. Progress Tracking

#### Fetch All Completed Word IDs
```http
GET /api/v1/progress
```

**Response:**
```json
{
  "completedIds": ["abc123", "def456", "ghi789"]
}
```

#### Mark Word as Completed
```http
POST /api/v1/progress
```

**Request Body:**
```json
{
  "wordId": "abc123",
  "completedDate": "2025-01-15T10:30:00Z"
}
```

**Response:**
```json
{}
```

#### Mark Word as Incomplete
```http
DELETE /api/v1/progress/{wordId}
```

**Response:**
```json
{}
```

#### Check if Word is Completed
```http
GET /api/v1/progress/{wordId}
```

**Response:**
```json
{
  "completed": true
}
```

#### Get Progress Statistics
```http
GET /api/v1/progress/stats?category={category}&language={language}
```

**Query Parameters:**
- `category` (required): business | travel | daily | academic
- `language` (required): en | es | fr | de | ja | zh | ko | ar | ru | pt

**Response:**
```json
{
  "completed": 5,
  "total": 10
}
```

---

### 3. Settings

#### Get Settings
```http
GET /api/v1/settings
```

**Response:**
```json
{
  "currentLanguage": "en",
  "lastSyncDate": "2025-01-15T10:30:00Z",
  "userId": "user123"
}
```

#### Update Settings
```http
PUT /api/v1/settings
```

**Request Body:**
```json
{
  "currentLanguage": "es",
  "lastSyncDate": "2025-01-15T10:30:00Z",
  "userId": "user123"
}
```

**Response:**
```json
{
  "currentLanguage": "es",
  "lastSyncDate": "2025-01-15T10:30:00Z",
  "userId": "user123"
}
```

---

### 4. Batch Operations

#### Import Vocabulary
```http
POST /api/v1/import
```

**Request Body:**
```json
{
  "words": [
    {
      "id": "abc123",
      "word": "Negotiate",
      ...
    }
  ],
  "category": "business",
  "replaceExisting": true
}
```

**Response:**
```json
{}
```

#### Export Vocabulary
```http
GET /api/v1/export
```

**Response:**
```json
{
  "vocabulary": {
    "business": [
      {
        "id": "abc123",
        "word": "Negotiate",
        ...
      }
    ],
    "travel": [...],
    "daily": [...],
    "academic": [...]
  }
}
```

#### Reset All Data
```http
POST /api/v1/reset
```

**⚠️ Warning: This deletes all user data**

**Response:**
```json
{}
```

---

### 5. Sync Operations

#### Sync Data
```http
POST /api/v1/sync
```

**Request Body:**
```json
{
  "lastSyncDate": "2025-01-14T10:30:00Z"
}
```

**Response:**
```json
{
  "changes": {
    "newWords": [...],
    "updatedWords": [...],
    "deletedWordIds": [...],
    "progressUpdates": [...]
  },
  "syncDate": "2025-01-15T10:30:00Z"
}
```

---

## Error Responses

All error responses follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {}
  }
}
```

### Status Codes

- `200`: Success
- `201`: Created
- `204`: Success (No Content)
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `409`: Conflict
- `500`: Internal Server Error
- `503`: Service Unavailable

### Common Error Codes

```json
{
  "error": {
    "code": "INVALID_API_KEY",
    "message": "The provided API key is invalid"
  }
}
```

```json
{
  "error": {
    "code": "WORD_NOT_FOUND",
    "message": "Word with ID 'abc123' not found"
  }
}
```

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid data provided",
    "details": {
      "word": ["Word field is required"],
      "definition": ["Definition must be at least 10 characters"]
    }
  }
}
```

---

## AWS Implementation Example

### Using AWS API Gateway + Lambda + DynamoDB

#### 1. DynamoDB Tables

**Words Table:**
- Partition Key: `userId` (String)
- Sort Key: `id` (String)
- GSI: `category-index` (category, word)

**Progress Table:**
- Partition Key: `userId` (String)
- Sort Key: `wordId` (String)

**Settings Table:**
- Partition Key: `userId` (String)

#### 2. Lambda Functions

```
GET    /words                -> listWords Lambda
GET    /words/{id}          -> getWord Lambda
POST   /words               -> createWord Lambda
POST   /words/batch         -> batchCreateWords Lambda
PUT    /words/{id}          -> updateWord Lambda
DELETE /words/{id}          -> deleteWord Lambda
DELETE /words/batch         -> batchDeleteWords Lambda

GET    /progress            -> getProgress Lambda
POST   /progress            -> markCompleted Lambda
DELETE /progress/{id}       -> markIncomplete Lambda

GET    /settings            -> getSettings Lambda
PUT    /settings            -> updateSettings Lambda

POST   /import              -> importVocabulary Lambda
GET    /export              -> exportVocabulary Lambda
POST   /sync                -> syncData Lambda
```

#### 3. Example Lambda (TypeScript)

```typescript
// createWord Lambda
export const handler = async (event: APIGatewayEvent) => {
  const userId = event.requestContext.authorizer.claims.sub;
  const { word, category } = JSON.parse(event.body);
  
  const item = {
    userId,
    id: word.id,
    ...word,
    category,
    createdAt: new Date().toISOString()
  };
  
  await dynamodb.put({
    TableName: 'VocabMaster-Words',
    Item: item
  }).promise();
  
  return {
    statusCode: 201,
    body: JSON.stringify(item)
  };
};
```

#### 4. Authentication with Cognito

```typescript
// API Gateway Authorizer
const cognitoAuthorizer = {
  type: 'COGNITO_USER_POOLS',
  authorizerUri: userPool.providerARNs[0],
  identitySource: 'method.request.header.Authorization'
};
```

#### 5. API Gateway Configuration

```yaml
Resources:
  VocabMasterAPI:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: VocabMasterAPI
      
  WordsResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: !Ref VocabMasterAPI
      ParentId: !GetAtt VocabMasterAPI.RootResourceId
      PathPart: words
```

---

## Security Considerations

1. **API Key**: Used for rate limiting and basic authentication
2. **JWT Token**: User-specific authentication via AWS Cognito
3. **CORS**: Configure allowed origins
4. **Rate Limiting**: Implement per-user rate limits
5. **Input Validation**: Validate all inputs on server side
6. **Encryption**: Use HTTPS only, encrypt data at rest in DynamoDB

---

## Testing the API

### Using cURL

```bash
# Fetch words
curl -X GET "https://api.vocabmaster.com/v1/words?category=business" \
  -H "X-API-Key: your-api-key" \
  -H "Authorization: Bearer your-jwt-token"

# Create word
curl -X POST "https://api.vocabmaster.com/v1/words" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -H "Authorization: Bearer your-jwt-token" \
  -d '{
    "word": {
      "id": "new123",
      "word": "Test",
      "definition": "A test word",
      "example": "This is a test.",
      "language": "en"
    },
    "category": "business"
  }'
```

### Using Postman

Import the collection:
1. Create new collection "VocabMaster API"
2. Add environment variables:
   - `baseUrl`: https://api.vocabmaster.com/v1
   - `apiKey`: your-api-key
   - `authToken`: your-jwt-token
3. Set headers:
   - `X-API-Key`: {{apiKey}}
   - `Authorization`: Bearer {{authToken}}

---

## Cost Estimation (AWS)

**Monthly Costs (Estimate for 1000 active users):**

- API Gateway: ~$3.50 (1M requests)
- Lambda: ~$5 (100M GB-seconds)
- DynamoDB: ~$10 (25GB storage + read/write)
- Cognito: Free (< 50k users)
- **Total: ~$20-25/month**

**For 10k users:** ~$100-150/month

---

## Next Steps

1. Set up AWS account and services
2. Deploy Lambda functions
3. Configure API Gateway
4. Set up Cognito User Pool
5. Update `AWSVocabularyProvider` with your API URL
6. Test endpoints
7. Monitor and optimize
