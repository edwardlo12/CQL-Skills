library "08111B" version '0.0.1'

using FHIR version '4.0.1'

include "FHIRHelpers" version '4.0.1' called FHIRHelpers
include "CDSConnectCommonsForFHIRv401" version '2.0.0' called C3F

context Patient

// CodeSystems
codesystem "ICD-10-CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "LOINC": 'http://loinc.org'
codesystem "SCT": 'http://snomed.info/sct'

// ValueSets
valueset "凝血異常 valueset": 'https://example.org/fhir/ValueSet/coagulation-disorder'
valueset "懷孕 valueset": 'https://example.org/fhir/ValueSet/pregnancy'

// Codes
code "血小板數量": '777-3' from "LOINC" display 'Platelets [#/volume] in Blood'
code "兒科專科醫師": '24251000087109' from "SCT" display 'Pediatric specialty'

// Indications
define "凝血異常":
  exists ( C3F.Confirmed([Condition: "凝血異常 valueset"]) )

define "適應症":
  "凝血異常"

// Contraindications
define "懷孕":
  exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )

// Age restriction
define "年齡符合":
  AgeInYears() >= 6 and AgeInYears() < 13

// Specialty restriction
define "專科符合":
  exists (
    [Practitioner] P
      where exists (
        P.qualification Q
          where Q.code ~ "兒科專科醫師"
      )
  )

// Frequency limit
define "過去一年執行次數":
  Count(
    C3F.ObservationLookBack(
      [Observation: code in "血小板數量"],
      1 year
    )
  )

define "頻率符合":
  "過去一年執行次數" < 3

// Lab value condition
define "血小板過低":
  exists (
    [Observation: "血小板數量"] O
      where C3F.QuantityValue(O) < 50000 '/uL'
        and O.status in {'final', 'corrected', 'amended'}
  )

// Main inclusion criteria
define "MeetsInclusionCriteria":
  "適應症"
    and not "懷孕"
    and "年齡符合"
    and "專科符合"
    and "頻率符合"
    and "血小板過低"

define "InPopulation":
  "MeetsInclusionCriteria"

define "Recommendation":
  if "InPopulation"
    then '建議給付 800 點。注意：需事先申請核准。'
    else null

define "Rationale":
  null

define "Links":
  null

define "Suggestions":
  null

define "Errors":
  null
