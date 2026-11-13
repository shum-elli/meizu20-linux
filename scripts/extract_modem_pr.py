#!/usr/bin/env python3
"""Read only /image/modem_pr from the owner's original modem FAT image."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
from pyfatfs.PyFatFS import PyFatFS

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--modem-image', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists():
        parser.error('Output directory must not exist; choose a new directory.')
    records = []
    with PyFatFS(str(args.modem_image), read_only=True) as fs:
        paths = sorted(p for p in fs.walk.files() if p.startswith('/image/modem_pr/'))
        if not paths or '/image/modem_pr/so/521_0_0.mbn' not in paths:
            parser.error('Expected Meizu supplemental firmware was not found.')
        args.output.mkdir(parents=True)
        for name in paths:
            rel = PurePosixPath(name).relative_to('/image')
            if '..' in rel.parts or rel.is_absolute():
                raise ValueError('Unsafe firmware path')
            data = fs.readbytes(name)
            target = args.output.joinpath(*rel.parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            records.append(dict(path=str(rel), size=len(data), sha256=hashlib.sha256(data).hexdigest()))
    (args.output / 'manifest.json').write_text(json.dumps(records, indent=2) + '\n')
    print(f'Extracted {len(records)} supplemental firmware files; source image opened read-only.')

if __name__ == '__main__':
    main()
