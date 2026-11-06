# Decision semantics

An applicable grant must refer to the requested asset and satisfy **all** selected checks: confirmed, not revoked, as-of date inside its inclusive window, requested channel and market in its explicit scope, crop permitted when requested, and required attribution asserted present.

The complete grant is the unit of evaluation. Two grants that separately cover channel and market do not create a combined permission. With several applicable grants, lexical ID order makes selection reproducible. A failing alternative does not override a complete applicable grant. Grant-specific revocation is not automatically asset-wide revocation.

When none applies, the row status is `hold`. Its reasons are the sorted union of the failing checks across related grants; those reasons explain alternatives, not necessarily one single contract. `no_authored_grant` means no grant refers to that exact asset ID. The decision copies only the requested asset ID, fixed status/reasons and selected opaque grant ID; evidence/reviewer references, attribution and unknown fields are omitted.

Invalid metadata is a different state: `input_valid: false`, `selected_checks_pass: false`, `input_issue: invalid_request_or_grant_metadata`, empty assets. A malformed unrelated grant therefore also holds the request. Repair the metadata before interpreting individual assets.

Even a passing result means only `ready_for_editorial_review`. Review the original evidence, actual edited image and actual attribution. This software never certifies ownership, license validity, consent, trademarks, privacy, releases, legal eligibility or publication safety.
