package novasia.media_rights

import rego.v1

reason_codes := ["unconfirmed", "revoked", "not_yet_valid", "expired", "channel_not_permitted", "market_not_permitted", "crop_not_permitted", "attribution_missing"]

bad(g, _, "unconfirmed") if { g.confirmed == false }
bad(g, _, "revoked") if { g.revoked == true }
bad(g, _, "not_yet_valid") if { g.valid_from > input.as_of }
bad(g, _, "expired") if { g.valid_until < input.as_of }
bad(g, _, "channel_not_permitted") if { not input.channel in g.channels }
bad(g, _, "market_not_permitted") if { not input.market in g.markets }
bad(g, a, "crop_not_permitted") if { a.cropped; g.allow_crop == false }
bad(g, a, "attribution_missing") if { g.requires_attribution; a.attribution_provided == false }

grant_reasons(g, a) := [code | some code in reason_codes; bad(g, a, code)]
usable_grants(a) := sort([g.id | some g in input.grants; g.asset_id == a.id; count(grant_reasons(g, a)) == 0])

asset_decision(a) := {
    "asset_id": a.id, "status": "ready_for_editorial_review",
    "selected_grant_id": usable_grants(a)[0], "reasons": [],
} if { count(usable_grants(a)) > 0 }

asset_decision(a) := {
    "asset_id": a.id, "status": "hold", "selected_grant_id": null,
    "reasons": sort({code | some g in input.grants; g.asset_id == a.id; some code in grant_reasons(g, a)}),
} if { count(usable_grants(a)) == 0; some g in input.grants; g.asset_id == a.id }

asset_decision(a) := {
    "asset_id": a.id, "status": "hold", "selected_grant_id": null,
    "reasons": ["no_authored_grant"],
} if { not some_grant(a.id) }

some_grant(id) if { some g in input.grants; g.asset_id == id }

rows := [asset_decision(a) | some a in input.assets] if { input_valid }
rows := [] if { not input_valid }

default selected_checks_pass := false
selected_checks_pass if {
    input_valid
    every row in rows { row.status == "ready_for_editorial_review" }
}

# This value never authorizes use legally; it is an authored-metadata workflow gate.
decision := {
    "schema_version": 1,
    "input_valid": input_valid,
    "selected_checks_pass": selected_checks_pass,
    "human_review_required": true,
    "input_issue": input_issue,
    "assets": rows,
}
input_issue := null if { input_valid }
input_issue := "invalid_request_or_grant_metadata" if { not input_valid }
