# Scope and limitations

This pack checks authored permission metadata, not the truth or completeness of the underlying rights. It has no license catalogue and does not translate a license name into permission. An evidence reference is not proof that a valid document exists. Revocation/expiry entries must be maintained by the owner; the pack never contacts an author or rights holder.

There is no visual image inspection, PDF inspection, metadata extraction, GPS processing or automatic attribution insertion. The crop and attribution-present booleans are caller assertions. Channel, territory, exclusivity, consent, rights transfers, source authenticity and legal interpretations require separate evidence review.

Only the explicit date/channel/market/crop/attribution dimensions are modeled. A grant may have other restrictions not represented in this schema. Do not enter it as confirmed until the responsible person has determined that this model covers the intended use. If requirements cannot be represented, hold the asset outside this tool.

The policy's collection limits are application-level validation, not a JSON parser sandbox. Configure byte/time/memory limits in the caller for untrusted input. Reports deliberately omit free-text grant content but still contain opaque asset/grant IDs; do not assume anonymity.

Implementation references: official [Rego language](https://www.openpolicyagent.org/docs/policy-language), [OPA policy tests](https://www.openpolicyagent.org/docs/policy-testing) and [Artifact Hub OPA repository format](https://artifacthub.io/docs/topics/repositories/opa-policies/). This is an independent NovAsia project, not an official OPA or CNCF policy pack.
