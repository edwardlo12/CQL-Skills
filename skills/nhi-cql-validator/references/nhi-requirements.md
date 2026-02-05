# NHI Compliance Requirements

## Required Define Statements

All NHI CQL files MUST include these define statements:

```cql
define "MeetsInclusionCriteria": [logic]
define "InPopulation": "MeetsInclusionCriteria"
define "Recommendation": [string or null]
define "Rationale": [string or null]
define "Links": null
define "Suggestions": null
define "Errors": null
```

### Define Statement Purposes

- **MeetsInclusionCriteria**: Main inclusion logic combining all conditions
- **InPopulation**: References MeetsInclusionCriteria (required for CDS Hooks)
- **Recommendation**: Payment recommendation including point value
- **Rationale**: Explanation (can be null)
- **Links**: External references (typically null)
- **Suggestions**: Additional suggestions (typically null)
- **Errors**: Error messages (typically null)

## Approved CodeSystem URLs

Only these 8 CodeSystems are approved for NHI CQL:

```cql
codesystem "ICD-10-CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "ICD-10-PCS": 'http://www.cms.gov/Medicare/Coding/ICD10'
codesystem "LOINC": 'http://loinc.org'
codesystem "SCT": 'http://snomed.info/sct'
codesystem "TWMedicalServicePayment": 'https://twcore.mohw.gov.tw/ig/twcore/CodeSystem/medical-service-payment-tw'
codesystem "CONDVERSTATUS": 'http://terminology.hl7.org/CodeSystem/condition-ver-status'
codesystem "CONDCLINSTATUS": 'http://terminology.hl7.org/CodeSystem/condition-clinical'
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
```

**Validation:** Flag any CodeSystem URL not in this list as an error.

## Required CQL Headers

Every NHI CQL file must start with:

```cql
library "[規則編號]" version '0.0.1'

using FHIR version '4.0.1'

include "FHIRHelpers" version '4.0.1' called FHIRHelpers
include "CDSConnectCommonsForFHIRv401" version '2.0.0' called C3F

context Patient
```

**Version requirements:**
- FHIR version: exactly `'4.0.1'`
- FHIRHelpers version: exactly `'4.0.1'`
- C3F version: exactly `'2.0.0'`

## Format Requirements

**Indentation:** 2 spaces (not tabs)
- Check for tab characters and flag as warning

**String quotes:** Single quotes `'...'` (not double quotes `"..."`)
- Check all string literals

**Library name:** Must match NHI rule number
- When rules provided, verify library name matches rule number

## C3F Function Usage

Prefer using C3F library functions over custom implementations:

**Common C3F functions:**
- `C3F.Confirmed([Condition: ...])` - Get confirmed conditions
- `C3F.Verified([Observation: ...])` - Get verified observations
- `C3F.QuantityValue(observation)` - Extract quantity value
- `C3F.ObservationLookBack(observations, lookbackPeriod)` - Filter by time

**Flag as warning:** Redundant definitions of these functions (should use C3F directly)

## ValueSet JSON Required Structure

```json
{
  "resourceType": "ValueSet",
  "id": "[ID in FHIR format]",
  "meta": {
    "versionId": "1",
    "lastUpdated": "YYYY-MM-DDTHH:MM:SS.sssZ",
    "profile": [...]
  },
  "url": "[ValueSet URL with http:// not https://]",
  "identifier": [...],
  "version": "YYYYMMDD",
  "name": "[Name]",
  "title": "[Title]",
  "status": "active",
  "publisher": "[Publisher]",
  "purpose": "(Clinical Focus: ...),(Data Element Scope: ...),(Inclusion Criteria: ...),(Exclusion Criteria: ...)",
  "compose": {
    "include": [...]
  }
}
```

**ID format:**
- ⚠️ Warning (not error) if not OID format `2.16.840.1.113762.1.4.1287.[number]`
- ✅ Pass if valid FHIR id format

**Purpose format:** Must follow pattern `(Key: value),(Key: value),...`

## Filter Operator Guidelines

Choose appropriate filter operators based on code length:

| Code pattern | Recommended operator | Use case |
|--------------|---------------------|----------|
| 3-4 digits   | `descendent-of`     | Include all descendants |
| 4-5 digits   | `is-a`              | Include code and descendants |
| 6+ digits    | `=`                 | Exact match only |
| Multiple unrelated | `in`          | Explicit list |

**Flag as warning:** Potentially incorrect operator choice (e.g., using `=` for 3-digit codes)

## Cross-Validation Rules

**CQL vs ValueSet URL matching:**
- CQL valueset declarations use `https://`
- ValueSet JSON url field uses `http://`
- **This difference is CORRECT** - do not flag as error
- Example:
  ```cql
  // In CQL
  valueset "糖尿病 valueset": 'https://example.org/fhir/ValueSet/diabetes'
  ```
  ```json
  // In ValueSet JSON
  "url": "http://example.org/fhir/ValueSet/diabetes"
  ```

**Dependency file checks:**
- `FHIRHelpers.cql` must exist in same directory
- `CDSConnectCommonsForFHIRv401.cql` must exist in same directory

## Version Consistency

All version references must be consistent:
- Check FHIR version matches across includes
- Check library versions match across files
