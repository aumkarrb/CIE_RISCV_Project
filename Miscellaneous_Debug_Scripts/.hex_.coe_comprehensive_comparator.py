#!/usr/bin/env python3
"""
hexcoe_compare.py   — HEX/COE comparison utility

Added 2025-07-24
• Supports multiple *.hex* dialects: Intel-HEX, S-Record, TI-TXT,
  raw ASCII-hex (contiguous), and autodetects the right loader.
"""

import argparse, logging, os, re, sys
from collections import defaultdict
from typing import Dict, List, Tuple

LOG = logging.getLogger("hexcoe_compare")
_hex_line_re = re.compile(r"^:([0-9A-Fa-f]{2})([0-9A-Fa-f]{4})([0-9A-Fa-f]{2})"
                          r"([0-9A-Fa-f]*)([0-9A-Fa-f]{2})$")

# ---------------------------------------------------------------------------
# Helper ─────────────────────────────────────────────────────────────────────
# ---------------------------------------------------------------------------
def _ihex_checksum(vals: List[int]) -> int:
    return ((~sum(vals) + 1) & 0xFF)


def _one_complement(vals: List[int]) -> int:
    return ((~sum(vals)) & 0xFF)


def _human(n: int) -> str:
    for u in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.0f}{u}"
        n /= 1024
    return f"{n:.1f}TB"


# ---------------------------------------------------------------------------
# Intel HEX ──────────────────────────────────────────────────────────────────
# ---------------------------------------------------------------------------
def _load_ihex(fh, start=0, length=None) -> Dict[int, int]:
    data, high_addr = {}, 0
    for ln, line in enumerate(fh, 1):
        line = line.strip()
        if not line:
            continue
        m = _hex_line_re.match(line)
        if not m:
            raise ValueError(f"line {ln}: malformed Intel-HEX")
        bc, addr, rtype, payload, cks = (int(m.group(1), 16),
                                         int(m.group(2), 16),
                                         int(m.group(3), 16),
                                         bytes.fromhex(m.group(4)),
                                         int(m.group(5), 16))
        if _ihex_checksum([bc, addr >> 8, addr & 0xFF, rtype, *payload]) != cks:
            raise ValueError(f"line {ln}: bad checksum")
        if rtype == 0x00:                              # data
            abs_addr = (high_addr << 16) | addr
            for b in payload:
                if length and not (start <= abs_addr < start + length):
                    abs_addr += 1
                    continue
                data[abs_addr] = b
                abs_addr += 1
        elif rtype == 0x01:                            # EOF
            break
        elif rtype == 0x02:                            # extended segment
            high_addr = ((payload[0] << 8) | payload[1]) << 4
        elif rtype == 0x04:                            # extended linear
            high_addr = (payload[0] << 8) | payload[1]
        else:                                          # 03,05 etc – ignore
            pass
    return data


# ---------------------------------------------------------------------------
# Motorola S-Record ──────────────────────────────────────────────────────────
# ---------------------------------------------------------------------------
_srec_re = re.compile(r"^S([0-9])([0-9A-Fa-f]{2})([0-9A-Fa-f]+)$")


def _load_srec(fh, start=0, length=None) -> Dict[int, int]:
    data = {}
    for ln, line in enumerate(fh, 1):
        line = line.strip()
        if not line:
            continue
        m = _srec_re.match(line)
        if not m:
            raise ValueError(f"line {ln}: malformed S-record")
        stype, count_hex, rest = m.groups()
        count = int(count_hex, 16)
        bytes_all = [int(rest[i : i + 2], 16) for i in range(0, len(rest), 2)]
        if len(bytes_all) != count:
            raise ValueError(f"line {ln}: length mismatch")
        checksum = bytes_all[-1]
        calc = _one_complement(bytes_all[:-1])
        if calc != checksum:
            raise ValueError(f"line {ln}: bad checksum")
        if stype in "123":
            addr_len = {"1": 2, "2": 3, "3": 4}[stype]
            addr_bytes = bytes_all[:addr_len]
            addr = 0
            for b in addr_bytes:
                addr = (addr << 8) | b
            for b in bytes_all[addr_len:-1]:
                if length and not (start <= addr < start + length):
                    addr += 1
                    continue
                data[addr] = b
                addr += 1
        elif stype in "789":        # termination records – ignore
            break
    return data


# ---------------------------------------------------------------------------
# TI-TXT (@ addr … Q) ────────────────────────────────────────────────────────
# ---------------------------------------------------------------------------
def _load_titxt(fh, start=0, length=None) -> Dict[int, int]:
    data, cur = {}, 0
    for ln, line in enumerate(fh, 1):
        line = line.strip()
        if not line or line.startswith("q") or line.startswith("Q"):
            break
        if line.startswith("@"):
            cur = int(line[1:], 16)
            continue
        for token in re.split(r"[,\s]+", line):
            if not token:
                continue
            val = int(token, 16)
            if length and not (start <= cur < start + length):
                cur += 1
                continue
            data[cur] = val
            cur += 1
    return data


# ---------------------------------------------------------------------------
# Plain (contiguous) ASCII-hex ───────────────────────────────────────────────
# ---------------------------------------------------------------------------
def _load_raw_hex(fh, start=0, length=None) -> Dict[int, int]:
    hexchars = re.sub(r"[^0-9A-Fa-f]", "", fh.read())
    if len(hexchars) % 2:
        raise ValueError("odd number of hex digits in raw file")
    data, addr = {}, 0
    for i in range(0, len(hexchars), 2):
        if length and not (start <= addr < start + length):
            addr += 1
            continue
        data[addr] = int(hexchars[i : i + 2], 16)
        addr += 1
    return data


# ---------------------------------------------------------------------------
# Stubs for other HEX flavours (easy hook-ins) ───────────────────────────────
# ---------------------------------------------------------------------------
def _load_tektronix(*a, **k):
    raise NotImplementedError("Tektronix HEX loader not yet implemented")

def _load_mos(*a, **k):
    raise NotImplementedError("MOS Technology papertape HEX loader not yet implemented")


# ---------------------------------------------------------------------------
# Dispatcher / autodetect ———————————————————————————————————————————————
# ---------------------------------------------------------------------------
def _detect_hex_flavour(first_line: str) -> str:
    if first_line.startswith(":"):
        return "ihex"
    if first_line.startswith("S"):
        return "srec"
    if first_line.startswith("@"):
        return "titxt"
    if first_line[:1] in "/%":
        return "tek"
    if first_line.startswith(";"):
        return "mos"
    return "raw"


def load_hex_generic(path, start=0, length=None) -> Dict[int, int]:
    with open(path, "r", encoding="ascii", errors="ignore") as fh:
        # peek first non-blank line
        for first in fh:
            first = first.strip()
            if first:
                flavour = _detect_hex_flavour(first)
                fh.seek(0)
                break
        else:
            raise ValueError("empty file")
        loader = {
            "ihex": _load_ihex,
            "srec": _load_srec,
            "titxt": _load_titxt,
            "raw": _load_raw_hex,
            "tek": _load_tektronix,
            "mos": _load_mos,
        }[flavour]
        LOG.debug("Detected %s format in %s", flavour.upper(), path)
        return loader(fh, start, length)


# ---------------------------------------------------------------------------
# Xilinx COE loader (unchanged) ──────────────────────────────────────────────
# ---------------------------------------------------------------------------
def load_coe(path, start=0, length=None) -> Dict[int, int]:
    radix, vec_tokens = 16, []
    with open(path, "r", encoding="utf-8", errors="ignore") as fh:
        for line in fh:
            line = line.split(";", 1)[0].strip()
            if not line:
                continue
            if "=" in line:
                key, val = [p.strip() for p in line.split("=", 1)]
                k = key.lower()
                if k in ("radix", "memory_initialization_radix"):
                    radix = int(val.rstrip(";"), 0)
                elif k in ("coefdata", "memory_initialization_vector"):
                    vec_tokens.append(val)
                    if ";" not in val:
                        for cont in fh:
                            cont = cont.split(";", 1)[0]
                            vec_tokens.append(cont)
                            if ";" in cont:
                                break
    raw = " ".join(vec_tokens).replace(";", " ")
    entries = [t for t in re.split(r"[,\s]+", raw) if t]
    data, addr = {}, 0
    for tok in entries:
        val = int(tok, radix)
        if length and not (start <= addr < start + length):
            addr += 1
            continue
        data[addr] = val & 0xFF
        addr += 1
    return data


# ---------------------------------------------------------------------------
# Comparison & CLI (unchanged except for new loader) ────────────────────────
# ---------------------------------------------------------------------------
def _compare(a: Dict[int, int], b: Dict[int, int]):
    addrs = sorted(set(a) | set(b))
    mism, samples = 0, []
    for addr in addrs:
        if a.get(addr) != b.get(addr):
            mism += 1
            if len(samples) < 10:
                samples.append((addr, a.get(addr), b.get(addr)))
    return len(addrs), mism, samples


def _parse_cli():
    p = argparse.ArgumentParser(description="Compare HEX/SREC/COE files")
    p.add_argument("file1"), p.add_argument("file2")
    p.add_argument("--start", type=lambda x: int(x, 0))
    p.add_argument("--length", type=lambda x: int(x, 0))
    p.add_argument("--loglevel", default="INFO")
    return p.parse_args()


def main():
    args = _parse_cli()
    logging.basicConfig(level=getattr(logging, args.loglevel.upper(), logging.INFO),
                        format="%(levelname)s | %(message)s", stream=sys.stderr)
    try:
        data1 = (load_coe if args.file1.lower().endswith(".coe") else load_hex_generic)(
            args.file1, args.start or 0, args.length
        )
        data2 = (load_coe if args.file2.lower().endswith(".coe") else load_hex_generic)(
            args.file2, args.start or 0, args.length
        )
    except Exception as e:
        LOG.error("Failed: %s", e)
        sys.exit(1)

    total, diffcnt, samples = _compare(data1, data2)

    print("\nComparison Report\n-----------------")
    print(f"File #1 : {args.file1} ({_human(len(data1))}, {len(data1)} entries)")
    print(f"File #2 : {args.file2} ({_human(len(data2))}, {len(data2)} entries)")
    if args.start is not None:
        rng = f"0x{args.start:X}..0x{args.start + (args.length or 0):X}"
        print(f"Window  : {rng}")
    print(f"Total addresses compared : {total}")
    if diffcnt:
        print(f"MISMATCHES               : {diffcnt}")
        for a, v1, v2 in samples:
            print(f"  0x{a:08X} : {v1} vs {v2}")
        sys.exit(2)
    else:
        print("RESULT                   : Files are identical")
        sys.exit(0)


if __name__ == "__main__":
    main()
