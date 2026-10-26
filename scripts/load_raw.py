"""Download the UCI "Default of Credit Card Clients" dataset and land it in DuckDB.

Plays the role of the EL tool: the file is downloaded once (cached in data/raw/),
its SHA-256 is verified, and the sheet is written as-is to `raw.credit_card_clients`.
Column names are normalised to snake_case, as most EL tools do; no other cleaning
happens here - that is the job of the dbt staging layer.

Usage: python scripts/load_raw.py [--db data/banking.duckdb]
"""

import argparse
import csv
import hashlib
import io
import os
import re
import tempfile
import urllib.request
import zipfile
from pathlib import Path

import duckdb
import xlrd

URL = "https://archive.ics.uci.edu/static/public/350/default+of+credit+card+clients.zip"
SHA256 = "56c885f84457f6680f8438f02bfcdac9579323d8a94465ee5f26e32baa727602"
XLS_NAME = "default of credit card clients.xls"
CACHE = Path("data/raw/default_of_credit_card_clients.zip")


def fetch() -> bytes:
    if not CACHE.exists():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        print(f"Downloading {URL}")
        with urllib.request.urlopen(URL, timeout=120) as resp:
            CACHE.write_bytes(resp.read())
    blob = CACHE.read_bytes()
    digest = hashlib.sha256(blob).hexdigest()
    if digest != SHA256:
        CACHE.unlink()
        raise SystemExit(f"Checksum mismatch ({digest}); cached file removed, re-run to retry.")
    return blob


def to_csv(blob: bytes, out: Path) -> int:
    with zipfile.ZipFile(io.BytesIO(blob)) as zf:
        sheet = xlrd.open_workbook(file_contents=zf.read(XLS_NAME)).sheet_by_index(0)
    # Row 0 holds the X1..X23 codes, row 1 the real column names, data starts at row 2.
    header = [re.sub(r"\W+", "_", str(h).strip().lower()) for h in sheet.row_values(1)]
    with out.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        for i in range(2, sheet.nrows):
            writer.writerow(int(v) if isinstance(v, float) and v.is_integer() else v
                            for v in sheet.row_values(i))
    return sheet.nrows - 2


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--db", default=os.environ.get("DUCKDB_PATH", "data/banking.duckdb"))
    db = Path(parser.parse_args().db)
    db.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp:
        csv_path = Path(tmp) / "credit_card_clients.csv"
        rows = to_csv(fetch(), csv_path)
        with duckdb.connect(str(db)) as con:
            con.execute("create schema if not exists raw")
            con.execute(
                "create or replace table raw.credit_card_clients as "
                "select *, current_timestamp as _loaded_at from read_csv(?, header = true)",
                [str(csv_path)],
            )
            loaded = con.execute("select count(*) from raw.credit_card_clients").fetchone()[0]
    assert loaded == rows, f"expected {rows} rows, loaded {loaded}"
    print(f"Loaded {loaded} rows into {db} (raw.credit_card_clients)")


if __name__ == "__main__":
    main()
