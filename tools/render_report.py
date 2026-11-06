"""Render the raw decision JSON from `opa eval --format raw` as local escaped HTML."""
from html import escape
import json
from pathlib import Path
import sys


def render(result):
    e = lambda value: escape(str(value), quote=True)
    rows = ''.join('<tr>' + ''.join('<td>' + e(x) + '</td>' for x in (
        row['asset_id'], row['status'], row['selected_grant_id'] or '—', ', '.join(row['reasons']) or 'No selected flags'
    )) + '</tr>' for row in result['assets'])
    status = 'SELECTED CHECKS PASS' if result['selected_checks_pass'] else 'HOLD FOR REVIEW'
    return f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Property Media Rights Gate</title><style>body{{margin:0;background:#eff4f1;color:#173d3a;font:16px/1.6 system-ui}}main{{max-width:1100px;margin:auto;padding:40px 24px}}nav{{display:flex;justify-content:space-between;font-size:12px;letter-spacing:.08em}}a{{color:#176c64}}h1{{font-size:clamp(38px,6vw,70px);line-height:1.1;letter-spacing:-.05em;margin:50px 0 24px}}.status{{background:#fff0da;border-left:5px solid #ba7439;padding:20px}}.scroll{{overflow:auto;margin-top:30px}}table{{border-collapse:collapse;background:white;width:100%;font-size:14px}}td,th{{padding:18px;text-align:left;border-bottom:1px solid #dbe6e0}}td{{overflow-wrap:anywhere}}footer{{margin-top:36px;font-size:12px;color:#526e68}}</style><body><main>
<nav><span>RELEASE OPERATIONS / AUTHORED MEDIA GRANTS</span><a href="https://novasia.estate/">NovAsia Estate</a></nav>
<h1>Property Media<br>Rights Gate.</h1><section class="status"><b>{status}</b><br>Human review required. This is a metadata workflow decision, not a legal authorization.</section>
<p>Input valid: {e(result['input_valid'])}. Input issue: {e(result['input_issue'] or 'None')}.</p>
<div class="scroll"><table><thead><tr><th>Asset</th><th>Decision</th><th>Selected grant</th><th>Review reasons</th></tr></thead><tbody>{rows}</tbody></table></div>
<footer>Original media, contract text, reviewer references and attribution values are omitted. Read the authored evidence before release.<br>Developed by <a href="https://novasia.estate/">NovAsia Estate</a> · MIT · Offline report</footer></main></body></html>'''


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: python tools/render_report.py decision.json new-report.html')
    source, output = map(Path, sys.argv[1:])
    if source.stat().st_size > 2_000_000:
        raise SystemExit('Decision exceeds report size limit.')
    result = json.loads(source.read_text(encoding='utf-8-sig'))
    with output.open('x', encoding='utf-8', newline='\n') as target:
        target.write(render(result))
