package novasia.media_rights

import rego.v1

sample_asset := {"id": "photo-1", "cropped": false, "attribution_provided": true}
sample_grant := {"id": "grant-1", "asset_id": "photo-1", "evidence_ref": "evidence-1", "reviewer_ref": "reviewer-1", "confirmed": true, "revoked": false, "valid_from": "2026-01-01", "valid_until": "2026-12-31", "channels": ["web"], "markets": ["KH"], "allow_crop": false, "requires_attribution": true, "attribution": "Synthetic Studio"}
sample_request := {"schema_version": 1, "as_of": "2026-11-06", "channel": "web", "market": "KH", "assets": [sample_asset], "grants": [sample_grant]}

with_grant(patch) := object.union(sample_request, {"grants": [object.union(sample_grant, patch)]})
with_asset(patch) := object.union(sample_request, {"assets": [object.union(sample_asset, patch)]})

test_complete_grant_passes_selected_checks if { r := decision with input as sample_request; r.input_valid; r.selected_checks_pass; r.human_review_required }
test_no_grant_holds if { r := decision with input as object.union(sample_request, {"grants": []}); r.assets[0].reasons == ["no_authored_grant"] }
test_expired_holds if { r := decision with input as with_grant({"valid_until": "2026-11-05"}); r.assets[0].reasons == ["expired"] }
test_final_day_inclusive if { r := decision with input as with_grant({"valid_until": "2026-11-06"}); r.selected_checks_pass }
test_first_day_inclusive if { r := decision with input as with_grant({"valid_from": "2026-11-06"}); r.selected_checks_pass }
test_future_grant_holds if { r := decision with input as with_grant({"valid_from": "2026-11-07"}); r.assets[0].reasons == ["not_yet_valid"] }
test_revoked_holds if { r := decision with input as with_grant({"revoked": true}); r.assets[0].reasons == ["revoked"] }
test_unconfirmed_holds if { r := decision with input as with_grant({"confirmed": false}); r.assets[0].reasons == ["unconfirmed"] }
test_channel_must_match if { r := decision with input as object.union(sample_request, {"channel": "print"}); r.assets[0].reasons == ["channel_not_permitted"] }
test_market_must_match if { r := decision with input as object.union(sample_request, {"market": "TH"}); r.assets[0].reasons == ["market_not_permitted"] }
test_crop_permission_required if { r := decision with input as with_asset({"cropped": true}); r.assets[0].reasons == ["crop_not_permitted"] }
test_attribution_required if { r := decision with input as with_asset({"attribution_provided": false}); r.assets[0].reasons == ["attribution_missing"] }
test_no_attribution_required if { r := decision with input as object.union(with_grant({"requires_attribution": false, "attribution": ""}), {"assets": [object.union(sample_asset, {"attribution_provided": false})]}); r.selected_checks_pass }
test_multiple_reasons_sorted if { r := decision with input as with_grant({"confirmed": false, "revoked": true}); r.assets[0].reasons == ["revoked", "unconfirmed"] }
test_deterministic_grant_selection if { request := object.union(sample_request, {"grants": [object.union(sample_grant, {"id": "z"}), object.union(sample_grant, {"id": "a"})]}); r := decision with input as request; r.assets[0].selected_grant_id == "a" }
test_one_complete_grant_suffices if { request := object.union(sample_request, {"grants": [object.union(sample_grant, {"id": "bad", "revoked": true}), sample_grant]}); r := decision with input as request; r.selected_checks_pass }
test_other_assets_grant_not_used if { r := decision with input as with_grant({"asset_id": "other"}); r.assets[0].reasons == ["no_authored_grant"] }
test_empty_assets_invalid if { r := decision with input as object.union(sample_request, {"assets": []}); not r.input_valid; r.assets == []; not r.selected_checks_pass }
test_duplicate_assets_invalid if { r := decision with input as object.union(sample_request, {"assets": [sample_asset, sample_asset]}); not r.input_valid }
test_duplicate_grants_invalid if { r := decision with input as object.union(sample_request, {"grants": [sample_grant, sample_grant]}); not r.input_valid }
test_invalid_date_rejected if { r := decision with input as object.union(sample_request, {"as_of": "2026-02-30"}); not r.input_valid }
test_leap_day_2000_valid if { valid_date("2000-02-29") }
test_century_1900_not_leap if { not valid_date("1900-02-29") }
test_leap_day_2024_valid if { valid_date("2024-02-29") }
test_unpadded_date_invalid if { not valid_date("2026-1-01") }
test_reversed_grant_window_invalid if { r := decision with input as with_grant({"valid_from": "2027-01-01"}); not r.input_valid }
test_boolean_string_invalid if { r := decision with input as with_grant({"confirmed": "true"}); not r.input_valid }
test_empty_evidence_invalid if { r := decision with input as with_grant({"evidence_ref": ""}); not r.input_valid }
test_empty_reviewer_invalid if { r := decision with input as with_grant({"reviewer_ref": ""}); not r.input_valid }
test_blank_attribution_invalid if { r := decision with input as with_grant({"attribution": "  "}); not r.input_valid }
test_unknown_channel_invalid if { r := decision with input as object.union(sample_request, {"channel": "broadcast"}); not r.input_valid }
test_wildcard_not_inferred if { r := decision with input as with_grant({"markets": ["*"]}); not r.input_valid }
test_duplicate_scope_invalid if { r := decision with input as with_grant({"markets": ["KH", "KH"]}); not r.input_valid }
test_missing_field_invalid if { r := decision with input as object.remove(sample_request, {"market"}); not r.input_valid }
test_null_request_fixed_error if { r := decision with input as null; not r.input_valid; r.input_issue == "invalid_request_or_grant_metadata" }
test_private_fields_not_copied if { request := object.union(sample_request, {"private_notes": "SECRET_SENTINEL", "grants": [object.union(sample_grant, {"private_contract": "SECRET_SENTINEL"})]}); r := decision with input as request; not contains(json.marshal(r), "SECRET_SENTINEL") }
test_oversize_batch_invalid if { assets := [object.union(sample_asset, {"id": sprintf("photo-%d", [i])}) | some i in numbers.range(1, 501)]; r := decision with input as object.union(sample_request, {"assets": assets}); not r.input_valid }
test_no_external_builtins_needed if { r := decision with input as sample_request; r.assets[0].selected_grant_id == "grant-1" }
