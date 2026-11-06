package novasia.media_rights

import rego.v1

# Deliberately lexical IDs: no filenames, contacts or inferred identities.
valid_id(x) if { is_string(x); regex.match(`^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$`, x) }
valid_text(x) if { is_string(x); count(x) > 0; count(x) <= 500; trim_space(x) != "" }

leap(y) if { y % 400 == 0 }
leap(y) if { y % 4 == 0; y % 100 != 0 }
month_days(y, m) := 29 if { m == 2; leap(y) }
month_days(y, m) := 28 if { m == 2; not leap(y) }
month_days(_, m) := 30 if { m in {4, 6, 9, 11} }
month_days(_, m) := 31 if { m in {1, 3, 5, 7, 8, 10, 12} }
valid_date(x) if {
    is_string(x)
    regex.match(`^[0-9]{4}-[0-9]{2}-[0-9]{2}$`, x)
    y := to_number(substring(x, 0, 4))
    m := to_number(substring(x, 5, 2))
    d := to_number(substring(x, 8, 2))
    y >= 1900; y <= 2100
    m >= 1; m <= 12
    d >= 1; d <= month_days(y, m)
}

valid_labels(values) if {
    is_array(values); count(values) > 0; count(values) <= 20
    every v in values { valid_id(v) }
    count({v | some v in values}) == count(values)
}
valid_asset(a) if { is_object(a); valid_id(a.id); is_boolean(a.cropped); is_boolean(a.attribution_provided) }
valid_grant(g) if {
    is_object(g)
    valid_id(g.id); valid_id(g.asset_id)
    valid_id(g.evidence_ref); valid_id(g.reviewer_ref)
    is_boolean(g.confirmed); is_boolean(g.revoked)
    valid_date(g.valid_from); valid_date(g.valid_until)
    g.valid_from <= g.valid_until
    valid_labels(g.channels); every c in g.channels { c in {"web", "portal", "print", "social"} }
    valid_labels(g.markets)
    is_boolean(g.allow_crop); is_boolean(g.requires_attribution)
    is_string(g.attribution); count(g.attribution) <= 500
    attribution_consistent(g)
}
attribution_consistent(g) if { g.requires_attribution == false }
attribution_consistent(g) if { g.requires_attribution == true; valid_text(g.attribution) }

default input_valid := false
input_valid if {
    is_object(input); input.schema_version == 1
    valid_date(input.as_of)
    input.channel in {"web", "portal", "print", "social"}
    valid_id(input.market)
    is_array(input.assets); count(input.assets) > 0; count(input.assets) <= 500
    every a in input.assets { valid_asset(a) }
    count({a.id | some a in input.assets}) == count(input.assets)
    is_array(input.grants); count(input.grants) <= 1000
    every g in input.grants { valid_grant(g) }
    count({g.id | some g in input.grants}) == count(input.grants)
}
