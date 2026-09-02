"""Export website reading data from the grade 5 and 6 LaTeX teaching plans.

Run after editing a plan: python3 scripts/export_stem_plan_reading.py
Recompile its PDF with XeLaTeX twice separately. The LaTeX source stays out
of pubspec.yaml so it is not included in the published website.
This parser intentionally supports only the current teaching-plan template.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'src/data'


def plain(value):
    value = value.replace(r'\newpage', '').replace(r'\times', ' × ')
    value = value.replace(r'\par', '\n').replace('{,}', ',')
    value = re.sub(r'\$(.*?)\$', r'\1', value)
    value = re.sub(r'\\textbf\{([^{}]*)\}', r'\1', value)
    value = value.replace('--', '–').strip()
    if re.search(r'[\\{}$]', value):
        raise ValueError(f'Unsupported LaTeX in reading text: {value}')
    return value


def export(total, grade=5):
    directory = ROOT / f'{grade}_diagnostic'
    stem = f'stem_{grade}_plan_{total}_hours'
    source = (directory / f'{stem}.tex').read_text()
    parts = re.split(r'\\section\*\{([^}]+)\}', source)
    sections = []
    weeks = []
    for title, body in zip(parts[1::2], parts[2::2]):
        if 'longtable' in body:
            entries = []
            for line in body.splitlines():
                if not re.match(r'^\d+ / ', line):
                    continue
                cells = [cell.strip() for cell in line.split(r'\\')[0].split('&')]
                assert len(cells) == 6
                number, hours = cells[0].split(' / ')
                module, topic = cells[2].split(r'\par ', 1)
                entry = dict(week=int(number), hours=hours, module=plain(module),
                             topic=plain(topic), pages=plain(cells[3]),
                             activity=plain(cells[4]), outcome=plain(cells[5]))
                if grade == 6:
                    entry['referenceLabel'] = 'Програма'
                entries.append(entry)
                weeks.append(entry)
            sections.append(dict(title=title, weeks=entries))
        elif 'tabular' in body:
            rows = []
            for line in body.splitlines():
                if ' & ' in line and r'\toprule' not in line:
                    cells = line.replace(r'\midrule ', '').split(r'\\')[0].split(' & ')
                    assert len(cells) == 4
                    rows.append([plain(cell) for cell in cells])
            assert len(rows) == 8
            sections.append(dict(title=title, rows=rows))
        else:
            sections.append(dict(title=title, text=plain(body)))
    assert [w['week'] for w in weeks] == list(range(1, 33))
    assert sum(float(w['hours'].replace(',', '.')) for w in weeks) == total
    assert len(sections[-2]['weeks']) == 15
    assert len(sections[-1]['weeks']) == 17
    (directory / f'{stem}.json').write_text(
        json.dumps(dict(sections=sections), ensure_ascii=False, indent=2) + '\n'
    )


if __name__ == '__main__':
    for grade in (5, 6):
        for total in (32, 48):
            export(total, grade)
